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

    // MARK: - Declaration
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var contactUsBoxView: UIView!
    @IBOutlet weak var catactUsIconBoxView: UIView!
    @IBOutlet weak var iconResourceCollectionView: UICollectionView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        initInstance()
        initEventListener()
    }
    
    // MARK: - Initialization
    private func initView() {
        // ContactUs Box View
        contactUsBoxView.layer.cornerRadius = 20
        contactUsBoxView.makeAsSettingGroupView()
        catactUsIconBoxView.layer.cornerRadius = 12
        
        // Icon resource CollectionView
        iconResourceCollectionView.contentInset = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 28)
    }
    
    private func initInstance() {
        // Icon resource CollectionView
        let iconResourceNibName = UINib(nibName: "IconResourceCollectionViewCell", bundle: nil)
        iconResourceCollectionView.register(iconResourceNibName, forCellWithReuseIdentifier: "iconResourceCollectionCell")
        iconResourceCollectionView.dataSource = self
        iconResourceCollectionView.delegate = self
    }
    
    private func initEventListener() {
        // Exit button Tap Action
        exitButton.rx.tap
            .bind(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
        
        // Contact us Tap Action
        contactUsBoxView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self, onNext: { vc, _ in
                if MFMailComposeViewController.canSendMail() {
                    let composeVC = MFMailComposeViewController()
                    
                    composeVC.setToRecipients(["avocado.34.131@gmail.com"])
                    composeVC.setSubject("문의")
                    composeVC.setMessageBody("", isHTML: false)
                    
                    vc.present(composeVC, animated: true, completion: nil)
                } else {
                    print("can't send an email because some reason")
                }
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Method
}

// MARK: Extension
extension CreditViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ResourceItem.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let resourceCell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconResourceCollectionCell", for: indexPath) as? IconResourceCollectionViewCell else { return UICollectionViewCell() }
        
        let resourceItem                    = ResourceItem.allCases[indexPath.row]
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
