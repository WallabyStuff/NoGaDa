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
    
    // MARK: - Declaration
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
    public var viewModel: AddSongViewModel?
    private var disposeBag = DisposeBag()
    private var selectedBrand: KaraokeBrand = .tj
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupInstance()
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
    private func setupData() {
        if viewModel == nil {
            dismiss(animated: true, completion: nil)
            return
        }
    }
    
    private func setupView() {
        // Exit button
        exitButton.makeAsCircle()
        exitButton.setExitButtonShadow()
        
        // Confirm button
        confirmButton.layer.cornerRadius = 12
        confirmButton.hero.modifiers = [.translate(y: 20), .fade]
        
        // Notification view
        notificationView.layer.cornerRadius = 12
        
        // Song title textfield
        songTitleTextField.setLeftPadding(width: 12)
        songTitleTextField.setRightPadding(width: 12)
        
        // Song author textfield
        singerTextField.setLeftPadding(width: 12)
        singerTextField.setRightPadding(width: 12)
        
        // Song number textfield
        songNumberTextField.setLeftPadding(width: 12)
        songNumberTextField.setRightPadding(width: 12)
        
        // Brand picker Button
        brandPickerButton.layer.cornerRadius = 12
        brandPickerButton.layer.borderWidth = 1
        brandPickerButton.layer.borderColor = ColorSet.brandPopUpButtonBorderColor.cgColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupInstance() {
        // Content scrollView
        contentScrollView.delegate = self
    }
    
    private func bind() {
        // Exit button
        exitButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        // Song title textfield
        songTitleTextField.rx.controlEvent(.editingDidEndOnExit)
            .asDriver()
            .drive(with: self, onNext: { vc,_ in
                vc.singerTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
        
        // Singer textfield
        singerTextField.rx.controlEvent(.editingDidEndOnExit)
            .asDriver()
            .drive(with: self, onNext: { vc,_ in
                vc.songNumberTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
        
        // Song number textfield
        songNumberTextField.rx.controlEvent(.editingDidEndOnExit)
            .asDriver()
            .drive(with: self, onNext: { vc,_ in
                vc.view.endEditing(true)
            }).disposed(by: disposeBag)
        
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
        
        // ContentView tap action
        contentView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self, onNext: { vc,_ in
                vc.view.endEditing(true)
            }).disposed(by: disposeBag)
        
        // Confirm button tap action
        confirmButton.rx.tap
            .asDriver()
            .drive(with: self, onNext: { vc,_ in
                vc.addSong()
            }).disposed(by: disposeBag)
        
        // Brand picker button tap action
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

        viewModel?.addSong(title: songTitle,
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
        guard let brandPickerVC = storyboard?.instantiateViewController(withIdentifier: "karaokeBrandPickerStoryboard") as? KaraokeBrandPickerViewController else { return }
        
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
