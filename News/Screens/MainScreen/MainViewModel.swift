import Foundation
import RxSwift
import RxCocoa

enum SegmentType: Int {
    case all
    case favorites
    case blocked
}

// MARK: - Protocol

protocol IMainViewModel {
    var publishError: PublishRelay<String> { get }
    var combinedItems: Observable<[MainModels.TableItem]> { get }
    
    func loadNews()
    func insertFavorite(news: News)
    func removeFavorite(news: News)
    func insertBlocked(news: News)
    func removeBlocked(news: News)
    func selectSegment(_ segment: SegmentType)
}

final class MainViewModel {
    // MARK: - Typealiases
    
    typealias Errors = GlobalConstants.Errors
    typealias Constants = GlobalConstants.Constants
    typealias TableItem = MainModels.TableItem
    
    // MARK: - Properties
    
    let publishError = PublishRelay<String>()
    
    private let networkService: INetworkService = NetworkService()
    private let disposeBag = DisposeBag()
    
    private let allNewsRelay = BehaviorRelay<[News]>(value: [])
    private let favoriteIDsRelay = BehaviorRelay<Set<String>>(value: [])
    private let blockedIDsRelay = BehaviorRelay<Set<String>>(value: [])
    private let selectedSegmentRelay = BehaviorRelay<SegmentType>(value: .all)
    private let navigationRelay = BehaviorRelay<[NavigationDataResponse]>(value: [])

    private var filteredNews: Observable<[News]> {
        Observable.combineLatest(
            allNewsRelay,
            favoriteIDsRelay,
            blockedIDsRelay,
            selectedSegmentRelay
        )
        .map { news, favorites, blocked, segment in
            switch segment {
            case .all:
                return news.filter { !blocked.contains($0.id) }
            case .favorites:
                return news.filter { favorites.contains($0.id) && !blocked.contains($0.id) }
            case .blocked:
                return news.filter { blocked.contains($0.id) }
            }
        }
    }
    
    var combinedItems: Observable<[TableItem]> {
        Observable.combineLatest(filteredNews, navigationRelay)
            .filter { _, navigationBlocks in
                !navigationBlocks.isEmpty
            }
            .map { news, navigationBlocks in
                var result: [TableItem] = []
                for (index, newsItem) in news.enumerated() {
                    result.append(.news(newsItem))
                    if (index + 1) % Constants.blockInterval == .zero {
                        let navIndex = ((index + 1) / Constants.blockInterval - 1) % navigationBlocks.count
                        result.append(.navigation(navigationBlocks[navIndex]))
                    }
                }
                return result
            }
    }
    
    init() {
        Observable.combineLatest(networkService.publishNews, networkService.publishNavigation)
            .compactMap { news, navigation -> (NewsDataResponse, [NavigationDataResponse])? in
                guard let news = news, let navigation = navigation else { return nil }
                return (news, navigation)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { news, navigation in
                let newss = self.getFormattedNews(from: news.results)
                self.allNewsRelay.accept(newss)
                self.navigationRelay.accept(navigation)
            })
            .disposed(by: disposeBag)
    }
}

private extension MainViewModel {
    // MARK: - Private Methods
    
    func getFormattedNews(from newsResponse: [NewsResponse]) -> [News] {
        var news: [News] = []
        for response in newsResponse {
            news.append(News(
                id: response.id,
                title: response.webTitle,
                sectionName: response.sectionName,
                date: response.webPublicationDate,
                url: response.webUrl)
            )
        }
        return news
    }
}

extension MainViewModel: IMainViewModel {
    // MARK: - Methods
    
    func loadNews() {
        networkService.getNews()
        
        if navigationRelay.value.isEmpty {
            networkService.getNavigation()
        }
    }
    
    func insertFavorite(news: News) {
        var current = favoriteIDsRelay.value
        if !current.contains(news.id) {
            current.insert(news.id)
            favoriteIDsRelay.accept(current)
        }
    }
    
    func removeFavorite(news: News) {
        var current = favoriteIDsRelay.value
        if current.contains(news.id) {
            current.remove(news.id)
            favoriteIDsRelay.accept(current)
        }
    }
    
    func insertBlocked(news: News) {
        var current = blockedIDsRelay.value
        if !current.contains(news.id) {
            current.insert(news.id)
            blockedIDsRelay.accept(current)
        }
    }
    
    func removeBlocked(news: News) {
        var current = blockedIDsRelay.value
        if current.contains(news.id) {
            current.remove(news.id)
            blockedIDsRelay.accept(current)
        }
    }
    
    func selectSegment(_ segment: SegmentType) {
        selectedSegmentRelay.accept(segment)
    }
}
