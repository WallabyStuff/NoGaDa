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
    private var selectedBrand: KaraokeBrand = .tj
    
    
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
    
    private func bind() {
        bindExitButton()
        bindSongTitleTextField()
        bindSingerTextField()
        bindSongNumberTextField()
        bindConfirmButtonActivateState()
        bindContentView()
        bindConfirmButton()
        bindBrandPickerButton()
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
    
    private func bindExitButton() {
        exitButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    private func bindSongTitleTextField() {
        songTitleTextField.rx.controlEvent(.editingDidEndOnExit)
            .asDriver()
            .drive(with: self, onNext: { vc,_ in
                vc.singerTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
    }
    
    private func bindSingerTextField() {
        singerTextField.rx.controlEvent(.editingDidEndOnExit)
            .asDriver()
            .drive(with: self, onNext: { vc,_ in
                vc.songNumberTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
    }
    
    private func bindSongNumberTextField() {
        songNumberTextField.rx.controlEvent(.editingDidEndOnExit)
            .asDriver()
            .drive(with: self, onNext: { vc,_ in
                vc.view.endEditing(true)
            }).disposed(by: disposeBag)
    }
    
    private func bindConfirmButtonActivateState() {
        let songTitleOb = songTitleTextField.rx.text.orEmpty.asDriver().map { !$0.isEmpty }
        let singerOb = singerTextField.rx.text.orEmpty.asDriver().map { !$0.isEmpty }
        
        Driver.combineLatest(songTitleOb, singerOb, resultSelector: { $0 && $1 })
            .drive(with: self, onNext: { vc, isAllTextFieldFilled in
                if isAllTextFieldFilled {
                    vc.confirmButton.backgroundColor = ColorSet.addFolderButtonBackgroundColor
                    vc.confirmButton.setTitleColor(ColorSet.addFolderButtonForegroundColor, for: .normal)
                } else {
                    vc.confirmButton.backgroundColor = ColorSet.addFolderButtonDisabledBackgroundColor
                    vc.confirmButton.setTitleColor(ColorSet.disabledTextColor, for: .normal)
                }
            }).disposed(by: disposeBag)
    }
    
    private func bindContentView() {
        contentView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self, onNext: { vc,_ in
                vc.view.endEditing(true)
            }).disposed(by: disposeBag)
    }
    
    private func bindConfirmButton() {
        confirmButton.rx.tap
            .asDriver()
            .drive(with: self, onNext: { vc,_ in
                vc.addSong()
            }).disposed(by: disposeBag)
    }
    
    private func bindBrandPickerButton() {
        brandPickerButton.rx.tap
            .asDriver()
            .drive(with: self, onNext: { vc,_ in
                vc.showBrandPickerVC()
            }).disposed(by: disposeBag)
    }
    
    
    // MARK: - Methods
    
    private func addSong() {
        let songTitle = songTitleTextField.text ?? ""
        let singer = singerTextField.text ?? ""
        let songNumber = songNumberTextField.text ?? ""

        viewModel.addSong(title: songTitle,
                                 singer: singer,
                                 songNumber: songNumber,
                                 brand: selectedBrand)
            .subscribe(onCompleted: { [weak self] in
                // Success to add a new song
                self?.delegate?.didSongAdded?()
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    private func showBrandPickerVC() {
        let storyboard = UIStoryboard(name: "Archive", bundle: nil)
        guard let brandPickerVC = storyboard.instantiateViewController(withIdentifier: "karaokeBrandPickerStoryboard") as? KaraokeBrandPickerViewController else { return }
        
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
        self.selectedBrand = selectedBrand
        brandPickerButton.setTitle(selectedBrand.localizedString, for: .normal)
    }
}
