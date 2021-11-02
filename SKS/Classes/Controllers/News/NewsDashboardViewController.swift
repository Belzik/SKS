import UIKit

class NewsDashboardViewController: ViewController<NewsDashboardView> {
    // MARK: - Properties

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.style
    }
    private var style: UIStatusBarStyle = .lightContent

    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.newsHandler = { [weak self] news in
            guard let self = self else { return }
            if news.pooling?.uuidPooling != nil {
                self.performSegue(withIdentifier: "seguePoolingNews", sender: news)
            } else {
                self.performSegue(withIdentifier: "segueDetailNews", sender: news)
            }
        }

        mainView.knowledgeHandler = { [weak self] news in
            guard let self = self else { return }
            self.performSegue(withIdentifier: "segueKnowledge", sender: news)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueDetailNews" {
            let dvc = segue.destination as! DetailNewsViewController
            if let news = sender as? News {
                dvc.model = news
            }
        }

        if segue.identifier == "seguePoolingNews" {
            let dvc = segue.destination as! PoolingNewsViewController
            if let news = sender as? News {
                dvc.model = news
            }
        }
    }

}
