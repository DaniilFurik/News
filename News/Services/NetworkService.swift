import Foundation
import RxRelay

// MARK: - Protocol

protocol INetworkService {
    func getNews(page: Int)
    func getNavigation()
    var publishNews: PublishRelay<NewsDataResponse?> { get set }
    var publishNavigation: PublishRelay<[NavigationDataResponse]?> { get set }
}

final class NetworkService {
    // MARK: - Typealiases
    
    typealias Constants = NetworkServiceModels.Constants
    typealias Parameters = NetworkServiceModels.Parameters
    typealias RequestType = NetworkServiceModels.RequestType
    typealias AuthorizationHeader = NetworkServiceModels.AuthorizationHeader
    
    // MARK: - Properties
    
    var publishNews = PublishRelay<NewsDataResponse?>()
    var publishNavigation = PublishRelay<[NavigationDataResponse]?>()
}
private extension NetworkService {
    // MARK: - Private Methods
    
    func getURLRequest(urlComponents: URLComponents?) -> URLRequest? {
        guard let url = urlComponents?.url else { return nil }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = RequestType.GET.rawValue
        urlRequest.setValue(AuthorizationHeader.name, forHTTPHeaderField: AuthorizationHeader.authorization)
        
        return urlRequest
    }
    
    func handleDecodingError(_ error: Error) {
        switch error {
        case let DecodingError.dataCorrupted(context):
            print("Data corrupted: \(context)")
        case let DecodingError.keyNotFound(key, context):
            print("Key '\(key)' not found: \(context)")
        case let DecodingError.typeMismatch(type, context):
            print("Type mismatch: \(type), \(context)")
        case let DecodingError.valueNotFound(value, context):
            print("Value '\(value)' not found: \(context)")
        default:
            print("Parse error: \(error)")
        }
    }
}

extension NetworkService: INetworkService {
    // MARK: - Methods
    
    func getNews(page: Int) {
        var urlComponents = URLComponents(string: Parameters.baseURL + Parameters.guardian)
        urlComponents?.queryItems = [
            URLQueryItem(name: Parameters.page, value: page.description),
            URLQueryItem(name: Parameters.pageSize, value: Constants.pageSize.description),
        ]
        
        if let request = getURLRequest(urlComponents: urlComponents) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(for: request)
                    let response = try JSONDecoder().decode(DataResponse.self, from: data)
                    publishNews.accept(response.response)
                } catch let error as DecodingError {
                    self.handleDecodingError(error)
                    publishNews.accept(nil)
                } catch {
                    print(error.localizedDescription)
                    publishNews.accept(nil)
                }
            }
        } else {
            publishNews.accept(nil)
        }
    }
    
    func getNavigation() {
        let urlComponents = URLComponents(string: Parameters.baseURL + Parameters.navigation)
        
        if let request = getURLRequest(urlComponents: urlComponents) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(for: request)
                    let response = try JSONDecoder().decode(NavigationResponse.self, from: data)
                    publishNavigation.accept(response.results)
                } catch let error as DecodingError {
                    handleDecodingError(error)
                    publishNavigation.accept(nil)
                } catch {
                    print(error.localizedDescription)
                    publishNavigation.accept(nil)
                }
            }
        } else {
            publishNavigation.accept(nil)
        }
    }
}
