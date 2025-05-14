import UIKit

extension UIViewController {
    func showWarningAlert(with message: String) {
        let alert = UIAlertController(title: message, message: .empty, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "", message: .empty, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "", style: .default, handler: { _ in
            
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Destructive", style: .destructive, handler: { _ in }))
        present(alert, animated: true)
    }
}
