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
  
  
  // MARK: Types
  
  typealias ViewModel = SettingViewModel
  
  
  // MARK: - Properties
  
  static let identifier = R.storyboard.setting.settingStoryboard.identifier
  
  private var viewModel: ViewModel
  @IBOutlet weak var exitButton: UIButton!
  @IBOutlet weak var settingItemTableView: UITableView!
  
  
  // MARK: - Initializers
  
  required init(_ viewModel: ViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    dismiss(animated: true)
  }
  
  required init?(_ coder: NSCoder, _ viewModel: ViewModel) {
    self.viewModel = viewModel
    super.init(coder: coder)
  }
  
  required init?(coder: NSCoder) {
    fatalError("ViewModel has not been implemented")
  }
  
  
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
    setupSettingItemTableView()
  }
  
  
  // MARK: - Binds
  
  private func bind() {
    bindInputs()
    bindOutputs()
  }
  
  private func bindInputs() {
    exitButton.rx.tap
      .bind(to: viewModel.input.tapExitButton)
      .disposed(by: disposeBag)
  }
  
  private func bindOutputs() {
    viewModel.output.dismiss
      .asDriver(onErrorDriveWith: .never())
      .drive(with: self, onNext: { vc, _ in
        vc.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
    
    viewModel.output.settingItems
      .bind(to: settingItemTableView.rx.items(cellIdentifier: SettingItemTableViewCell.identifier, cellType: SettingItemTableViewCell.self)) { index, item, cell in
        cell.configure(item: item)
        cell.itemSelectAction = { [weak self] in
          guard let self = self else { return }
          item.action(vc: self)
        }
      }
      .disposed(by: disposeBag)
  }
  
  private func setupSettingItemTableView() {
    registerEtcTableCell()
    settingItemTableView.layer.cornerRadius = 16
    settingItemTableView.tableFooterView = UIView()
    settingItemTableView.isScrollEnabled = false
    settingItemTableView.separatorStyle = .none
    settingItemTableView.contentInset = .init(top: 12, left: 0, bottom: 12, right: 0)
  }
  
  private func registerEtcTableCell() {
    let nibName = UINib(nibName: R.nib.settingItemTableViewCell.name, bundle: nil)
    settingItemTableView.register(nibName, forCellReuseIdentifier: SettingItemTableViewCell.identifier)
  }
}
