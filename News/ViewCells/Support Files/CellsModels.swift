import UIKit

enum CellsModels {
    enum Constants {
        static let cellSpacing: CGFloat = 12
        static let menuButtonSize: CGFloat = 24
        static let bigRadius: CGFloat = 8
        static let smallRadius = bigRadius / 2
        static let circleSize: CGFloat = 6
    }
    
    enum Images {
        static let newsImage = UIImage(systemName: "text.page")
        static let menuImage = UIImage(systemName: "ellipsis.circle")
        static let heartImage = UIImage(systemName: "heart")
        static let blockImage = UIImage(systemName: "circle.slash")
        static let circleImage = UIImage(systemName: "circle.fill")
    }
    
    enum Texts {
        static let addToFavorite = "Add to favorite"
        static let block = "Block"
    }
}
