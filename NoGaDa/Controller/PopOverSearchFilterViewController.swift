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

class PopOverSearchFilterViewController: UIViewController {

    // MARK: - Declaration
    @IBOutlet weak var filterItemTableView: UITableView!
    @IBOutlet weak var applyButton: UIButton!
    
    weak var delegate: PopOverSearchFilterViewDelegate?
    private var disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupInstance()
        bind()
    }

    // MARK: - Initializers
    private func setupView() {
        // filter item TableView
        filterItemTableView.tableFooterView = UIView()
        filterItemTableView.separatorInset  = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 80)
        filterItemTableView.backgroundColor = .white
    }
    
    private func setupInstance() {
        // Filter item Tableview
        let searchFilterCellNibName     = UINib(nibName: "SearchFilterTableViewCell", bundle: nil)
        filterItemTableView.register(searchFilterCellNibName, forCellReuseIdentifier: "searchFilterTableCell")
        filterItemTableView.dataSource  = self
        filterItemTableView.delegate    = self
        
        // Apply Button
        applyButton.layer.cornerRadius = 12
    }
    
    private func bind() {
        // Apply Button Tap Action
        applyButton.rx.tap
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.delegate?.popOverSearchFilterView(didTapApply: true)
                vc.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    
    // MARK: - Methods
}

// MARK: - Extensions
extension PopOverSearchFilterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchFilterItem.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let filterItemCell = tableView.dequeueReusableCell(withIdentifier: "searchFilterTableCell") as? SearchFilterTableViewCell else { return UITableViewCell() }
        
        let filterItem = SearchFilterItem.allCases[indexPath.row]
        
        filterItemCell.titleLabel.text      = filterItem.title
        filterItemCell.filterSwitch.isOn    = filterItem.state
        filterItemCell.filterSwitch.rx.controlEvent(.valueChanged)
            .subscribe(with: self, onNext: { vc, _ in
                UserDefaults.standard.set(!filterItem.state, forKey: filterItem.userDefaultKey)
            }).disposed(by: disposeBag)
        
        return filterItemCell
    }
}
