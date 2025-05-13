import Foundation
import RxRelay

// MARK: - Protocol

protocol INetworkService {
    func getNews()
    var publishResult: PublishRelay<DataResponse?> { get set }
}

final class NetworkService {
    // MARK: - Typealiases
    
    typealias Constants = NetworkServiceModels.Constants
    typealias Parameters = NetworkServiceModels.Parameters
    typealias RequestType = NetworkServiceModels.RequestType
    typealias AuthorizationHeader = NetworkServiceModels.AuthorizationHeader
    
    // MARK: - Properties
    
    var publishResult = PublishRelay<DataResponse?>()
}
extension NetworkService {
    // MARK: - Private Methods
    
    private func getURLRequest(urlComponents: URLComponents?) -> URLRequest? {
        guard let url = urlComponents?.url else { return nil }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = RequestType.GET.rawValue
        urlRequest.setValue(AuthorizationHeader.name, forHTTPHeaderField: AuthorizationHeader.authorization)
        
        return urlRequest
    }
    
    private func handleDecodingError(_ error: Error) {
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
    
    func getNews() {
        var urlComponents = URLComponents(string: Parameters.baseURL + Parameters.guardian)
        urlComponents?.queryItems = [
            URLQueryItem(name: Parameters.page, value: Constants.page.description),
            URLQueryItem(name: Parameters.pageSize, value: Constants.pageSize.description),
        ]
        
        if let request = getURLRequest(urlComponents: urlComponents) {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(for: request)
                    let response = try JSONDecoder().decode(Response.self, from: data)
                    publishResult.accept(response.response)
                } catch let error as DecodingError {
                    self.handleDecodingError(error)
                    publishResult.accept(nil)
                } catch {
                    print(error.localizedDescription)
                    publishResult.accept(nil)
                }
            }
        } else {
            publishResult.accept(nil)
        }
    }
}
