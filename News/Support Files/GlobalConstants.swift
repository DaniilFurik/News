import UIKit

enum GlobalConstants {
    enum Colors {
        static let beigeColor = UIColor(named: "BeigeColor")
        static let blackColor = UIColor(named: "BlackColor")
        static let blueColor = UIColor(named: "BlueColor")
        static let cyanBlueColor = UIColor(named: "CyanBlueColor")
        static let greyColor = UIColor(named: "GreyColor")
    }
    
    enum Constants {
        static let verticalSpacing: CGFloat = 8
        static let horizontalSpacing: CGFloat = 16
        static let cellSize: CGFloat = 126
    }
    
    enum Fonts {
        static let primaryFont: UIFont = .systemFont(ofSize: 17, weight: .medium)
        static let secondaryFont: UIFont = .systemFont(ofSize: 15, weight: .regular)
    }
    
    enum Errors {
        static let noConnectionErrorMessage = "No internet connection"
        static let genericErrorMessage = "Something went wrong"
    }
}
