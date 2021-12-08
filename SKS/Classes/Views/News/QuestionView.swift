import UIKit
import SnapKit

class QuestionView: SnapKitView {
    // MARK: - Views

    let activityIndicatorView = UIActivityIndicatorView(style: .medium)
    private let mainView = UIView()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.hideScrollIndicators()
        scrollView.isHidden = true

        return scrollView
    }()
    private let contentView = UIView(frame: .zero)

    private lazy var backView: BackView = {
        let view = BackView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(backTapped))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)

        return view
    }()

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.montserrat.bold.s20
        label.textColor = ColorManager.lightBlack.value
        label.numberOfLines = 0

        return label
    }()

    private var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = .zero
        textView.contentInset = UIEdgeInsets(top: -4, left: -6, bottom: 0, right: -6)
        textView.dataDetectorTypes = UIDataDetectorTypes.link
        textView.isScrollEnabled = false
        textView.isEditable = false

        return textView
    }()

    private var separatorOneView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager._B3B3B3.value.withAlphaComponent(0.2)

        return view
    }()

    private var documentView: DocumentView = {
        let view = DocumentView(name: "Прикрепленный документ.docx", mb: "2")

        return view
    }()

    private var separatorTwoView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager._B3B3B3.value.withAlphaComponent(0.2)

        return view
    }()

    private var infoLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.montserrat.bold.s16
        label.textColor = ColorManager._383C45.value
        label.text = "Была ли информация полезна?"
        label.textAlignment = .center

        return label
    }()

    private var stackButton: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20

        return stack
    }()

    var yesButton: UIButton = {
        let button = UIButton()
        button.setTitle("Да", for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = Fonts.montserrat.bold.s16
        button.setTitleColor(ColorManager.green.value, for: .normal)
        button.backgroundColor = .white
        button.setupShadow(
            8,
            shadowRadius: 6,
            color: UIColor.black.withAlphaComponent(0.45),
            offset: CGSize(width: 0, height: 0),
            opacity: 0.25
        )

        button.addTarget(self, action: #selector(yesButtonTapped), for: .touchUpInside)

        return button
    }()

    var noButton: UIButton = {
        let button = UIButton()
        button.setTitle("Нет", for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = Fonts.montserrat.bold.s16
        button.setTitleColor(ColorManager.red.value, for: .normal)
        button.backgroundColor = .white
        button.setupShadow(
            8,
            shadowRadius: 6,
            color: UIColor.black.withAlphaComponent(0.45),
            offset: CGSize(width: 0, height: 0),
            opacity: 0.25
        )

        button.addTarget(self, action: #selector(noButtonTapped), for: .touchUpInside)

        return button
    }()

    var thanksLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.montserrat.regular.s16
        label.textColor = ColorManager.lightBlack.value
        label.text = "Спасибо за ваш отзыв"
        label.textAlignment = .center

        return label
    }()

    private let separatorButton: UIView = {
        let view = UIView()
        view.backgroundColor = ColorManager._EFF2F5.value

        return view
    }()

    private var questionLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.montserrat.bold.s16
        label.textColor = ColorManager._383C45.value
        label.text = "Остались ли еще вопросы?"
        label.textAlignment = .center

        return label
    }()

    private let writeUsButton: UIButton = {
        let button = UIButton()
        button.setTitle("Напишите нам", for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = Fonts.montserrat.bold.s16
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = ColorManager.green.value
        button.addTarget(self, action: #selector(writeButtonTapped), for: .touchUpInside)

        return button
    }()



    // MARK: - Properties

    var backHandler: (() -> Void)?
    var yesHandler: (() -> Void)?
    var noHandler: (() -> Void)?
    var writeHandler: (() -> Void)?

    // MARK: - Internal methods

    func setView(withQuestion question: Question, linkToMessenger: String?) {
        titleLabel.text = question.question

        if let answer = question.answer {
            descriptionTextView.attributedText = answer.html2Attributed
            descriptionTextView.font = Fonts.montserrat.regular.s16
        }

        if linkToMessenger == nil {
            hideQuestionsViews()
        }

        if var link = linkToMessenger {
            link = link.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
            if link == "null" || link == "" {
               hideQuestionsViews()
            }
        }

        setVotedState(isVoted: question.user_voted)
        scrollView.isHidden = false
    }

    func setVotedState(isVoted: Bool?) {
        if let isVoted = isVoted,
           isVoted {
            yesButton.isHidden = true
            noButton.isHidden = true
            thanksLabel.isHidden = false

            yesButton.snp.makeConstraints {
                $0.height.equalTo(22)
            }

            noButton.snp.makeConstraints {
                $0.height.equalTo(22)
            }
        } else {
            thanksLabel.isHidden = true
        }
    }

    override func setup() {
        backgroundColor = .white
        addSubviews()
        setConstraints()
    }

    override func addSubviews() {
        addSubview(mainView)
        mainView.addSubview(activityIndicatorView)
        mainView.addSubview(backView)
        mainView.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(separatorOneView)
//        contentView.addSubview(documentView)
//        contentView.addSubview(separatorTwoView)
        contentView.addSubview(infoLabel)
        contentView.addSubview(stackButton)
        stackButton.addArrangedSubview(yesButton)
        stackButton.addArrangedSubview(noButton)
        stackButton.addArrangedSubview(thanksLabel)
        contentView.addSubview(separatorButton)
        contentView.addSubview(questionLabel)
        contentView.addSubview(writeUsButton)
    }

    override func setConstraints() {
        mainView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.bottom.equalTo(safeAreaLayoutGuide)
        }

        activityIndicatorView.snp.makeConstraints {
            $0.centerY.centerX.equalToSuperview()
        }

        backView.snp.makeConstraints {
            $0.left.equalToSuperview().inset(16)
            $0.top.equalToSuperview().inset(16)
            $0.height.equalTo(20)
        }

        scrollView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(backView.snp.bottom).offset(24)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview().priority(.low)
            $0.width.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.top.equalToSuperview()
        }

        descriptionTextView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
        }

        separatorOneView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(descriptionTextView.snp.bottom).offset(32)
            $0.height.equalTo(6)
        }

//        documentView.snp.makeConstraints {
//            $0.left.right.equalToSuperview().inset(16)
//            $0.top.equalTo(separatorOneView.snp.bottom).offset(28)
//        }
//
//        separatorTwoView.snp.makeConstraints {
//            $0.left.right.equalToSuperview()
//            $0.top.equalTo(documentView.snp.bottom).offset(28)
//            $0.height.equalTo(6)
//        }

        infoLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.top.equalTo(separatorOneView.snp.bottom).offset(28)
        }

        stackButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(infoLabel.snp.bottom).offset(20)
        }

        yesButton.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(48)
        }

        noButton.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(48)
        }

        separatorButton.snp.makeConstraints {
            $0.top.equalTo(stackButton.snp.bottom).offset(28)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }

        questionLabel.snp.makeConstraints {
            $0.top.equalTo(separatorButton.snp.bottom).offset(28)
            $0.left.right.equalToSuperview().inset(16)
        }

        writeUsButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.top.equalTo(questionLabel.snp.bottom).offset(20)
            $0.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
    }

    // MARK: - Private methods

    private func hideQuestionsViews() {
        questionLabel.removeFromSuperview()
        writeUsButton.removeFromSuperview()
        separatorButton.snp.makeConstraints {
            $0.top.equalTo(stackButton.snp.bottom).offset(28)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview().inset(16)
        }
    }

    // MARK: - Actions

    @objc func backTapped() {
        backHandler?()
    }

    @objc func yesButtonTapped() {
        yesHandler?()
    }

    @objc func noButtonTapped() {
        noHandler?()
    }

    @objc func writeButtonTapped() {
        writeHandler?()
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
