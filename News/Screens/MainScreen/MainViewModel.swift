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
    var filteredNews: Observable<[News]> { get }
    
    func loadNews()
    func toggleFavorite(news: News)
    func toggleBlocked(news: News)
    func selectSegment(_ segment: SegmentType)
}

final class MainViewModel {
    // MARK: - Typealiases
    
    typealias Errors = GlobalConstants.Errors
    
    // MARK: - Properties
    
    let publishError = PublishRelay<String>()
    
    private let service: INetworkService = NetworkService()
    private let disposeBag = DisposeBag()
    
    private let allNewsRelay = BehaviorRelay<[News]>(value: [])
    private let favoriteIDsRelay = BehaviorRelay<Set<String>>(value: [])
    private let blockedIDsRelay = BehaviorRelay<Set<String>>(value: [])
    private let selectedSegmentRelay = BehaviorRelay<SegmentType>(value: .all)

    var filteredNews: Observable<[News]> {
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
    
    init() {
        service.publishResult.subscribe(onNext: { [weak self] data in
            guard let self = self else { return }
            guard let data = data else {
                self.publishError.accept(Errors.genericErrorMessage)
                return
            }
            
            let news = self.getFormattedNews(from: data.results)
            self.allNewsRelay.accept(news)
        }).disposed(by: disposeBag)
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
        service.getNews()
    }
    
    func toggleFavorite(news: News) {
        var current = favoriteIDsRelay.value
        current.formSymmetricDifference([news.id])
        favoriteIDsRelay.accept(current)
    }
    
    func toggleBlocked(news: News) {
        var current = blockedIDsRelay.value
        current.formSymmetricDifference([news.id])
        blockedIDsRelay.accept(current)
    }
    
    func selectSegment(_ segment: SegmentType) {
        selectedSegmentRelay.accept(segment)
    }
}
