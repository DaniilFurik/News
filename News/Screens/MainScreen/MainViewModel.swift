import Foundation
import RxSwift
import RxCocoa

// MARK: - Protocol

protocol IMainViewModel {
    var publishError: PublishRelay<String> { get }
    var combinedItems: Observable<[MainModels.TableItem]> { get }
    var isLoading: Observable<Bool> { get }
    
    func loadLatestNews()
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
        
    private var currentPage = MainModels.Constants.defaultPage

    private let networkService: INetworkService = NetworkService()
    private let disposeBag = DisposeBag()
    
    private let allNewsRelay = BehaviorRelay<[News]>(value: [])
    private let favoriteIDsRelay = BehaviorRelay<Set<String>>(value: [])
    private let blockedIDsRelay = BehaviorRelay<Set<String>>(value: [])
    private let selectedSegmentRelay = BehaviorRelay<SegmentType>(value: .all)
    private let navigationRelay = BehaviorRelay<[NavigationDataResponse]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)

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
    
    var isLoading: Observable<Bool> { isLoadingRelay.asObservable() }
    let publishError = PublishRelay<String>()
    
    // MARK: - Lifecycle
    
    init() {
        Observable.combineLatest(networkService.publishNews, networkService.publishNavigation)
            .compactMap { news, navigation -> (NewsDataResponse, [NavigationDataResponse])? in
                guard let news, let navigation else {
                    self.publishError.accept(GlobalConstants.Errors.genericErrorMessage)
                    self.isLoadingRelay.accept(false)
                    return nil
                }
                return (news, navigation)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] news, navigation in
                self?.handleFetched(newsResponse: news.results, navigation: navigation)
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
    
    private func handleFetched(newsResponse: [NewsResponse], navigation: [NavigationDataResponse]) {
        let news = getFormattedNews(from: newsResponse)
        
        let updatedNews: [News]
        if currentPage == MainModels.Constants.defaultPage {
            updatedNews = news
        } else {
            updatedNews = allNewsRelay.value + news
        }

        allNewsRelay.accept(updatedNews)
        navigationRelay.accept(navigation)
        
        isLoadingRelay.accept(false)
    }
}

extension MainViewModel: IMainViewModel {
    // MARK: - Methods
    
    func loadLatestNews() {
        if NetworkManager.shared.isConnected {
            guard !isLoadingRelay.value else { return }
            
            isLoadingRelay.accept(true)
            currentPage = MainModels.Constants.defaultPage
            networkService.getNews(page: currentPage)
            
            if navigationRelay.value.isEmpty {
                networkService.getNavigation()
            }
        } else {
            publishError.accept(GlobalConstants.Errors.noConnectionErrorMessage)
        }
    }
    
    func loadNews() {
        if NetworkManager.shared.isConnected {
            guard !isLoadingRelay.value else { return }
            
            isLoadingRelay.accept(true)
            currentPage += 1
            networkService.getNews(page: currentPage)
        } else {
            publishError.accept(GlobalConstants.Errors.noConnectionErrorMessage)
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
