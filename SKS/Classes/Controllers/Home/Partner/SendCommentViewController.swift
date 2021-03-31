//
//  SendCommentViewController.swift
//  SKS
//
//  Created by Alexander on 06/12/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

import UIKit
import Cosmos

protocol SendCommentViewControllerDelegate: class {
    func commentSent()

}

class SendCommentViewController: BaseViewController {
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var commentTextField: SKSTextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendCommentButtonTapped(_ sender: SKSButton) {
        if ratingView.rating == 0 {
            showAlert(message: "Для отправки отзыва необходимо указать рейтинг.")
        }
        
        sendData()
    }
    
    var uuidPartner: String = ""
    let dispatchGroup = DispatchGroup()
    var isHaveErrors = false
    var delegate: SendCommentViewControllerDelegate?
    
    var chComment: CheckComment?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        checkComment()
        commentTextField.delegate = self
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func checkComment() {
        activityIndicator.startAnimating()
        NetworkManager.shared.getCommentUser(uuidPartner: uuidPartner) { [weak self] result in
            self?.activityIndicator.stopAnimating()
            if let chComment = result.result.value {
                self?.chComment = chComment
                self?.commentTextField.text = chComment.info?.comment
                
                if let rating = chComment.rating {
                    self?.ratingView.rating = Double(rating)
                }
            }
        }
    }
    
    func sendData() {
        sendRating()
        
        if chComment?.info?.uuidComment != nil {
            editComment()
        } else {
            if commentTextField.text!.count > 0 {
                dispatchGroup.enter()
            }
        }
        
        
//        else {
//            if commentTextField.text!.count > 0 {
//                sendComment()
//            }
//        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let isHaveErrors = self?.isHaveErrors else { return }
            
            if !isHaveErrors {
                self?.delegate?.commentSent()
                let alertAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    self?.dismiss(animated: true, completion: nil)
                }
                self?.showAlert(actions: [alertAction], title: "Успех", message: "Ваш отзыв отправлен")
            }
        }
    }
    
    func sendComment() {
        //dispatchGroup.enter()
        NetworkManager.shared.sendCommentToPartner(uuidPartner: uuidPartner,
                                                   comment: commentTextField.text!) { [weak self] result in
            self?.dispatchGroup.leave()
            if result.statusCode == 200 {
                self?.isHaveErrors = false
                
            } else {
                self?.isHaveErrors = true
                if let statusCode = result.statusCode,
                    statusCode == 403 {
                    self?.showAlert(message: "Для того, чтобы оставить отзыв необходимо статус подтвержденного пользователя")
                } else {
                    self?.showAlert(message: NetworkErrors.common)
                }
            }
        }
    }
    
    func editComment() {
        guard let uuidComment = chComment?.info?.uuidComment else {return }
        
        dispatchGroup.enter()
        NetworkManager.shared.editCommentToPartner(uuidComment: uuidComment,
                                                   comment: commentTextField.text!) { [weak self] result in
            self?.dispatchGroup.leave()
            if result.statusCode == 200 {
                self?.isHaveErrors = false
            } else {
                self?.isHaveErrors = true
                if let statusCode = result.statusCode,
                    statusCode == 403 {
                    self?.showAlert(message: "Для того, чтобы оставить отзыв необходимо статус подтвержденного пользователя")
                } else {
                    self?.showAlert(message: NetworkErrors.common)
                }
            }
        }
    }
    
    
    func sendRating() {
        dispatchGroup.enter()
        NetworkManager.shared.sendRatingToPartner(uuidPartner: uuidPartner,
                                                  rating: ratingView.rating) { [weak self] result in
            self?.dispatchGroup.leave()
            if result.statusCode == 200 {
                self?.isHaveErrors = false
                
                if self?.chComment?.info?.uuidComment == nil {
                    if self!.commentTextField.text!.count > 0 {
                        self?.sendComment()
                    }
                }
            } else {
                self?.isHaveErrors = true
                
                if let statusCode = result.statusCode,
                    statusCode == 403 {
                    self?.showAlert(message: "Для того, чтобы оставить отзыв необходимо статус подтвержденного пользователя")
                } else {
                    self?.showAlert(message: NetworkErrors.common)
                }
                
            }
        }
    }
}

extension SendCommentViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        
        return true
    }
}
