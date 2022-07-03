import UIKit
import XLPagerTabStrip

class AboutRZDProgrammViewController: BaseViewController {
    @IBOutlet weak var descriptionLabel: UILabel!
    weak var delegate: RZDPartnerScrollableDelegate?
}

// MARK: - IndicatorInfoProvider
extension AboutRZDProgrammViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "О Программе")
    }
}

// MARK: - UIScrollViewDelegate
extension AboutRZDProgrammViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView: scrollView)
    }
}
