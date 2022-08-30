//
//  SettingViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/29.
//

import UIKit

import RxSwift
import RxCocoa

class SettingViewController: BaseViewController {
  
  
  // MARK: - Properties
  
  static let identifier = R.storyboard.setting.settingStoryboard.identifier
  
  @IBOutlet weak var exitButton: UIButton!
  @IBOutlet weak var searchFilterGroupView: UIView!
  @IBOutlet weak var etcGroupView: UIView!
  @IBOutlet weak var searchFilterTableView: UITableView!
  @IBOutlet weak var etcTableView: UITableView!
  
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
  
  // MARK: - Setups
  
  private func setup() {
    setupView()
  }
  
  private func setupView() {
    setupSearchFilterGroupView()
    setupEtcGroupView()
  }
  
  private func bind() {
    bindExitButton()
  }
  
  private func setupSearchFilterGroupView() {
    registerSearchFilterTableCell()
    searchFilterGroupView.makeAsSettingGroupView()
    searchFilterTableView.layer.cornerRadius = 20
    searchFilterTableView.tableFooterView = UIView()
    searchFilterTableView.isScrollEnabled = false
    searchFilterTableView.separatorColor = ColorSet.settingItemSeparatorColor
    searchFilterTableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 80)
    searchFilterTableView.layer.cornerRadius = 20
    searchFilterTableView.dataSource = self
    searchFilterTableView.delegate = self
  }
  
  private func registerSearchFilterTableCell() {
    let nibName = UINib(nibName: R.nib.searchFilterTableViewCell.name, bundle: nil)
    searchFilterTableView.register(nibName, forCellReuseIdentifier: SearchFilterTableViewCell.identifier)
  }
  
  private func setupEtcGroupView() {
    registerEtcTableCell()
    etcGroupView.makeAsSettingGroupView()
    etcTableView.layer.cornerRadius = 20
    etcTableView.tableFooterView = UIView()
    etcTableView.isScrollEnabled = false
    etcTableView.separatorColor = ColorSet.settingItemSeparatorColor
    etcTableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 64)
    etcTableView.dataSource = self
    etcTableView.delegate = self
  }
  
  private func registerEtcTableCell() {
    let nibName = UINib(nibName: R.nib.settingEtcTableViewCell.name, bundle: nil)
    etcTableView.register(nibName, forCellReuseIdentifier: SettingEtcTableViewCell.identifier)
  }
  
  
  // MARK: - Binds
  
  private func bindExitButton() {
    exitButton.rx.tap
      .asDriver()
      .drive(with: self, onNext: { vc, _ in
        vc.dismiss(animated: true, completion: nil)
      }).disposed(by: disposeBag)
  }
}


// MARK: - Extensions

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
      guard let filterItemCell = tableView.dequeueReusableCell(withIdentifier: SearchFilterTableViewCell.identifier) as? SearchFilterTableViewCell else {
        return UITableViewCell()
      }
      
      let filterItem = SearchFilterItem.allCases[indexPath.row]
      
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
      guard let etcItemCell = tableView.dequeueReusableCell(withIdentifier: SettingEtcTableViewCell.identifier) as? SettingEtcTableViewCell else {
        return UITableViewCell()
      }
      
      let etcItem = SettingEtcItem.allCases[indexPath.row]
      
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
