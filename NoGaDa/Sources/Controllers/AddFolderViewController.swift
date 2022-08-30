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
  
  static let identifier = R.storyboard.folder.addFolderStoryboard.identifier
  
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
  
  private func bind() {
    bindIntputs()
    bindOutputs()
  }
  
  private func bindIntputs() {
    exitButton
      .rx.tap
      .bind(to: viewModel.input.tapExitButton)
      .disposed(by: disposeBag)
    
    folderEmojiTextField
      .rx.text
      .orEmpty
      .bind(to: viewModel.input.folderEmoji)
      .disposed(by: disposeBag)
    
    folderTitleTextField
      .rx.text
      .orEmpty
      .bind(to: viewModel.input.folderTitle)
      .disposed(by: disposeBag)
    
    confirmButton
      .rx.tap
      .bind(to: viewModel.input.tapConfirmButton)
      .disposed(by: disposeBag)
  }
  
  private func bindOutputs() {
    viewModel.output.dismiss
      .asDriver(onErrorDriveWith: .never())
      .drive(onNext: { [weak self] in
        self?.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
    
    viewModel.output.isConfirmButtonActive
      .asDriver(onErrorDriveWith: .never())
      .drive(with: self, onNext: { vc, isActive in
        if isActive {
          vc.activeConfirmButton()
        } else {
          vc.inactiveConfirmButton()
        }
      })
      .disposed(by: disposeBag)
    
    viewModel.output.didFolderAdded
      .asDriver(onErrorDriveWith: .never())
      .drive(onNext: { [weak self] in
        self?.delegate?.didFolderAdded()
      })
      .disposed(by: disposeBag)
  }
  
  
  // MARK: - Method
  
  private func activeConfirmButton() {
    confirmButton.backgroundColor = ColorSet.addFolderButtonBackgroundColor
    confirmButton.setTitleColor(ColorSet.addFolderButtonForegroundColor, for: .normal)
    confirmButton.isEnabled = true
  }
  
  private func inactiveConfirmButton() {
    confirmButton.backgroundColor = ColorSet.addFolderButtonDisabledBackgroundColor
    confirmButton.setTitleColor(ColorSet.disabledTextColor, for: .normal)
    confirmButton.isEnabled = true
  }
}


// MARK: - Extensions

extension AddFolderViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    view.endEditing(true)
    return false
  }
}
