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
    private let addFolderViewModel = AddFolderViewModel()
    weak var delegate: AddFolderViewDelegate?
    private var disposeBag = DisposeBag()
    
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
        exitButton.setReversedExitButtonShadow()
        
        // Emoji Textfield Frame
        emojiTextFieldFrame.layer.cornerRadius = 20
        
        // Folder Title Textfield
        folderTitleTextField.layer.cornerRadius = 12
        folderTitleTextField.setLeftPadding(width: 8)
        folderTitleTextField.setPlaceholderColor(ColorSet.textFieldPlaceholderColor)
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
        
        // Confirm Button Tap Acrion
        confirmButton.rx.tap
            .bind(with: self) { vc, _ in
                guard let title = vc.folderTitleTextField.text else { return }
                guard let titleEmoji = vc.folderEmojiTextField.text else { return }
                
                vc.addFolderViewModel.addFolder(title, titleEmoji)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onCompleted: { [weak vc] in
                        vc?.delegate?.addFolderView(didAddFile: true)
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
                    vc.confirmButton.setTitleColor(ColorSet.textColor, for: .normal)
                } else {
                    vc.confirmButton.backgroundColor = ColorSet.addFolderButtonDisabledBackgroundColor
                    vc.confirmButton.setTitleColor(ColorSet.disabledTextColor, for: .normal)
                }
                
                vc.confirmButton.isEnabled = isAllTextFieldFilled
            }).disposed(by: disposeBag)
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
