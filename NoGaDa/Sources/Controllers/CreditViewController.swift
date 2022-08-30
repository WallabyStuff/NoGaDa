//
//  CreditViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/29.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture
import MessageUI

class CreditViewController: UIViewController {
  
  
  // MARK: - Properties
  
  @IBOutlet weak var exitButton: UIButton!
  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var contentScrollView: UIScrollView!
  @IBOutlet weak var contactUsBoxView: UIView!
  @IBOutlet weak var catactUsIconBoxView: UIView!
  @IBOutlet weak var iconResourceCollectionView: UICollectionView!
  @IBOutlet weak var contactTextView: UITextView!
  
  private var disposeBag = DisposeBag()
  private var viewModel: CreditViewModel
  
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
  
  // MARK: - Initializers
  
  init(_ viewModel: CreditViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  init?(_ coder: NSCoder, _ viewModel: CreditViewModel) {
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
    setupHeaderLabel()
    setupContactUsBoxView()
    setupIconResourceCollectionView()
    setupContactTextView()
  }
  
  private func setupHeaderLabel() {
    headerLabel.text = "노가다\n노래방 가서 다 부를거야\n\nVersion \(viewModel.appVersion)"
  }
  
  private func setupContactUsBoxView() {
    contactUsBoxView.layer.cornerRadius = 20
    contactUsBoxView.makeAsSettingGroupView()
    catactUsIconBoxView.layer.cornerRadius = 12
  }
  
  private func setupIconResourceCollectionView() {
    registerIconResourceCollectionCell()
    iconResourceCollectionView.contentInset = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 28)
  }
  
  private func registerIconResourceCollectionCell() {
    let nibName = UINib(nibName: R.nib.iconResourceCollectionViewCell.name, bundle: nil)
    iconResourceCollectionView.register(nibName, forCellWithReuseIdentifier: IconResourceCollectionViewCell.identifier)
  }
  
  private func setupContactTextView() {
    contactTextView.dataDetectorTypes = .all
  }
  
  
  // MARK: Binds
  
  private func bind() {
    bindInputs()
    bindOutputs()
  }
  
  private func bindInputs() {
    exitButton
      .rx.tap
      .bind(to: viewModel.input.tapExitButton)
      .disposed(by: disposeBag)
    
    contactUsBoxView
      .rx.tapGesture()
      .when(.recognized)
      .map { _ in }
      .bind(to: viewModel.input.tapContactbutton)
      .disposed(by: disposeBag)
  }
  
  private func bindOutputs() {
    viewModel.output.dismiss
      .asDriver(onErrorDriveWith: .never())
      .drive(onNext: { [weak self] in
        self?.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
    
    viewModel.output.showingMailComposeVC
      .asDriver(onErrorDriveWith: .never())
      .drive(with: self, onNext: { vc, mailInfo  in
        if MFMailComposeViewController.canSendMail() {
          let composeVC = MFMailComposeViewController()
          composeVC.setToRecipients(mailInfo.recipients)
          composeVC.setSubject(mailInfo.subject)
          composeVC.setMessageBody("", isHTML: false)
          vc.present(composeVC, animated: true, completion: nil)
        } else {
          print("can't send an email because of some reason")
        }
      })
      .disposed(by: disposeBag)
    
    viewModel.output.iconResources
      .bind(to: iconResourceCollectionView.rx.items(cellIdentifier: IconResourceCollectionViewCell.identifier, cellType: IconResourceCollectionViewCell.self)) { [weak self] index, item, cell in
        guard let self = self else { return }
        cell.descriptionLabel.text = item.description
        cell.iconImageView.image = item.image
        cell.rx.tapGesture()
          .when(.recognized)
          .bind(with: self, onNext: { vc, _ in
            item.openLink(vc: vc)
          }).disposed(by: self.disposeBag)
      }
      .disposed(by: disposeBag)
  }
}
