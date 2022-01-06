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

@objc protocol AddFolderViewDelegate: AnyObject {
    @objc func didFolderAdded()
}

class AddFolderViewController: UIViewController {
    
    // MARK: - Declaraiton
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var emojiTextFieldFrame: UIView!
    @IBOutlet weak var folderEmojiTextField: EmojiTextField!
    @IBOutlet weak var folderTitleTextField: HighlightingTextfield!
    
    weak var delegate: AddFolderViewDelegate?
    private let addFolderViewModel = AddFolderViewModel()
    private var disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupInstance()
        bind()
    }
    
    // MARK: - Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - Initializers
    private func setupView() {
        // Confirm Button
        confirmButton.layer.cornerRadius = 12
        
        // Exit Button
        exitButton.makeAsCircle()
        exitButton.setReversedExitButtonShadow()
        
        // Emoji Textfield Frame
        emojiTextFieldFrame.layer.cornerRadius = 20
        
        // Folder Title Textfield
        folderTitleTextField.setLeftPadding(width: 8)
        folderTitleTextField.setPlaceholderColor(ColorSet.textFieldPlaceholderColor)
    }
    
    private func setupInstance() {
        // Folder Title TextField
        folderTitleTextField.delegate = self
        folderTitleTextField.returnKeyType = .done
    }
    
    private func bind() {
        // Exit Button Tap Action
        exitButton.rx.tap
            .bind(with: self) { vc, _ in
                vc.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
        
        // Confirm Button Tap Action
        confirmButton.rx.tap
            .bind(with: self) { vc, _ in
                guard let title = vc.folderTitleTextField.text else { return }
                guard let titleEmoji = vc.folderEmojiTextField.text else { return }
                
                vc.addFolderViewModel.addFolder(title, titleEmoji)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onCompleted: { [weak vc] in
                        vc?.delegate?.didFolderAdded()
                        vc?.dismiss(animated: true, completion: nil)
                    }).disposed(by: vc.disposeBag)
            }.disposed(by: disposeBag)
        
        // Add Button Success State
        let folderEmojiOb = folderEmojiTextField.rx.text.orEmpty.asDriver().map { !$0.isEmpty }
        let folderTitleOb = folderTitleTextField.rx.text.orEmpty.asDriver().map { !$0.isEmpty }
        
        Driver.combineLatest(folderEmojiOb, folderTitleOb, resultSelector: { $0 && $1 })
            .drive(with: self, onNext: { vc, isAllTextFieldFilled in
                if isAllTextFieldFilled {
                    vc.confirmButton.backgroundColor = ColorSet.addFolderButtonBackgroundColor
                    vc.confirmButton.setTitleColor(ColorSet.addFolderButtonForegroundColor, for: .normal)
                } else {
                    vc.confirmButton.backgroundColor = ColorSet.addFolderButtonDisabledBackgroundColor
                    vc.confirmButton.setTitleColor(ColorSet.disabledTextColor, for: .normal)
                }
                
                vc.confirmButton.isEnabled = isAllTextFieldFilled
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Methods
}

// MARK: - Extensions
extension AddFolderViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}
