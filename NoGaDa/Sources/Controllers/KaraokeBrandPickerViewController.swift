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

    
    // MARK: - Properties
    
    @IBOutlet weak var brandPickerTableView: UITableView!
    
    weak var delegate: BrandPickerViewDelegaet?
    private let viewModel: KaraokeBrandPickerViewModel
    private var disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }

    
    // MARK: - Intializations
    
    init(_ viewModel: KaraokeBrandPickerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    init?(_ coder: NSCoder, _ viewModel: KaraokeBrandPickerViewModel) {
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
        setupBrandPickerTableView()
    }
    
    private func setupBrandPickerTableView() {
        brandPickerTableView.tableFooterView = UIView()
        brandPickerTableView.separatorStyle = .singleLine
        brandPickerTableView.separatorInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        brandPickerTableView.showsVerticalScrollIndicator = false
        brandPickerTableView.isScrollEnabled = false
        
        let nibName = UINib(nibName: R.nib.karaokeBrandPickerTableViewCell.name, bundle: nil)
        brandPickerTableView.register(nibName, forCellReuseIdentifier: KaraokeBrandPickerTableViewCell.identifier)
    }
    
    
    // MARK: - Bidns
    
    private func bind() {
        bindInputs()
        bindOutputs()
    }
    
    private func bindInputs() {
        brandPickerTableView
            .rx.itemSelected
            .bind(to: viewModel.input.tapKaraokeBrandItem)
            .disposed(by: disposeBag)
    }
    
    private func bindOutputs() {
        viewModel.output
            .karaokeBrands
            .bind(to: brandPickerTableView.rx.items(cellIdentifier: KaraokeBrandPickerTableViewCell.identifier, cellType: KaraokeBrandPickerTableViewCell.self)) { index, brand, cell in
                cell.brandNameLabel.text = brand.localizedString
            }
            .disposed(by: disposeBag)
        
        viewModel.output
            .didTapKaraokeBrandItem
            .asDriver(onErrorDriveWith: .never())
            .drive(with: self, onNext: { vc, brand in
                vc.delegate?.didBrandSelected(brand)
            })
            .disposed(by: disposeBag)
        
        viewModel.output
            .dismiss
            .asDriver(onErrorDriveWith: .never())
            .drive(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
