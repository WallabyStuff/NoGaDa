//
//  AddSongViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/12/07.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture
import Hero


@objc protocol AddSongViewDelegate: AnyObject {
    @objc optional func didSongAdded()
}

class AddSongViewController: UIViewController {
    
    
    // MARK: - Properties
    
    static let identifier = R.storyboard.archive.addSongStoryboard.identifier
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var songTitleTextField: HighlightingTextfield!
    @IBOutlet weak var singerTextField: HighlightingTextfield!
    @IBOutlet weak var songNumberTextField: HighlightingTextfield!
    @IBOutlet weak var brandPickerButton: UIButton!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    weak var delegate: AddSongViewDelegate?
    private var viewModel: AddSongViewModel
    private var disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }
    
    
    // MARK: - Overrides
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
            
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            traitCollection.performAsCurrent {
                brandPickerButton.layer.borderColor = ColorSet.brandPopUpButtonBorderColor.cgColor
            }
        }
    }
    
    
    // MARK: - Initializers
    
    init(_ viewModel: AddSongViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    init?(_ coder: NSCoder, _ viewModel: AddSongViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Setups
    
    private func setup() {
        setupView()
    }
    
    private func setupView() {
        setupExitButton()
        setupConfirmButton()
        setupNotificationView()
        setupSongTitleTextField()
        setupSingerTextField()
        setupSongNumberTextField()
        setupBrandPickerButton()
        setupContentScrollView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupExitButton() {
        exitButton.makeAsCircle()
        exitButton.setExitButtonShadow()
    }
    
    private func setupConfirmButton() {
        confirmButton.layer.cornerRadius = 12
        confirmButton.hero.modifiers = [.translate(y: 20), .fade]
    }
    
    private func setupNotificationView() {
        notificationView.layer.cornerRadius = 12
    }
    
    private func setupSongTitleTextField() {
        songTitleTextField.setLeftPadding(width: 12)
        songTitleTextField.setRightPadding(width: 12)
    }
    
    private func setupSingerTextField() {
        singerTextField.setLeftPadding(width: 12)
        singerTextField.setRightPadding(width: 12)
    }
    
    private func setupSongNumberTextField() {
        songNumberTextField.setLeftPadding(width: 12)
        songNumberTextField.setRightPadding(width: 12)
    }
    
    private func setupBrandPickerButton() {
        brandPickerButton.layer.cornerRadius = 12
        brandPickerButton.layer.borderWidth = 1
        brandPickerButton.layer.borderColor = ColorSet.brandPopUpButtonBorderColor.cgColor
    }
    
    private func setupContentScrollView() {
        contentScrollView.delegate = self
    }
    
    
    // MARK: - Binds
    
    private func bind() {
        bindInputs()
        bindOutputs()
    }
    
    private func bindInputs() {
        songTitleTextField
            .rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.input.songTitle)
            .disposed(by: disposeBag)
        
        songTitleTextField
            .rx.controlEvent(.editingDidEndOnExit)
            .asDriver()
            .drive(with: self, onNext: { vc,_ in
                vc.singerTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
        
        singerTextField
            .rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.input.singerName)
            .disposed(by: disposeBag)
        
        singerTextField
            .rx.controlEvent(.editingDidEndOnExit)
            .asDriver()
            .drive(with: self, onNext: { vc,_ in
                vc.songNumberTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
        
        songNumberTextField
            .rx.text
            .orEmpty
            .distinctUntilChanged()
            .bind(to: viewModel.input.songNumber)
            .disposed(by: disposeBag)
        
        songNumberTextField
            .rx.controlEvent(.editingDidEndOnExit)
            .asDriver()
            .drive(with: self, onNext: { vc,_ in
                vc.view.endEditing(true)
            }).disposed(by: disposeBag)
        
        contentView
            .rx.tapGesture()
            .when(.recognized)
            .bind(with: self, onNext: { vc,_ in
                vc.view.endEditing(true)
            }).disposed(by: disposeBag)
        
        brandPickerButton
            .rx.tap
            .bind(to: viewModel.input.tapBrandPickerButton)
            .disposed(by: disposeBag)
        
        exitButton
            .rx.tap
            .bind(to: viewModel.input.tapExitButton)
            .disposed(by: disposeBag)
        
        confirmButton
            .rx.tap
            .bind(to: viewModel.input.tapConfirmButton)
            .disposed(by: disposeBag)
    }
    
    private func bindOutputs() {
        viewModel.output
            .confirmButtonActiveState
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .never())
            .drive(with: self, onNext: { vc, isAllTextFieldFilled in
                if isAllTextFieldFilled {
                    vc.confirmButton.isUserInteractionEnabled = true
                    vc.confirmButton.backgroundColor = ColorSet.addFolderButtonBackgroundColor
                    vc.confirmButton.setTitleColor(ColorSet.addFolderButtonForegroundColor, for: .normal)
                } else {
                    vc.confirmButton.isUserInteractionEnabled = false
                    vc.confirmButton.backgroundColor = ColorSet.addFolderButtonDisabledBackgroundColor
                    vc.confirmButton.setTitleColor(ColorSet.disabledTextColor, for: .normal)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output
            .showingBrandPickerView
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] in
                self?.showBrandPickerVC()
            })
            .disposed(by: disposeBag)
        
        viewModel.output
            .dismiss
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.output
            .karaokeBrand
            .distinctUntilChanged()
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] brand in
                self?.brandPickerButton.setTitle(brand.localizedString, for: .normal)
            })
            .disposed(by: disposeBag)
        
        viewModel.output
            .succeedToAddSong
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] in
                self?.delegate?.didSongAdded?()
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - Methods
    
    private func showBrandPickerVC() {
        let storyboard = UIStoryboard(name: "Archive", bundle: nil)
        let brandPickerVC = storyboard.instantiateViewController(identifier: "karaokeBrandPickerStoryboard", creator: { coder -> KaraokeBrandPickerViewController in
            let viewModel = KaraokeBrandPickerViewModel()
            return .init(coder, viewModel) ?? KaraokeBrandPickerViewController(viewModel)
        })
        
        brandPickerVC.modalPresentationStyle = .popover
        brandPickerVC.preferredContentSize = CGSize(width: 140, height: 87) // two 44height of cells - 1height of separator height
        brandPickerVC.popoverPresentationController?.permittedArrowDirections = .right
        brandPickerVC.popoverPresentationController?.sourceRect = brandPickerButton.bounds
        brandPickerVC.popoverPresentationController?.sourceView = brandPickerButton
        brandPickerVC.presentationController?.delegate = self
        brandPickerVC.delegate = self
        present(brandPickerVC, animated: true)
    }
    
    @objc
    private func keyboardWillShow(_ sender: Notification) {
        view.frame.origin.y = -150
    }
    
    @objc
    private func keyboardWillHide(_ sender: Notification) {
        view.frame.origin.y = 0
    }
    
    @objc
    private func didTapDoneButton(_ sender: Any) {
        view.endEditing(true)
    }
}


// MARK: - Extensions

extension AddSongViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension AddSongViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension AddSongViewController: BrandPickerViewDelegaet {
    func didBrandSelected(_ selectedBrand: KaraokeBrand) {
        Observable.just(selectedBrand)
            .bind(to: viewModel.input.changeKaraokeBrand)
            .disposed(by: disposeBag)
    }
}
