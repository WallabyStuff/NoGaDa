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


protocol AddSongViewDelegate: AnyObject {
    func didSongUpdated()
}

class AddSongViewController: UIViewController {
    
    // MARK: - Declaration
    weak var delegate: AddSongViewDelegate?
    private var disposeBag = DisposeBag()
    private let addSongViewModel = AddSongViewModel()
    public var currentFolderId: String?
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var songTitleTextField: HighlightingTextfield!
    @IBOutlet weak var singerTextField: HighlightingTextfield!
    @IBOutlet weak var songNumberTextField: HighlightingTextfield!
    @IBOutlet weak var brandPickerView: UIPickerView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureData()
        initView()
        initInstance()
        initEventListener()
    }
    
    // MARK: - Override
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Initializer
    private func configureData() {
        if currentFolderId == nil {
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func initView() {
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
        
        // Brand picker view
        brandPickerView.layer.borderWidth = 1
        brandPickerView.layer.borderColor = ColorSet.brandPopUpButtonBorderColor.cgColor
        brandPickerView.layer.cornerRadius = 12
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func initInstance() {
        // Brand  picker view
        brandPickerView.dataSource = self
        brandPickerView.delegate = self
        
        // Content scrollView
        contentScrollView.delegate = self
    }
    
    private func initEventListener() {
        // Exit button
        exitButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        // Song title textfield
        songTitleTextField.rx.controlEvent(.editingDidEndOnExit)
            .bind(with: self, onNext: { vc,_ in
                vc.singerTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
        
        // Song composer textfield
        singerTextField.rx.controlEvent(.editingDidEndOnExit)
            .bind(with: self, onNext: { vc,_ in
                vc.songNumberTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
        
        // Song number textfield
        songNumberTextField.rx.controlEvent(.editingDidEndOnExit)
            .bind(with: self, onNext: { vc,_ in
                vc.view.endEditing(true)
            }).disposed(by: disposeBag)
        
        let songTitleOb = songTitleTextField.rx.text.orEmpty.asDriver().map { !$0.isEmpty }
        let songComposerOb = singerTextField.rx.text.orEmpty.asDriver().map { !$0.isEmpty }
        
        Driver.combineLatest(songTitleOb, songComposerOb, resultSelector: { $0 && $1 })
            .drive(with: self, onNext: { vc, isAllTextFieldFilled in
                if isAllTextFieldFilled {
                    vc.confirmButton.backgroundColor = ColorSet.addFolderButtonBackgroundColor
                    vc.confirmButton.setTitleColor(ColorSet.textColor, for: .normal)
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
            .bind(with: self, onNext: { vc,_ in
                vc.addSong()
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Method
    private func addSong() {
        let songTitle = songTitleTextField.text ?? ""
        let singer = singerTextField.text ?? ""
        let songNumber = songNumberTextField.text ?? ""
        
        addSongViewModel.addSong(title: songTitle,
                                 singer: singer,
                                 songNumber: songNumber,
                                 brand: selectedBrand(),
                                 to: currentFolderId!)
            .subscribe(onCompleted: { [weak self] in
                // Success to add a new song
                self?.delegate?.didSongUpdated()
                self?.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    private func selectedBrand() -> KaraokeBrand {
        let selectedRow = brandPickerView.selectedRow(inComponent: 0)
        return KaraokeBrand.allCases[selectedRow]
    }
    
    @objc
    private func keyboardWillShow(_ sender: Notification) {
        view.frame.origin.y = -150
    }
    
    @objc
    private func keyboardWillHide(_ sender: Notification) {
        view.frame.origin.y = 0
    }
}

// MARK: - Extension
extension AddSongViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return addSongViewModel.numberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return addSongViewModel.numberOfRowsInComponent
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.textAlignment = .center
        pickerLabel.textColor = ColorSet.textColor
        pickerLabel.font = UIFont.boldSystemFont(ofSize: 15)
        pickerLabel.text = addSongViewModel.titleForRowAt(row)
        
        return pickerLabel
    }
}

extension AddSongViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension AddSongViewController: UITextFieldDelegate {
    
}
