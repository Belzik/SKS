import UIKit

class ViewController<View: BaseView>: UIViewController {
    // MARK: - Properties

    let mainView = View()

    // MARK: - Internal methods

    override func loadView() {
        view = mainView
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    func showAlert(actions: [UIAlertAction], title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alertController.addAction($0) }
        present(alertController, animated: true)
    }

    func showAlert(message: String) {
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        showAlert(actions: [action], title: "Внимание!", message: message)
    }
}
