//
//  BrandPickerViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2022/01/05.
//

import UIKit

import RxSwift
import RxCocoa

protocol BrandPickerViewDelegaet: AnyObject {
    func didBrandSelected(_ selectedBrand: KaraokeBrand)
}

class KaraokeBrandPickerViewController: UIViewController {

    // MARK: - Declaration
    @IBOutlet weak var brandPickerTableView: UITableView!
    
    weak var delegate: BrandPickerViewDelegaet?
    private let viewModel = KaraokeBrandPickerViewModel()
    private var disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        bind()
    }
    
    // MARK: - Intializations
    private func setupView() {
        setupBrandPickerTableView()
    }
    
    private func bind() {
        bindBrandPickerTableView()
    }
    
    // MARK: - Setups
    private func setupBrandPickerTableView() {
        brandPickerTableView.tableFooterView = UIView()
        brandPickerTableView.separatorStyle = .singleLine
        brandPickerTableView.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        brandPickerTableView.showsVerticalScrollIndicator = false
        brandPickerTableView.isScrollEnabled = false
        
        let nibName = UINib(nibName: "KaraokeBrandPickerTableViewCell", bundle: nil)
        brandPickerTableView.register(nibName, forCellReuseIdentifier: KaraokeBrandPickerTableViewCell.identifier)
        brandPickerTableView.dataSource = self
        brandPickerTableView.delegate = self
    }
    
    // MARK: - Bidns
    private func bindBrandPickerTableView() {
        brandPickerTableView.rx.itemSelected
            .asDriver()
            .drive(with: self, onNext: { vc,indexPath in
                vc.delegate?.didBrandSelected(vc.viewModel.brandForRowAt(indexPath))
                vc.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
}

// MARK: Extensions
extension KaraokeBrandPickerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: KaraokeBrandPickerTableViewCell.identifier, for: indexPath) as? KaraokeBrandPickerTableViewCell else {
            return UITableViewCell()
        }
        
        cell.brandNameLabel.text = viewModel.brandForRowAt(indexPath).localizedString
        
        return cell
    }
}
