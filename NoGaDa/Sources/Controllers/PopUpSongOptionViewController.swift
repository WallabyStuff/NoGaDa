//
//  PopUpSongOptionViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/12/14.
//

import UIKit

import RxSwift
import RxCocoa

@objc protocol PopUpSongOptionViewDelegate: AnyObject {
  @objc optional func didSelectedSongRemoved()
  @objc optional func didSelectedItemMoved()
}

class PopUpSongOptionViewController: UIViewController {
  
  
  // MARK: - Properties
  
  @IBOutlet weak var songThumbnailImageView: UIImageView!
  @IBOutlet weak var exitButton: UIButton!
  @IBOutlet weak var songTitleLabel: UILabel!
  @IBOutlet weak var singerLabel: UILabel!
  @IBOutlet weak var optionTableView: UITableView!
  
  weak var delegate: PopUpSongOptionViewDelegate?
  private var viewModel: PopUpSongOptionViewModel
  private var disposeBag = DisposeBag()
  private var parentVC: UIViewController
  
  public var exitButtonAction: () -> Void = {}
  private var archiveFolderFloatingPanelView: ArchiveFolderFloatingPanelView?
  
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    bind()
  }
  
  
  // MARK: - Initializers
  
  init(_ viewModel: PopUpSongOptionViewModel) {
    self.viewModel = viewModel
    self.parentVC = UIViewController()
    super.init(nibName: nil, bundle: nil)
  }
  
  init?(_ coder: NSCoder, parentVC: UIViewController, viewModel: PopUpSongOptionViewModel) {
    self.parentVC = parentVC
    self.viewModel = viewModel
    super.init(coder: coder)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Setups
  
  private func setupView() {
    setupExitButton()
    setupSongThumbnailImageView()
    setupSongTitleLabel()
    setupSingerLabel()
    setupOptionTableView()
    setupArchiveFolderFloatingPanelView()
  }
  
  private func setupExitButton() {
    exitButton.makeAsCircle()
  }
  
  private func setupSongThumbnailImageView() {
    songThumbnailImageView.layer.cornerRadius = 12
  }
  
  private func setupSongTitleLabel() {
    songTitleLabel.text = viewModel.selectedSong.title
  }
  
  private func setupSingerLabel() {
    singerLabel.text = viewModel.selectedSong.singer
  }
  
  private func setupOptionTableView() {
    optionTableView.separatorStyle = .none
    optionTableView.tableFooterView = UIView()
    
    let nibName = UINib(nibName: R.nib.popUpSongOptionTableViewCell.name, bundle: nil)
    optionTableView.register(nibName, forCellReuseIdentifier: PopUpSongOptionTableViewCell.identifier)
    optionTableView.dataSource = self
    optionTableView.delegate = self
  }
  
  private func setupArchiveFolderFloatingPanelView() {
    archiveFolderFloatingPanelView = ArchiveFolderFloatingPanelView(parentViewController: parentVC, delegate: self)
  }
  
  
  // MARK: - Binds
  
  private func bind() {
    bindInputs()
    bindOutputs()
  }
  
  private func bindInputs() {
    exitButton
      .rx.tap
      .bind(to: viewModel.input.tapExitButton)
      .disposed(by: disposeBag)
    
    optionTableView
      .rx.itemSelected
      .bind(to: viewModel.input.tapOptionItem)
      .disposed(by: disposeBag)
  }
  
  private func bindOutputs() {
    viewModel.output
      .dismiss
      .asDriver(onErrorDriveWith: .never())
      .drive(onNext: { [weak self] in
        self?.exitButtonAction()
      })
      .disposed(by: disposeBag)
    
    viewModel.output
      .showingFolderFloatingPanelView
      .asDriver(onErrorDriveWith: .never())
      .drive(with: self, onNext: { vc, song in
        let song = song.asSongType()
        vc.archiveFolderFloatingPanelView?.show(song)
      })
      .disposed(by: disposeBag)
    
    viewModel.output
      .showingDeleteSongAlert
      .asDriver(onErrorDriveWith: .never())
      .drive(with: self, onNext: { vc, song in
        vc.presentRemoveAlert(song)
      })
      .disposed(by: disposeBag)
    
    viewModel.output
      .didSelectedSongItemEdited
      .asDriver(onErrorDriveWith: .never())
      .drive(with: self, onNext: { vc, _ in
        vc.archiveFolderFloatingPanelView?.hide(animated: true)
        vc.delegate?.didSelectedItemMoved?()
      })
      .disposed(by: disposeBag)
  }
  
  
  // MARK: - Methods
  
  private func presentArchiveFolderVC(_ selectedSong: Song) {
    let storyboard = UIStoryboard(name: R.storyboard.folder.name, bundle: nil)
    let archiveFolderVC = storyboard.instantiateViewController(identifier: PopUpArchiveFolderViewController.identifier) { coder -> PopUpArchiveFolderViewController in
      let viewModel = PopUpArchiveFolderViewModel()
      return .init(coder, viewModel) ?? PopUpArchiveFolderViewController(.init())
    }
    
    archiveFolderVC.delegate = self
    present(archiveFolderVC, animated: true, completion: nil)
  }
  
  private func presentRemoveAlert(_ song: ArchiveSong) {
    let removeAlert = UIAlertController(title: "삭제", message: "정말 「\(song.title)」 를 삭제하시겠습니까?", preferredStyle: .alert)
    
    let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] action in
      guard let self = self else { return }
      Observable.just(Void())
        .bind(to: self.viewModel.input.deleteSong)
        .dispose()
    }
    
    let cancelAction = UIAlertAction(title: "취소", style: .destructive, handler: nil)
    
    removeAlert.addAction(confirmAction)
    removeAlert.addAction(cancelAction)
    
    present(removeAlert, animated: true)
  }
}


// MARK: - Extensions

extension PopUpSongOptionViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfRowsInSection(viewModel.sectionCount)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let optionCell = tableView.dequeueReusableCell(withIdentifier: PopUpSongOptionTableViewCell.identifier, for: indexPath) as? PopUpSongOptionTableViewCell else { return UITableViewCell() }
    
    let optionModel = viewModel.optionAtIndex(indexPath)
    optionCell.titleLabel.text = optionModel.title
    optionCell.iconImageView.image = optionModel.icon
    
    return optionCell
  }
}

extension PopUpSongOptionViewController: PopUpArchiveFolderViewDelegate {
  func didSongAdded() {
    archiveFolderFloatingPanelView?.hide(animated: true)
    archiveFolderFloatingPanelView = nil
    Observable.just(Void())
      .bind(to: viewModel.input.deleteSong)
      .disposed(by: disposeBag)
  }
}
