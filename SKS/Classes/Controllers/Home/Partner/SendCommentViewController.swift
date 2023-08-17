//
//  SendCommentViewController.swift
//  SKS
//
//  Created by Alexander on 06/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import Cosmos

protocol SendCommentViewControllerDelegate: AnyObject {
    func commentSent()

}

class SendCommentViewController: BaseViewController {
    // MARK: Views

    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var commentTextField: SKSTextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Properties

    var uuidPartner: String = ""
    let dispatchGroup = DispatchGroup()
    var isHaveErrors = false
    var delegate: SendCommentViewControllerDelegate?
    
    var chComment: CheckComment?

    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentTextField.delegate = self
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    // MARK: Methods
    
    func sendData() {
        sendRating()
    }

    func endData() {
        if !isHaveErrors {
            delegate?.commentSent()
            let alertAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }
            showAlert(actions: [alertAction], title: "Успех", message: "Ваш отзыв отправлен")
        }
    }
    
    func sendComment(idRating: Int) {
        NetworkManager.shared.sendCommentToPartner(
            uuidPartner: uuidPartner,
            comment: commentTextField.text!,
            idRating: idRating
        ) { [weak self] result in
            if result.responseCode == 200 {
                self?.isHaveErrors = false
                self?.endData()
            } else {
                self?.isHaveErrors = true
                if let statusCode = result.responseCode,
                    statusCode == 403 {
                    self?.showAlert(message: "Для того, чтобы оставить отзыв необходимо статус подтвержденного пользователя")
                } else if let statusCode = result.responseCode,
                             statusCode == 429 {
                    self?.showAlert(message: "Вы не можете оставить отзыв, так как не прошло 24 часа с предыдущего")
                } else {
                    self?.showAlert(message: NetworkErrors.common)
                }
            }
        }
    }
    
    func sendRating() {
        NetworkManager.shared.sendRatingToPartner(uuidPartner: uuidPartner,
                                                  rating: ratingView.rating) { [weak self] result in
            if let responseCode = result.responseCode,
               responseCode == 200 {
                self?.isHaveErrors = false

                if self!.commentTextField.text!.count > 0,
                   let idRating = result.value?.idRating {
                    self?.sendComment(idRating: idRating)
                } else {
                    self?.endData()
                }
            } else {
                self?.isHaveErrors = true
                
                if let statusCode = result.responseCode,
                    statusCode == 403 {
                    self?.showAlert(message: "Для того, чтобы оставить отзыв необходимо статус подтвержденного пользователя")
                } else if let statusCode = result.responseCode,
                             statusCode == 429 {
                    self?.showAlert(message: "Вы не можете оставить отзыв, так как не прошло 24 часа с предыдущего")
                } else {
                    self?.showAlert(message: NetworkErrors.common)
                }
            }
        }
    }

    // MARK: Actions

    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func sendCommentButtonTapped(_ sender: DownloadButton) {
        if ratingView.rating == 0 {
            showAlert(message: "Для отправки отзыва необходимо указать рейтинг.")
        }

        sendData()
    }
}

extension SendCommentViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        
        return true
    }
}
