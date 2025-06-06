import UIKit

enum MainModels {
    enum Texts {
        static let titleText = "News"
        static let allText = "All"
        static let favoritesText = "Favorites"
        static let blockedText = "Blocked"
        static let resfreshText = "Refresh"
        static let emptyNewsText = "No Results"
        static let emptyFavoritesText = "No Favorites News"
        static let emptyBlockedText = "No Blocked News"
    }
    
    enum Images {
        static let emptyNewsImage = UIImage(systemName: "exclamationmark.circle.fill")
        static let emptyFavotitesImage = UIImage(systemName: "heart.circle.fill")
        static let emptyBlockedImage = UIImage(systemName: "circle.slash")
        static let refreshImage = UIImage(systemName: "arrow.clockwise")
    }
    
    enum TableItem {
        case news(News)
        case navigation(NavigationDataResponse)
    }
    
    enum NavigationType: String {
        case push
        case modal
        case fullScreen

        init(rawValue: String) {
            switch rawValue {
            case "push": self = .push
            case "modal": self = .modal
            case "full_screen": self = .fullScreen
            default: self = .push
            }
        }
    }
    
    enum Constants {
        static let defaultPage = 1
        static let emptyNewsHeight: CGFloat = 132
        static let emptyFavoriteHeight: CGFloat = 76
        static let spacing: CGFloat = 50
    }
    
    enum StorageKeys {
        static let favorites = "FavoriteNewsIDs"
        static let blocked = "BlockedNewsIDs"
    }
}
