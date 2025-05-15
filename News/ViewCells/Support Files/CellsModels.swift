import UIKit

enum CellsModels {
    enum Constants {
        static let cellSpacing: CGFloat = 12
        static let menuButtonSize: CGFloat = 24
        static let circleSize: CGFloat = 6
    }
    
    enum Images {
        static let newsImage = UIImage(systemName: "text.page")
        static let menuImage = UIImage(systemName: "ellipsis.circle")
        static let heartImage = UIImage(systemName: "heart")
        static let heartSlashImage = UIImage(systemName: "heart.slash")
        static let blockImage = UIImage(systemName: "circle.slash")
        static let unblockImage = UIImage(systemName: "lock.open")
        static let circleImage = UIImage(systemName: "circle.fill")
    }
    
    enum Texts {
        static let addToFavorite = "Add to favorite"
        static let removeFromFavorite = "Remove from favorite"
        static let block = "Block"
        static let unblock = "Unblock"
        static let titleBlock = "Do you want to block?"
        static let titleUnblock = "Do you want to unblock?"
        static let messageBlock = "Confirm to hide this news source"
        static let messageUnblock = "Confirm to unblock this news source"
    }
}
