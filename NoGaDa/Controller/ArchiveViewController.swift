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

class ArchiveViewController: UIViewController {

    // MARK: - Declaraiton
    var disposeBag = DisposeBag()
    let archiveFolderManager = ArchiveFolderManager()
    var archiveFolderArr = [ArchiveFolder]()
    
    @IBOutlet weak var appbarView: UIView!
    @IBOutlet weak var appbarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var appbarTitleLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var addFolderButton: UIButton!
    @IBOutlet weak var folderTableView: UITableView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        initInstance()
        initEventListener()
        setArchiveFolders()
    }
    
    // MARK: - Override
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setArchiveFolders()
    }

    // MARK: - Initialization
    private func initView() {
        self.hero.isEnabled = true
        
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
        folderTableView.separatorStyle = .none
        folderTableView.tableFooterView = UIView()
        folderTableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    }
    
    private func initInstance() {
        // Folder TableView
        let folderCellNibName = UINib(nibName: "FolderTableViewCell", bundle: nil)
        folderTableView.register(folderCellNibName, forCellReuseIdentifier: "folderTableViewCell")
        folderTableView.delegate = self
        folderTableView.dataSource = self
    }
    
    private func initEventListener() {
        // ExitButton TapAction
        exitButton.rx.tap
            .bind(with: self) { vc, _ in
                vc.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
        
        // AddFolder Button Tap Action
        addFolderButton.rx.tap
            .bind(with: self) { vc, _ in
                vc.presentAddFolderVC()
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Method
    private func presentAddFolderVC() {
        guard let addFolderVC = storyboard?.instantiateViewController(identifier: "addFolderStoryboard") as? AddFolderViewController else { return }
        addFolderVC.delegate = self
        addFolderVC.modalPresentationStyle = .fullScreen
        
        present(addFolderVC, animated: true, completion: nil)
    }
    
    private func presentFolderVC(selectedArchiveFolder: ArchiveFolder) {
        guard let folderVC = storyboard?.instantiateViewController(identifier: "folderStoryboard") as? FolderViewController else { return }
        folderVC.delegate = self
        folderVC.modalPresentationStyle = .fullScreen
        folderVC.currentArchiveFolder = selectedArchiveFolder
        
        present(folderVC, animated: true, completion: nil)
    }
    
    private func setArchiveFolders() {
        archiveFolderManager.fetchData()
            .subscribe(with: self, onNext: { vc, archiveFolderArr in
                vc.archiveFolderArr = archiveFolderArr
                vc.folderTableView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    private func presentRemoveFolderAlert(targetFolder: ArchiveFolder, _ completion: @escaping () -> Void ) {
        let removeFolderAlert = UIAlertController(title: "삭제",
                                                  message: "정말로 「\(targetFolder.title)」 를 삭제하시겠습니까?",
                                                  preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .destructive)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] action in
            guard let self = self else { return }
            
            self.archiveFolderManager.deleteData(archiveFolder: targetFolder)
                .subscribe(onCompleted: {
                    completion()
                }).disposed(by: self.disposeBag)
        }
        
        removeFolderAlert.addAction(confirmAction)
        removeFolderAlert.addAction(cancelAction)
        
        present(removeFolderAlert, animated: true, completion: nil)
    }
}

// MARK: - Extension
extension ArchiveViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archiveFolderArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let folderCell = tableView.dequeueReusableCell(withIdentifier: "folderTableViewCell") as? FolderTableViewCell else { return UITableViewCell() }
        
        folderCell.titleEmojiLabel.text = archiveFolderArr[indexPath.row].titleEmoji
        folderCell.titleLabel.text      = archiveFolderArr[indexPath.row].title
        
        return folderCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentFolderVC(selectedArchiveFolder: archiveFolderArr[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presentRemoveFolderAlert(targetFolder: archiveFolderArr[indexPath.row]) { [weak self] in
                self?.archiveFolderArr.remove(at: indexPath.row)
                self?.folderTableView.deleteRows(at: [indexPath], with: .left)
            }
        }
    }
}

extension ArchiveViewController: FolderViewDelegate {
    func folderView(didChangeFolderDescription: Bool) {
        setArchiveFolders()
    }
}

extension ArchiveViewController: AddFolderViewDelegate {
    func addFolderView(didAddFile: Bool) {
        setArchiveFolders()
    }
}
