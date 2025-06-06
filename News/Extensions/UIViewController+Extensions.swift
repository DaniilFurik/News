import UIKit

extension UIViewController {
    func showWarningAlert(with title: String) {
        let alert = UIAlertController(title: title, message: .empty, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: GlobalConstants.Texts.okText, style: .cancel))
        present(alert, animated: true)
    }
    
    func showAlert(title: String, message: String, buttonText: String, handler: @escaping (() -> Void) ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonText, style: .destructive, handler: { _ in
            handler()
        }))
        alert.addAction(UIAlertAction(title: GlobalConstants.Texts.cancelText, style: .cancel))
        present(alert, animated: true)
    }
}
