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

    // MARK: - Declaraiton
    @IBOutlet weak var appbarView: UIView!
    @IBOutlet weak var appbarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var appbarTitleLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var addFolderButton: UIButton!
    @IBOutlet weak var archiveFolderTableView: UITableView!
    
    weak var delegate: ArchiveFolderListViewDelegate?
    private let viewModel = ArchiveFolderListViewModel()
    private var disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupInstance()
        bind()
        reloadArchiveFolderTableView()
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
    private func setupView() {
        self.hero.isEnabled = true
        
        view.fillStatusBar(color: ColorSet.appbarBackgroundColor)
        
        // Appbar View
        appbarView.hero.id = "appbar"
        appbarView.layer.cornerRadius = 28
        appbarView.layer.maskedCorners = CACornerMask([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        appbarView.setAppbarShadow()
        
        // Appbar Height
        DispatchQueue.main.async {
            self.appbarViewHeightConstraint.constant = 90 + SafeAreaInset.top
        }
        
        // Appbar Title Label
        appbarTitleLabel.hero.id = "appbarTitle"
        
        // Add Folder Button
        addFolderButton.layer.cornerRadius = 12
        addFolderButton.hero.modifiers = [.translate(y: 20), .fade]
        
        // Exit Button
        exitButton.hero.id = "exitButton"
        exitButton.makeAsCircle()
        exitButton.setExitButtonShadow()
        
        // Folder TableView
        archiveFolderTableView.separatorStyle = .none
        archiveFolderTableView.tableFooterView = UIView()
        archiveFolderTableView.contentInset = UIEdgeInsets(top: 48, left: 0, bottom: 0, right: 0)
    }
    
    private func setupInstance() {
        // Folder TableView
        let folderCellNibName = UINib(nibName: "FolderTableViewCell", bundle: nil)
        archiveFolderTableView.register(folderCellNibName, forCellReuseIdentifier: "folderTableViewCell")
        archiveFolderTableView.delegate = self
        archiveFolderTableView.dataSource = self
    }
    
    private func bind() {
        // ExitButton TapAction
        exitButton.rx.tap
            .bind(with: self) { vc, _ in
                vc.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
        
        // AddFolder Button Tap Action
        addFolderButton.rx.tap
            .bind(with: self) { vc, _ in
                vc.presentAddFolderView()
            }.disposed(by: disposeBag)
        
        // ArchiveFolder TablewView
        archiveFolderTableView.rx.itemSelected
            .asDriver()
            .drive(with: self, onNext: { vc, indexPath in
                vc.presentArchiveSongListVC(indexPath: indexPath)
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
        guard let addFolderVC = storyboard?.instantiateViewController(identifier: "addFolderStoryboard") as? AddFolderViewController else {
            return
        }
        
        addFolderVC.modalPresentationStyle = .fullScreen
        addFolderVC.delegate = self
        present(addFolderVC, animated: true, completion: nil)
    }
    
    public func presentArchiveSongListVC(indexPath: IndexPath) {
        guard let archiveSongListVC = storyboard?.instantiateViewController(identifier: "archiveSongListStoryboard") as? ArchiveSongListViewController else {
            return
        }
        
        archiveSongListVC.modalPresentationStyle = .fullScreen
        let viewModel = ArchiveSongListViewModel(currentFolderId: viewModel.archiveFolderAtIndex(indexPath).id)
        archiveSongListVC.viewModel = viewModel
        archiveSongListVC.delegate = self
        present(archiveSongListVC, animated: true, completion: nil)
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
