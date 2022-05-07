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

@objc protocol ArchiveFolderListViewDelegate: AnyObject {
    @objc optional func didFileChanged()
}

class ArchiveFolderListViewController: UIViewController {

    
    // MARK: - Properties
    
    @IBOutlet weak var appbarView: UIView!
    @IBOutlet weak var appbarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var appbarTitleLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var addFolderButton: UIButton!
    @IBOutlet weak var archiveFolderTableView: UITableView!
    
    weak var delegate: ArchiveFolderListViewDelegate?
    private var viewModel: ArchiveFolderListViewModel
    private var disposeBag = DisposeBag()
    private let archiveFolderTableViewTopInset: CGFloat = 36
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
        reloadArchiveFolderTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        unhighlightSelectedCell()
    }
    
    
    // MARK: - Overrides
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        reloadArchiveFolderTableView()
    }

    
    // MARK: - Initializers
    
    init(_ viewModel: ArchiveFolderListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    init?(_ coder: NSCoder, _ viewModel: ArchiveFolderListViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Setups
    
    private func setupView() {
        self.hero.isEnabled = true
        
        setupAppbar()
        setupAddFolderButton()
        setupExitButton()
        setupArchiveFolderTableView()
    }
    
    private func bind() {
        bindExitButton()
        bindAddFolderButton()
        bindArchiveFolderTableView()
        bindAppbarView()
    }
    
    private func setupAppbar() {
        view.fillStatusBar(color: ColorSet.appbarBackgroundColor)
        appbarView.hero.id = "appbar"
        appbarView.layer.cornerRadius = 28
        appbarView.layer.maskedCorners = CACornerMask([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        appbarView.setAppbarShadow()
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
        archiveFolderTableView.separatorStyle = .none
        archiveFolderTableView.tableFooterView = UIView()
        archiveFolderTableView.contentInset = UIEdgeInsets(top: archiveFolderTableViewTopInset, left: 0, bottom: 0, right: 0)
        
        let nibName = UINib(nibName: "FolderTableViewCell", bundle: nil)
        archiveFolderTableView.register(nibName, forCellReuseIdentifier: "folderTableViewCell")
        archiveFolderTableView.delegate = self
        archiveFolderTableView.dataSource = self
    }
    
    
    // MARK: - Binds
    
    private func bindExitButton() {
        exitButton.rx.tap
            .asDriver()
            .drive(with: self) { vc, _ in
                vc.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
    }
    
    private func bindAddFolderButton() {
        addFolderButton.rx.tap
            .asDriver()
            .drive(with: self) { vc, _ in
                vc.presentAddFolderView()
            }.disposed(by: disposeBag)
    }
    
    private func bindArchiveFolderTableView() {
        archiveFolderTableView.rx.itemSelected
            .asDriver()
            .drive(with: self, onNext: { vc, indexPath in
                vc.presentArchiveSongListVC(indexPath: indexPath)
            }).disposed(by: disposeBag)
    }
    
    private func bindAppbarView() {
        archiveFolderTableView.rx.contentOffset
            .asDriver()
            .drive(with: self, onNext: { vc, offset in
                let changedY = offset.y + vc.archiveFolderTableViewTopInset
                let newAppbarHeight = AppbarHeight.shared.min - (changedY * 0.2)
                
                if newAppbarHeight >= AppbarHeight.shared.min {
                    vc.appbarViewHeightConstraint.constant = newAppbarHeight
                }
            }).disposed(by: disposeBag)
    }
    
    
    // MARK: - Methods
    
    private func reloadArchiveFolderTableView() {
        viewModel.fetchFolders()
            .subscribe(onCompleted: { [weak self] in
                self?.archiveFolderTableView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    private func presentRemoveFolderAlert(_ indexPath: IndexPath, _ completion: @escaping () -> Void ) {
        let archiveFolderVM = viewModel.archiveFolderAtIndex(indexPath)
        
        let removeFolderAlert = UIAlertController(title: "삭제",
                                                  message: "정말로 「\(archiveFolderVM.titleEmoji)\(archiveFolderVM.title)」 를 삭제하시겠습니까?",
                                                  preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .destructive)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] action in
            guard let self = self else { return }
            
            self.viewModel.deleteFolder(indexPath)
                .observe(on: MainScheduler.instance)
                .subscribe(onCompleted: {
                    completion()
                }).disposed(by: self.disposeBag)
        }
        
        removeFolderAlert.addAction(confirmAction)
        removeFolderAlert.addAction(cancelAction)
        present(removeFolderAlert, animated: true, completion: nil)
    }
    
    func presentAddFolderView() {
        let storyboard = UIStoryboard(name: "Folder", bundle: nil)
        guard let addFolderVC = storyboard.instantiateViewController(identifier: "addFolderStoryboard") as? AddFolderViewController else {
            return
        }
        
        addFolderVC.modalPresentationStyle = .fullScreen
        addFolderVC.delegate = self
        present(addFolderVC, animated: true, completion: nil)
    }
    
    public func presentArchiveSongListVC(indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Archive", bundle: nil)
        let archiveSongListVC = storyboard.instantiateViewController(identifier: "archiveSongListStoryboard") { coder -> ArchiveSongListViewController in
            let viewModel = ArchiveSongListViewModel(currentFolderId: self.viewModel.archiveFolderAtIndex(indexPath).id)
            return .init(coder, viewModel) ?? ArchiveSongListViewController(.init())
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

extension ArchiveFolderListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(viewModel.sectionCount)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let folderCell = tableView.dequeueReusableCell(withIdentifier: "folderTableViewCell") as? FolderTableViewCell else { return UITableViewCell() }
        
        let archiveFolderVM = viewModel.archiveFolderAtIndex(indexPath)
        
        folderCell.titleEmojiLabel.text = archiveFolderVM.titleEmoji
        folderCell.titleLabel.text      = archiveFolderVM.title
        
        return folderCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            presentRemoveFolderAlert(indexPath) { [weak self] in
                self?.archiveFolderTableView.deleteRows(at: [indexPath], with: .left)
                self?.delegate?.didFileChanged?()
            }
        }
    }
}

extension ArchiveFolderListViewController: ArchiveSongListViewDelegate {
    func didFolderNameChanged() {
        reloadArchiveFolderTableView()
    }
}

extension ArchiveFolderListViewController: AddFolderViewDelegate {
    func didFolderAdded() {
        reloadArchiveFolderTableView()
        delegate?.didFileChanged?()
    }
}
