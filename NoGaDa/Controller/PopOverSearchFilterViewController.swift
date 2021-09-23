//
//  PopOverSearchFilterViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/21.
//

import UIKit

import RxSwift
import RxCocoa

class PopOverSearchFilterViewController: UIViewController {

    // MARK: - Declaration
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var filterItemTableView: UITableView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        initInstance()
        initEventListener()
    }
    

    // MARK: - Initialization
    private func initView() {
        // filter item TableView
        filterItemTableView.tableFooterView = UIView()
        filterItemTableView.separatorInset  = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 80)
    }
    
    private func initInstance() {
        // Filter item Tableview
        let searchFilterCellNibName     = UINib(nibName: "SearchFilterTableViewCell", bundle: nil)
        filterItemTableView.register(searchFilterCellNibName, forCellReuseIdentifier: "searchFilterTableCell")
        filterItemTableView.dataSource  = self
        filterItemTableView.delegate    = self
        
    }
    
    private func initEventListener() {
        
    }
    
    
    // MARK: - Method
}

// MARK: - Extension
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
