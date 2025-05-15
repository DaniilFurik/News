import Foundation

final class NavigationDataResponse: Decodable {
    let id: Int
    let title: String
    let buttonTitle: String
    let navigation: String
    let subtitle: String?
    let titleSymbol: String?
    let buttonSymbol: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, navigation
        case buttonTitle = "button_title"
        case buttonSymbol = "button_symbol"
        case titleSymbol = "title_symbol"
    }
}
