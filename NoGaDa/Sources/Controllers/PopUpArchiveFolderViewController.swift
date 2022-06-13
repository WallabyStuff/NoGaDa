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
    private let admobManager = AdMobManager()
    
    
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
        setupData()
    }
    
    private func setupData() {
        viewModel.fetchFolder()
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
        
        archiveFolderTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
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
        bindAddFolderButton()
        bindExitButton()
        bindArchiveFolderTableView()
        bindArchiveFolderTableCell()
        bindPresentAlreadyExistsAlert()
        bindPlayNotificationFeedback()
        bindDidSongAdded()
    }
    
    private func bindAddFolderButton() {
        addFolderButton.rx.tap
            .asDriver()
            .drive(with: self) { vc, _ in
                vc.presentAddFolderVC()
            }.disposed(by: disposeBag)
    }
    
    private func bindExitButton() {
        exitButton.rx.tap
            .asDriver()
            .drive(with: self) { vc, _ in
                vc.exitButtonAction()
            }.disposed(by: disposeBag)
    }
    
    private func bindArchiveFolderTableView() {
        viewModel.folders
            .bind(to: archiveFolderTableView.rx.items(cellIdentifier: PopUpArchiveFolderTableViewCell.identifier,
                                                      cellType: PopUpArchiveFolderTableViewCell.self)) { index, item, cell in
                cell.titleLabel.text = item.title
                cell.emojiLabel.text = item.titleEmoji
            }.disposed(by: disposeBag)
    }
    
    private func bindArchiveFolderTableCell() {
        archiveFolderTableView.rx.itemSelected
            .asDriver()
            .drive(with: self, onNext: { vc, indexPath in
                vc.presentAddSongAlert(indexPath)
            }).disposed(by: disposeBag)
    }
    
    private func bindPresentAlreadyExistsAlert() {
        viewModel.presentAlreadyExitstAlert
            .subscribe(with: self, onNext: { vc, _ in
                vc.presentAlreadyExitstAlert()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindPlayNotificationFeedback() {
        viewModel.playNotificationFeedback
            .subscribe(with: self, onNext: { vc, type in
                HapticFeedbackManager.playNotificationFeedback(type)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindDidSongAdded() {
        viewModel.didSongAdded
            .subscribe(with: self, onNext: { vc, _ in
                vc.admobManager.presentAdMob(vc: vc)
                vc.delegate?.didSongAdded?()
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
    
    public func presentRemoveFolderAlert(_ indexPath: IndexPath) {
        let selectedFolder = viewModel.folderAt(indexPath)
        let removeFolderAlert = UIAlertController(title: "삭제",
                                                  message: "정말로 「\(selectedFolder.titleEmoji)\(selectedFolder.title)」 를 삭제하시겠습니까?",
                                                  preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .destructive)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] action in
            self?.viewModel.removeFolderAction(indexPath)
        }
        
        removeFolderAlert.addAction(confirmAction)
        removeFolderAlert.addAction(cancelAction)
        present(removeFolderAlert, animated: true, completion: nil)
    }
    
    public func presentAddSongAlert(_ indexPath: IndexPath) {
        let selectedSong = viewModel.selectedSong
        let targetFolder = viewModel.folderAt(indexPath)
        
        let addSongAlert = UIAlertController(title: "저장",
                                             message: "「\(selectedSong.title)」를 「\(targetFolder.title)」에 저장하시겠습니까?",
                                             preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .destructive)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] action in
            self?.viewModel.addSongAction(indexPath)
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

extension PopUpArchiveFolderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presentRemoveFolderAlert(indexPath)
        }
    }
}

extension PopUpArchiveFolderViewController: AddFolderViewDelegate {
    func didFolderAdded() {
        viewModel.fetchFolder()
    }
}
