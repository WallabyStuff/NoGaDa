//
//  AddFolderViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture

protocol AddFolderViewDelegate: AnyObject {
    func addFolderView(didAddFile: Bool)
}

class AddFolderViewController: UIViewController {
    
    // MARK: - Declaraiton
    weak var delegate: AddFolderViewDelegate?
    var disposeBag = DisposeBag()
    let archiveFolderManager = ArchiveFolderManager()
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var emojiTextFieldFrame: UIView!
    @IBOutlet weak var folderEmojiTextField: EmojiTextField!
    @IBOutlet weak var folderTitleTextField: UITextField!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        initInstance()
        initEventListener()
    }
    
    // MARK: - Override
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - Initialization
    private func initView() {
        // Confirm Button
        confirmButton.layer.cornerRadius = 12
        
        // Exit Button
        exitButton.makeAsCircle()
        
        // Emoji Textfield Frame
        emojiTextFieldFrame.layer.cornerRadius = 20
        
        // Folder Title Textfield
        folderTitleTextField.layer.cornerRadius = 12
        folderTitleTextField.setLeftPadding(width: 8)
        folderTitleTextField.setRightPadding(width: 8)
        folderTitleTextField.setPlaceholderColor(ColorSet.textfieldPlaceholderColor)
    }
    
    private func initInstance() {
        // Folder Title TextField
        folderTitleTextField.delegate = self
        folderTitleTextField.returnKeyType = .done
    }
    
    private func initEventListener() {
        // Exit Button Tap Action
        exitButton.rx.tap
            .bind(with: self) { vc, _ in
                vc.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
        
        // Emoji Textfield Input
        folderEmojiTextField.rx.text
            .bind(with: self) { vc, string in
                guard let string = string else { return }
                if string.count >= 1 {
                    guard let inputChar = string.last else { return }
                    
                    if !inputChar.isEmoji {
                        vc.folderEmojiTextField.text = ""
                    } else {
                        vc.folderEmojiTextField.text = inputChar.description
                    }
                }
            }.disposed(by: disposeBag)
        
        // Confirm Button Tap Acrion
        confirmButton.rx.tap
            .bind(with: self) { vc, _ in
                guard let title = vc.folderTitleTextField.text else { return }
                guard let titleEmoji = vc.folderEmojiTextField.text else { return }
                vc.archiveFolderManager.addData(title: title, titleEmoji: titleEmoji)
                    .subscribe {
                        vc.delegate?.addFolderView(didAddFile: true)
                        vc.dismiss(animated: true, completion: nil)
                    } onError: { error in
                        print(error)
                    }.disposed(by: vc.disposeBag)
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Method
}

// MARK: - Extension
extension AddFolderViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}
