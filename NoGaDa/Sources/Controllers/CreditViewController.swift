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
    
    private func bind() {
        bindExitButton()
        bindContactUsBoxView()
    }
    
    private func setupHeaderLabel() {
        headerLabel.text = viewModel.headerText
    }
    
    private func setupContactUsBoxView() {
        contactUsBoxView.layer.cornerRadius = 20
        contactUsBoxView.makeAsSettingGroupView()
        catactUsIconBoxView.layer.cornerRadius = 12
    }
    
    private func setupIconResourceCollectionView() {
        registerIconResourceCollectionCell()
        iconResourceCollectionView.contentInset = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 28)
        iconResourceCollectionView.dataSource = self
        iconResourceCollectionView.delegate = self
    }
    
    private func registerIconResourceCollectionCell() {
        let nibName = UINib(nibName: R.nib.iconResourceCollectionViewCell.name, bundle: nil)
        iconResourceCollectionView.register(nibName, forCellWithReuseIdentifier: IconResourceCollectionViewCell.identifier)
    }
    
    private func setupContactTextView() {
        contactTextView.dataDetectorTypes = .all
    }
    
    
    // MARK: Binds
    
    private func bindExitButton() {
        exitButton.rx.tap
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    private func bindContactUsBoxView() {
        contactUsBoxView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self, onNext: { vc, _ in
                if MFMailComposeViewController.canSendMail() {
                    let composeVC = MFMailComposeViewController()
                    
                    composeVC.setToRecipients(vc.viewModel.emailRecipients)
                    composeVC.setSubject(vc.viewModel.sendEmailErrorMessage)
                    composeVC.setMessageBody("", isHTML: false)
                    
                    vc.present(composeVC, animated: true, completion: nil)
                } else {
                    print(vc.viewModel.sendEmailErrorMessage)
                }
            }).disposed(by: disposeBag)
    }
}


// MARK: Extensions

extension CreditViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfRowInSection(viewModel.sectionCount)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let resourceCell = collectionView.dequeueReusableCell(withReuseIdentifier: IconResourceCollectionViewCell.identifier, for: indexPath) as? IconResourceCollectionViewCell else { return UICollectionViewCell() }
        
        let resourceItem = viewModel.resourceItemAtIndex(indexPath)
        resourceCell.descriptionLabel.text  = resourceItem.description
        resourceCell.iconImageView.image    = resourceItem.image
        
        resourceCell.rx.tapGesture()
            .when(.recognized)
            .bind(with: self, onNext: { vc, _ in
                resourceItem.openLink(vc: vc)
            }).disposed(by: disposeBag)
        
        return resourceCell
    }
}
