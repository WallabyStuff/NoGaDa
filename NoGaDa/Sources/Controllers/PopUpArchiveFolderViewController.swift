//
//  PopUpArchiveViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

import FloatingPanel
import RxSwift
import RxCocoa
import RxGesture

@objc protocol PopUpArchiveFolderViewDelegate: AnyObject {
  @objc optional func didSongAdded()
}

class PopUpArchiveFolderViewController: BaseViewController, ViewModelInjectable {
  
  
  // MARK: - Properties
  
  static let identifier = R.storyboard.folder.popUpArchiveFolderStoryboard.identifier
  typealias ViewModel = PopUpArchiveFolderViewModel
  
  @IBOutlet weak var exitButton: UIButton!
  @IBOutlet weak var addFolderButton: UIButton!
  @IBOutlet weak var archiveFolderTableView: UITableView!
  
  weak var delegate: PopUpArchiveFolderViewDelegate?
  var viewModel: ViewModel
  public var exitButtonAction: () -> Void = {}
  
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
  
  // MARK: - Initializers
  
  required init(_ viewModel: PopUpArchiveFolderViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(_ coder: NSCoder, _ viewModel: PopUpArchiveFolderViewModel) {
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
    setupAddFolderButton()
    setupArchiveFolderTableView()
    setupExitButton()
    setupAddFolderButton()
  }
  
  private func setupAddFolderButton() {
    addFolderButton.layer.cornerRadius = 12
    addFolderButton.layer.shadowColor = UIColor.gray.cgColor
    addFolderButton.layer.shadowOffset = CGSize(width: 0, height: 4)
    addFolderButton.layer.shadowRadius = 4
    addFolderButton.layer.shadowOpacity = 0.1
  }
  
  private func setupArchiveFolderTableView() {
    registerArchiveFolderTableCell()
    archiveFolderTableView.layer.cornerRadius = 8
    archiveFolderTableView.tableFooterView = UIView()
    archiveFolderTableView.separatorInset = UIEdgeInsets(top: 0, left: 44, bottom: 0, right: 0)
  }
  
  private func registerArchiveFolderTableCell() {
    let nibName = UINib(nibName: R.nib.popUpArchiveFolderTableViewCell.name, bundle: nil)
    archiveFolderTableView.register(nibName, forCellReuseIdentifier: PopUpArchiveFolderTableViewCell.identifier)
  }
  
  private func setupExitButton() {
    exitButton.makeAsCircle()
  }
  
  
  // MARK: - Binds
  
  private func bind() {
    bindInputs()
    bindOutputs()
  }
  
  private func bindInputs() {
    Observable.just(Void())
      .bind(to: viewModel.input.viewDidLoad)
      .disposed(by: disposeBag)
    
    archiveFolderTableView
      .rx.itemSelected
      .bind(to: viewModel.input.tapFolderItem)
      .disposed(by: disposeBag)
    
    addFolderButton
      .rx.tap
      .bind(to: viewModel.input.tapAddFolderButton)
      .disposed(by: disposeBag)
    
    exitButton
      .rx.tap
      .bind(to: viewModel.input.tapExitButton)
      .disposed(by: disposeBag)
  }
  
  private func bindOutputs() {
    viewModel.output.folders
      .bind(to: archiveFolderTableView.rx.items(cellIdentifier: PopUpArchiveFolderTableViewCell.identifier,
                                                cellType: PopUpArchiveFolderTableViewCell.self)) { index, item, cell in
        cell.titleLabel.text = item.title
        cell.emojiLabel.text = item.titleEmoji
      }.disposed(by: disposeBag)
    
    viewModel.output.showingAddSongAlert
      .asDriver(onErrorDriveWith: .never())
      .drive(onNext: { [weak self] song, targetFolder in
        self?.presentAddSongAlert(song: song,
                                  targetFolder: targetFolder)
      })
      .disposed(by: disposeBag)
    
    viewModel.output.showingAddFolderVC
      .asDriver(onErrorDriveWith: .never())
      .drive(onNext: { [weak self] in
        self?.presentAddFolderVC()
      })
      .disposed(by: disposeBag)
    
    viewModel.output.dismiss
      .asDriver(onErrorDriveWith: .never())
      .drive(onNext: { [weak self] in
        self?.dismiss(animated: true)
      })
      .disposed(by: disposeBag)
    
    viewModel.output.didSongAdded
      .asDriver(onErrorDriveWith: .never())
      .drive(onNext: { [weak self] in
        self?.delegate?.didSongAdded?()
      })
      .disposed(by: disposeBag)
    
    viewModel.output.playHapticFeedback
      .asDriver(onErrorDriveWith: .never())
      .drive(onNext: { type in
        HapticFeedbackManager.playNotificationFeedback(type)
      })
      .disposed(by: disposeBag)
    
    viewModel.output.showingAlearyExistsAlert
      .asDriver(onErrorDriveWith: .never())
      .drive(onNext: { [weak self] in
        self?.presentAlreadyExitstAlert()
      })
      .disposed(by: disposeBag)
  }
  
  
  // MARK: - Methods
  
  private func presentAddFolderVC() {
    let storyboard = UIStoryboard(name: R.storyboard.folder.name, bundle: nil)
    let addFolderVC = storyboard.instantiateViewController(identifier: AddFolderViewController.identifier) { coder -> AddFolderViewController in
      let viewModel = AddFolderViewModel()
      return .init(coder, viewModel) ?? AddFolderViewController(viewModel)
    }
    
    addFolderVC.delegate = self
    present(addFolderVC, animated: true, completion: nil)
  }
  
  public func presentAddSongAlert(song: Song, targetFolder: ArchiveFolder) {
    let addSongAlert = UIAlertController(title: "저장",
                                         message: "「\(song.title)」를 「\(targetFolder.title)」에 저장하시겠습니까?",
                                         preferredStyle: .alert)
    
    let cancelAction = UIAlertAction(title: "취소", style: .destructive)
    let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] action in
      guard let self = self else { return }
      Observable.just((song, targetFolder))
        .bind(to: self.viewModel.input.confirmAddSongButton)
        .disposed(by: self.disposeBag)
    }
    
    addSongAlert.addAction(confirmAction)
    addSongAlert.addAction(cancelAction)
    present(addSongAlert, animated: true, completion: nil)
  }
  
  public func presentAlreadyExitstAlert()  {
    let alreadyExistsAlert = UIAlertController(title: "알림",
                                               message: "이미 저장된 곡입니다.",
                                               preferredStyle: .alert)
    let confirmAction = UIAlertAction(title: "확인", style: .cancel)
    alreadyExistsAlert.addAction(confirmAction)
    
    present(alreadyExistsAlert, animated: true, completion: nil)
  }
}


// MARK: - Extensions

extension PopUpArchiveFolderViewController: AddFolderViewDelegate {
  func didFolderAdded() {
    Observable.just(Void())
      .bind(to: viewModel.input.didFolderAdded)
      .dispose()
  }
}
