//
//  ArchiveViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture
import Hero

@objc
protocol ArchiveFolderListViewDelegate: AnyObject {
    @objc optional
    func didFileChanged()
}

class ArchiveFolderViewController: BaseViewController, ViewModelInjectable {

    
    // MARK: - Properties
    
    static let identifier = R.storyboard.archive.archiveFolderStoryboard.identifier
    typealias ViewModel = ArchiveFolderViewModel
    
    @IBOutlet weak var appbarView: UIView!
    @IBOutlet weak var appbarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var appbarTitleLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var addFolderButton: UIButton!
    @IBOutlet weak var archiveFolderTableView: UITableView!
    
    weak var delegate: ArchiveFolderListViewDelegate?
    var viewModel: ViewModel
    private let archiveFolderTableViewTopInset: CGFloat = 36
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unhighlightSelectedCell()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    // MARK: - Overrides
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        archiveFolderTableView.reloadData()
    }

    
    // MARK: - Initializers
    
    required init(_ viewModel: ArchiveFolderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(_ coder: NSCoder, _ viewModel: ArchiveFolderViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("ViewModel has not been implemented")
    }
    
    // MARK: - Setups
    
    private func setup() {
        setupView()
    }
    
    private func setupView() {
        self.hero.isEnabled = true
        setupStatusBar()
        setupAppbar()
        setupAppbarTitleLabel()
        setupAddFolderButton()
        setupExitButton()
        setupArchiveFolderTableView()
    }
    
    private func setupStatusBar() {
        view.fillStatusBar(color: R.color.accentColor()!)
    }
    
    private func setupAppbar() {
        appbarView.hero.id = "appbar"
        appbarView.layer.cornerRadius = 28
        appbarView.layer.maskedCorners = CACornerMask([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        appbarView.setAppbarShadow()
        appbarViewHeightConstraint.constant = compactAppbarHeight
    }
    
    private func setupAppbarTitleLabel() {
        appbarTitleLabel.hero.id = "appbarTitle"
    }
    
    private func setupAddFolderButton() {
        addFolderButton.layer.cornerRadius = 12
        addFolderButton.hero.modifiers = [.translate(y: 20), .fade]
    }
    
    private func setupExitButton() {
        exitButton.makeAsCircle()
        exitButton.setExitButtonShadow()
    }
    
    private func setupArchiveFolderTableView() {
        registerArchiveFolderCell()
        archiveFolderTableView.separatorStyle = .none
        archiveFolderTableView.tableFooterView = UIView()
        archiveFolderTableView.contentInset = UIEdgeInsets(top: archiveFolderTableViewTopInset, left: 0, bottom: 0, right: 0)
        archiveFolderTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func registerArchiveFolderCell() {
        let nibName = UINib(nibName: R.nib.folderTableViewCell.name, bundle: nil)
        archiveFolderTableView.register(nibName, forCellReuseIdentifier: FolderTableViewCell.identifier)
    }
    
    
    // MARK: - Binds
    
    private func bind() {
        bindAppbarView()
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        self.rx.viewWillAppear
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
        
        exitButton
            .rx.tap
            .map { _ in }
            .bind(to: viewModel.input.tapExitButton)
            .disposed(by: disposeBag)
        
        addFolderButton
            .rx.tap
            .map { _ in }
            .bind(to: viewModel.input.tapAddFolderButton)
            .disposed(by: disposeBag)
        
        archiveFolderTableView
            .rx.itemSelected
            .bind(to: viewModel.input.tapFolderItem)
            .disposed(by: disposeBag)
    }
    
    private func bindOutput() {
        viewModel.output.folders
            .bind(to: archiveFolderTableView.rx.items(cellIdentifier: FolderTableViewCell.identifier,
                                                      cellType: FolderTableViewCell.self)) { index, item, cell in
                cell.titleEmojiLabel.text = item.titleEmoji
                cell.titleLabel.text = item.title
            }.disposed(by: disposeBag)
        
        viewModel.output.showingAddFolderVC
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] in
                self?.presentAddFolderView()
            })
            .disposed(by: disposeBag)
        
        viewModel.output.showingArchiveSongVC
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] folder in
                self?.presentArchiveSongVC(folder)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.showingDeleteFolderItemAlert
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] targetFolder in
                self?.presentRemoveFolderAlert(targetFolder)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.dismiss
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.didFolderEdited
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] in
                self?.delegate?.didFileChanged?()
            })
            .disposed(by: disposeBag)
    }
    
    private func bindAppbarView() {
        archiveFolderTableView.rx.contentOffset
            .asDriver()
            .drive(with: self, onNext: { vc, offset in
                let compactAppbarHeight = vc.compactAppbarHeight
                
                let changedY = offset.y + vc.archiveFolderTableViewTopInset
                let newAppbarHeight = compactAppbarHeight - (changedY * 0.2)
                
                if newAppbarHeight >= vc.compactAppbarHeight {
                    vc.appbarViewHeightConstraint.constant = newAppbarHeight
                }
            }).disposed(by: disposeBag)
    }
    
    
    // MARK: - Methods
    
    private func presentRemoveFolderAlert(_ targetFolder: ArchiveFolder) {
        let removeFolderAlert = UIAlertController(title: "삭제",
                                                  message: "정말로 「\(targetFolder.titleEmoji)\(targetFolder.title)」 를 삭제하시겠습니까?",
                                                  preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "취소", style: .destructive)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] action in
            guard let self = self else { return }
            
            Observable.just(targetFolder)
                .bind(to: self.viewModel.input.confirmDeleteFolder)
                .dispose()
        }

        removeFolderAlert.addAction(confirmAction)
        removeFolderAlert.addAction(cancelAction)
        present(removeFolderAlert, animated: true, completion: nil)
    }
    
    func presentAddFolderView() {
        let storyboard = UIStoryboard(name: R.storyboard.folder.name, bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: AddFolderViewController.identifier,
                                                                  creator: { coder -> AddFolderViewController in
            let viewModel = AddFolderViewModel()
            return .init(coder, viewModel) ?? AddFolderViewController(viewModel)
        })
        
        viewController.modalPresentationStyle = .fullScreen
        viewController.delegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    public func presentArchiveSongVC(_ archiveFolder: ArchiveFolder) {
        let storyboard = UIStoryboard(name: R.storyboard.archive.name, bundle: nil)
        let archiveSongListVC = storyboard.instantiateViewController(identifier: ArchiveSongViewController.identifier) { coder -> ArchiveSongViewController in
            let viewModel = ArchiveSongViewModel(currentFolder: archiveFolder)
            return .init(coder, viewModel) ?? ArchiveSongViewController(viewModel)
        }
        
        archiveSongListVC.modalPresentationStyle = .fullScreen
        archiveSongListVC.delegate = self
        present(archiveSongListVC, animated: true, completion: nil)
    }
    
    private func unhighlightSelectedCell(_ animated: Bool = true) {
        guard let indexPath = archiveFolderTableView.indexPathForSelectedRow else { return }
        archiveFolderTableView.deselectRow(at: indexPath, animated: animated)
    }
}


// MARK: - Extensions

extension ArchiveFolderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, _ in
            guard let self = self else { return }
            Observable.just(indexPath)
                .bind(to: self.viewModel.input.deleteFolderItem)
                .dispose()
        }
        let actions = [deleteAction]
        
        return .init(actions: actions)
    }
}

extension ArchiveFolderViewController: ArchiveSongListViewDelegate {
    func didFolderNameChanged() {
        Observable.just(Void())
            .bind(to: viewModel.input.editFolder)
            .dispose()
    }
}

extension ArchiveFolderViewController: AddFolderViewDelegate {
    func didFolderAdded() {
        delegate?.didFileChanged?()
    }
}
