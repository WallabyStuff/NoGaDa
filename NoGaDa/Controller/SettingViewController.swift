//
//  SettingViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/29.
//

import UIKit

import RxSwift
import RxCocoa

class SettingViewController: UIViewController {

    // MARK: - Declaration
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var searchFilterGroupView: UIView!
    @IBOutlet weak var etcGroupView: UIView!
    @IBOutlet weak var searchFilterTableView: UITableView!
    @IBOutlet weak var etcTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        initInstance()
        initEventListener()
    }
    
    // MARK: - Intitialization
    private func initView() {
        // Search filter group View
        searchFilterGroupView.makeAsSettingGroupView()
        searchFilterTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        searchFilterTableView.layer.cornerRadius = 20
        searchFilterTableView.tableFooterView = UIView()
        
        // Etc group View
        etcGroupView.makeAsSettingGroupView()
        etcTableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        etcTableView.layer.cornerRadius = 20
        etcTableView.tableFooterView = UIView()
    }
    
    private func initInstance() {
        // Search filter TableView
        let searchFilterCellNibName = UINib(nibName: "SearchFilterTableViewCell", bundle: nil)
        searchFilterTableView.register(searchFilterCellNibName, forCellReuseIdentifier: "searchFilterTableCell")
        searchFilterTableView.layer.cornerRadius = 20
        searchFilterTableView.dataSource = self
        searchFilterTableView.delegate = self
        
        // Etc TableView
        let settingEtcCellNibName = UINib(nibName: "SettingEtcTableViewCell", bundle: nil)
        etcTableView.register(settingEtcCellNibName, forCellReuseIdentifier: "settingEtcTableCell")
        etcTableView.dataSource = self
        etcTableView.delegate = self
    }
    
    private func initEventListener() {
        // ExitButton Tap Action
        exitButton.rx.tap
            .bind(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Method
}

// MARK: - Extension
extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case searchFilterTableView:
            return SearchFilterItem.allCases.count
        case etcTableView:
            return SettingEtcItem.allCases.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case searchFilterTableView:
            guard let filterItemCell = tableView.dequeueReusableCell(withIdentifier: "searchFilterTableCell") as? SearchFilterTableViewCell else { return UITableViewCell() }
            
            let filterItem = SearchFilterItem.allCases[indexPath.row]
            
            filterItemCell.selectionStyle = .none
            filterItemCell.contentView.backgroundColor = ColorSet.settingGroupBackgroundColor
            filterItemCell.titleLabel.textColor = ColorSet.textColor
            filterItemCell.titleLabel.text = filterItem.title
            filterItemCell.filterSwitch.isOn    = filterItem.state
            filterItemCell.filterSwitch.rx.controlEvent(.valueChanged)
                .subscribe(with: self, onNext: { vc, _ in
                    UserDefaults.standard.set(!filterItem.state, forKey: filterItem.userDefaultKey)
                }).disposed(by: disposeBag)
            
            return filterItemCell
        case etcTableView:
            guard let etcItemCell = tableView.dequeueReusableCell(withIdentifier: "settingEtcTableCell") as? SettingEtcTableViewCell else { return UITableViewCell() }
            
            let etcItem = SettingEtcItem.allCases[indexPath.row]
            
            etcItemCell.selectionStyle = .none
            etcItemCell.titleLabel.text = etcItem.title
            etcItemCell.iconImageView.image = etcItem.icon
            etcItemCell.rx.tapGesture()
                .when(.recognized)
                .bind(with: self, onNext: { vc, _ in
                    etcItem.action(vc: vc)
                }).disposed(by: disposeBag)
            
            return etcItemCell
        default:
            return UITableViewCell()
        }
    }
}
