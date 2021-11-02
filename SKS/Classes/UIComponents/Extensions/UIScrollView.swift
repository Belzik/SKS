import UIKit.UIScrollView

public extension UIScrollView {
    func hideScrollIndicators() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
}
