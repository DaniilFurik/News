import Foundation

enum NetworkServiceModels {
    enum Constants {
        static let page = 5
        static let pageSize = 50
    }

    enum Parameters {
        static let baseURL = "https://us-central1-server-side-functions.cloudfunctions.net"
        static let guardian = "/guardian"
        static let navigation = "/navigation"
        
        static let page = "page"
        static let pageSize = "page-size"
    }
    
    enum AuthorizationHeader {
        static let name = "firstname-lastname"
        static let authorization = "Authorization"
    }
    
    enum RequestType: String {
        case GET
        case POST
    }
}
