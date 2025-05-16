import UIKit

// MARK: - Protocol

protocol IMainRouter {
    func showViewController(
        from viewController: UIViewController,
        to destination: UIViewController,
        with navigation:  MainModels.NavigationType
    )
}

final class MainRouter: IMainRouter {
    
    // MARK: - Typealiases
    
    typealias NavigationType = MainModels.NavigationType
}

extension MainRouter {
    // MARK: - Methods
    
    func showViewController(from viewController: UIViewController, to destination: UIViewController, with navigation: NavigationType) {
        switch navigation {
        case .push:
            viewController.navigationController?.pushViewController(destination, animated: true)

        case .modal:
            destination.modalPresentationStyle = .pageSheet
            if let sheet = destination.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
            }
            viewController.present(destination, animated: true)

        case .fullScreen:
            destination.modalPresentationStyle = .fullScreen
            viewController.present(destination, animated: true)
        }
    }
}
