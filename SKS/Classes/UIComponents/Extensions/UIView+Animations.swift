import UIKit

public extension UIView {
    func transitionCrossDissolve(
        duration: TimeInterval = 0.25,
        then: (() -> Void)? = nil
    ) {
        UIView.transition(
            with: self,
            duration: duration,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: wrapped(completion: then)
        )
    }

    func animateCurveLinear(
        duration: TimeInterval = 0.25,
        animations: @escaping (() -> Void)
    ) {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: .curveLinear,
            animations: animations,
            completion: nil
        )
    }


    private func wrapped(completion: (() -> Void)?) -> ((Bool) -> Void)? {
        guard let completion = completion else {
            return nil
        }
        return { _ in
            completion()
        }
    }
}
