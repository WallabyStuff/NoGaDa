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
        return .darkContent
    }

    // MARK: - Initialization
    private func initView() {
        // Add Folder Button
        addFolderButton.layer.cornerRadius = 12
        
        // Exit Button
        exitButton.makeAsCircle()
        
        // Folder TableView
        folderTableView.separatorStyle = .none
        folderTableView.tableFooterView = UIView()
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
        folderVC.hero.isEnabled = true
        folderVC.hero.modalAnimationType = .selectBy(presenting: .push(direction: .left), dismissing: .pull(direction: .right))
        
        present(folderVC, animated: true, completion: nil)
    }
    
    private func setArchiveFolders() {
        archiveFolderManager.fetchData()
            .subscribe(with: self, onNext: { vc, archiveFolderArr in
                vc.archiveFolderArr = archiveFolderArr
                vc.folderTableView.reloadData()
            }).disposed(by: disposeBag)
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
            archiveFolderManager.deleteData(archiveFolder: archiveFolderArr[indexPath.row])
                .subscribe(with: self, onCompleted: { vc in
                    vc.archiveFolderArr.remove(at: indexPath.row)
                    vc.folderTableView.deleteRows(at: [indexPath], with: .left)
                }).disposed(by: disposeBag)
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
