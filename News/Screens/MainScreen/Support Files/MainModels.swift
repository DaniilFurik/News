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
}
