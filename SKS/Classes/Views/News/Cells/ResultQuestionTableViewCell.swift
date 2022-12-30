import UIKit
import SnapKit
import Kingfisher

class ResultQuestionTableViewCell: BaseTableViewCell {
    // MARK: - Views

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.montserrat.bold.s20
        label.textColor = ColorManager.lightBlack.value
        label.numberOfLines = 0

        return label
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16

        return stack
    }()

    private let thxStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical

        return stack
    }()

    private let thxView = UIView()

    private let thxImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_pool_fill")

        return imageView
    }()

    private let thxTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Спасибо за ваши ответы"
        label.font = Fonts.montserrat.bold.s20
        label.textColor = ColorManager._333333.value
        label.textAlignment = .center

        return label
    }()

    // MARK: - Properties

    weak var model: QuestionNew? {
        didSet {
            layout()
        }
    }

    // MARK: - Internal methods

    override func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(stackView)
        contentView.addSubview(thxStack)
        thxView.addSubview(thxImageView)
        thxView.addSubview(thxTitleLabel)
        thxStack.addArrangedSubview(thxView)
        thxView.isHidden = true
    }

    override func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.left.right.equalToSuperview().inset(16)
        }

        stackView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
        }

        thxStack.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.top.equalTo(stackView.snp.bottom).offset(16)
            $0.bottom.equalToSuperview()
        }

        thxImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(24)
            $0.height.equalTo(28)
            $0.width.equalTo(40)
        }

        thxTitleLabel.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(thxImageView.snp.bottom).offset(24)
        }
    }

    // MARK: - Private methods

    private func layout() {
        guard let model = model else { return }
        titleLabel.text = model.question
        while let v = stackView.arrangedSubviews.first {
            stackView.removeArrangedSubview(v)
        }
        var allCount = 0
        if let answers = model.answerVariants {
            for answer in answers {
                allCount += answer.voted ?? 0
            }
        }

        if let countAllOther = model.countAllOther {
            allCount += countAllOther
        }

        if let answers = model.answerVariants {
            for answer in answers {
                if let view = Bundle.main.loadNibNamed(
                    "ResultPoolingTableViewCell",
                    owner: self,
                    options: nil)?.first as? ResultPoolingTableViewCell {
                    answer.countAllOther = allCount
                    view.model = answer
                    let width = UIScreen.main.bounds.size.width - 16 - 16
                    view.snp.makeConstraints {
                        $0.width.equalTo(width)
                        $0.height.equalTo(44)
                    }
                    stackView.addArrangedSubview(view)
                }
            }
        }

        if let allowOther = model.allowOther,
           allowOther {
            var countAllOther: Int
            if let countAllOtherModel = model.countAllOther {
                countAllOther = countAllOtherModel
            } else {
                countAllOther = 0
            }

            if let view = Bundle.main.loadNibNamed(
                "ResultPoolingTableViewCell",
                owner: self,
                options: nil)?.first as? ResultPoolingTableViewCell {
                let answer = AnswerVariant(answerVariant: "Другое", voted: countAllOther)
                answer.countAllOther = allCount
                view.model = answer
                let width = UIScreen.main.bounds.size.width - 16 - 16
                view.snp.makeConstraints {
                    $0.width.equalTo(width)
                    $0.height.equalTo(44)
                }
                stackView.addArrangedSubview(view)
            }
        }

    }

    func showEndView(hidden: Bool) {
        thxView.isHidden = hidden
    }
}
