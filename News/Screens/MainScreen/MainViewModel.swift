import Foundation
import RxSwift
import RxCocoa

// MARK: - Protocol

protocol IMainViewModel {
    var publishError: PublishRelay<String> { get set }
    var newsItems: Observable<[News]> { get }
    func loadNews()
}

final class MainViewModel {
    // MARK: - Properties
    
    var publishError = PublishRelay<String>()
    
    private let itemsRelay = BehaviorRelay<[News]>(value: [])
    private let service: INetworkService = NetworkService()
    private let disposeBag = DisposeBag()
    
    var newsItems: Observable<[News]> {
        return itemsRelay.asObservable()
    }
    
    init() {
        service.publishResult.subscribe(onNext: { [weak self] data in
            guard let self, let data else {
                self?.publishError.accept("ERROR")
                return
            }
            
            var news = self.getFormattedNews(from: data.results)
            news = self.getFilteredNews(from: news)
            self.itemsRelay.accept(news)
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
    
    func getFilteredNews(from news:[News]) -> [News] {
        return news
    }
}

extension MainViewModel: IMainViewModel {
    // MARK: - Methods
    
    func loadNews() {
        service.getNews()
    }
    
    func addItem() {
//        var current = itemsRelay.value
//        current.append(News(title: "Элемент \(current.count + 1)"))
//        itemsRelay.accept(current)
    }
    
    func removeItem() {
//        var current = itemsRelay.value
//        guard !current.isEmpty else { return }
//        current.removeLast()
//        itemsRelay.accept(current)
    }
    
}
