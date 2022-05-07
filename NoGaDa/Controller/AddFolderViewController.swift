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
    
    
    // MARK: - Properteis
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var emojiTextFieldFrameView: UIView!
    @IBOutlet weak var folderEmojiTextField: EmojiTextField!
    @IBOutlet weak var folderTitleTextField: HighlightingTextfield!
    
    weak var delegate: AddFolderViewDelegate?
    private let viewModel: AddFolderViewModel
    private var disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
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
    
    init(_ viewModel: AddFolderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    init?(_ coder: NSCoder, _ viewModel: AddFolderViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Setups
    
    private func setupView() {
        setupFolderTitleTextfield()
        setupConfirmButton()
        setupExitButton()
        setupEmojiTextFieldFrameView()
        setupFolderTitleTextField()
    }
    
    private func bind() {
        bindConfirmButton()
        bindConfirmButtonActivateState()
        bindExitButton()
    }
    
    private func setupFolderTitleTextfield() {
        folderTitleTextField.delegate = self
        folderTitleTextField.returnKeyType = .done
    }
    
    private func setupConfirmButton() {
        confirmButton.layer.cornerRadius = 12
    }
    
    private func setupExitButton() {
        exitButton.makeAsCircle()
        exitButton.setReversedExitButtonShadow()
    }
    
    private func setupEmojiTextFieldFrameView() {
        emojiTextFieldFrameView.layer.cornerRadius = 20
    }
    
    private func setupFolderTitleTextField() {
        folderTitleTextField.setLeftPadding(width: 8)
        folderTitleTextField.setPlaceholderColor(ColorSet.textFieldPlaceholderColor)
    }
    
    
    // MARK: - Binds
    
    private func bindConfirmButton() {
        confirmButton.rx.tap
            .asDriver()
            .drive(with: self) { vc, _ in
                guard let title = vc.folderTitleTextField.text else { return }
                guard let titleEmoji = vc.folderEmojiTextField.text else { return }
                
                vc.viewModel.addFolder(title, titleEmoji)
                    .observe(on: MainScheduler.instance)
                    .subscribe(onCompleted: { [weak vc] in
                        vc?.delegate?.didFolderAdded()
                        vc?.dismiss(animated: true, completion: nil)
                    }).disposed(by: vc.disposeBag)
            }.disposed(by: disposeBag)
    }
    
    private func bindConfirmButtonActivateState() {
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
    
    private func bindExitButton() {
        exitButton.rx.tap
            .asDriver()
            .drive(with: self) { vc, _ in
                vc.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
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
