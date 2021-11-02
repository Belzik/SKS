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
}
