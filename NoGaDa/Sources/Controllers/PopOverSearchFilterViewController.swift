//
//  PopOverSearchFilterViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/21.
//

import UIKit

import RxSwift
import RxCocoa

protocol PopOverSearchFilterViewDelegate: AnyObject {
    func popOverSearchFilterView(didTapApply: Bool)
}

class PopOverSearchFilterViewController: BaseViewController, ViewModelInjectable {
        
    
    // MARK: - Properties
    
    typealias ViewModel = PopOverSearchFilterViewModel
    static let identifier = R.storyboard.search.popOverSearchFilterStoryboard.identifier
    
    @IBOutlet weak var searchFilterTableView: UITableView!
    @IBOutlet weak var applyButton: UIButton!
    
    weak var delegate: PopOverSearchFilterViewDelegate?
    var viewModel: PopOverSearchFilterViewModel
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }

    
    // MARK: - Initializers
    
    required init(_ viewModel: PopOverSearchFilterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        dismiss(animated: true)
    }
    
    required init?(_ coder: NSCoder, _ viewModel: PopOverSearchFilterViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("ViewModel has not been implemented")
    }
    
    
    // MARK: - Setups
    
    private func setupView() {
        setupSearchFilterTableView()
        setupApplayButton()
    }
    
    private func setupSearchFilterTableView() {
        registerSearchFilterTableCell()
        searchFilterTableView.tableFooterView = UIView()
        searchFilterTableView.separatorInset  = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 80)
        searchFilterTableView.backgroundColor = .white
    }
    
    private func registerSearchFilterTableCell() {
        let nibName = UINib(nibName: R.nib.searchFilterTableViewCell.name, bundle: nil)
        searchFilterTableView.register(nibName, forCellReuseIdentifier: SearchFilterTableViewCell.identifier)
    }
    
    private func setupApplayButton() {
        applyButton.layer.cornerRadius = 12
    }
    
    
    // MARK: - Binds
    
    private func bind() {
        bindApplyButton()
        bindSearchFilterTableView()
    }
    
    private func bindApplyButton() {
        applyButton.rx.tap
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.delegate?.popOverSearchFilterView(didTapApply: true)
                vc.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    private func bindSearchFilterTableView() {
        viewModel.searchFilterItem
            .bind(to: searchFilterTableView.rx.items(cellIdentifier: SearchFilterTableViewCell.identifier,
                                                     cellType: SearchFilterTableViewCell.self)) { [weak self] index, item, cell in
                guard let self = self else { return }
                
                cell.titleLabel.text = item.title
                cell.filterSwitch.isOn = item.state
                cell.filterSwitch.rx.controlEvent(.valueChanged)
                    .subscribe(with: self, onNext: { vc, _ in
                        UserDefaults.standard.set(!item.state, forKey: item.userDefaultKey)
                    }).disposed(by: self.disposeBag)
            }.disposed(by: disposeBag)
    }
}
