import UIKit
import SnapKit

public struct TabElement {
    let title: String
    let viewController: UIViewController

    public init(title: String, viewController: UIViewController) {
        self.title = title
        self.viewController = viewController
    }
}

public class TabView: SnapKitView {
    // MARK: - Views

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.hideScrollIndicators()
        return scrollView
    }()
    private let contentView = UIView(frame: .zero)
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let customSegmentedControl = TabSegmentedControl()

    // MARK: - Properties

    public var tabs: [TabElement] = []

    // MARK: - Init

    public convenience init(tabs: [TabElement]) {
        self.init()
        self.tabs = tabs
        scrollView.delegate = self
        setup()
    }

    // MARK: - Private methods

    private func pageNumber() -> CGFloat {
        return round(scrollView.contentOffset.x / scrollView.frame.size.width)
    }

    // MARK: - Public methods

    public override func addSubviews() {
        addSubview(customSegmentedControl)
        customSegmentedControl.delegate = self
        customSegmentedControl.configure(with: tabs.map { $0.title })

        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        for view in tabs.map({ $0.viewController.view! }) {
            stackView.addArrangedSubview(view)
            view.snp.makeConstraints {
                $0.height.equalToSuperview()
                $0.width.equalTo(Constant.screenWidth)
            }
        }
    }

    public override func setConstraints() {
        customSegmentedControl.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
        }

        scrollView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(customSegmentedControl.snp.bottom).offset(8)
        }
        contentView.snp.makeConstraints {
            $0.left.top.right.bottom.equalToSuperview()
            $0.height.equalToSuperview()
            $0.width.equalToSuperview().priority(250)
        }
        stackView.snp.makeConstraints {
            $0.left.top.right.bottom.equalToSuperview()
        }
    }
}

// MARK: - UIScrollViewDelegate
extension TabView: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        customSegmentedControl.selectButton(Int(pageNumber()))
    }
}

// MARK: - CustomSegmentedControlDelegate
extension TabView: TabSegmentedControlDelegate {
    func changeView(to index: Int) {
        if pageNumber() != CGFloat(index) {
            UIView().animateCurveLinear {
                self.scrollView.contentOffset.x = Constant.screenWidth * CGFloat(index)
            }
        }
    }
}

// MARK: - Constants
extension TabView {
    enum Constant {
        static let screenWidth = UIScreen.main.bounds.size.width
    }
}
