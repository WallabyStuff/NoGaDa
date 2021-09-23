//
//  PopUpArchiveViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture

protocol PopUpArchiveViewDelegate: AnyObject {
    func popUpArchiveView(successfullyAdded: Song)
}

class PopUpArchiveViewController: UIViewController {

    // MARK: - Declaraiton
    weak var delegate: PopUpArchiveViewDelegate?
    var disposeBag = DisposeBag()
    var selectedSong: Song? // Passed from superview (main/search)View | Necessary instance
    var exitButtonAction: () -> Void = {}
    let archiveFolderManager = ArchiveFolderManager()
    var archiveFolderArr = [ArchiveFolder]()
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var addFolderButton: UIButton!
    @IBOutlet weak var folderTableView: UITableView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        configureData()
        initView()
        initInstance()
        initEventListener()
        setArchiveFolders()
    }

    // MARK: - Initialization
    private func configureData() {
        if selectedSong == nil {
            dismiss(animated: true, completion: nil)
            return
        }
    }
    
    private func initView() {
        // AddFolder Button
        addFolderButton.layer.cornerRadius = 12
        
        // Folder TableView
        folderTableView.layer.cornerRadius = 8
        folderTableView.tableFooterView = UIView()
        
        // Exit Button
        exitButton.makeAsCircle()
    }
    
    private func initInstance() {
        // Folder TableView
        let folderCellNibName = UINib(nibName: "PopUpArchiveFolderTableViewCell", bundle: nil)
        folderTableView.register(folderCellNibName, forCellReuseIdentifier: "popUpArchiveTableCell")
        folderTableView.dataSource = self
        folderTableView.delegate = self
    }
    
    private func initEventListener() {
        // AddFolder Button Tap Actiobn
        addFolderButton.rx.tap
            .bind(with: self) { vc, _ in
                vc.presentAddFolderVC()
            }.disposed(by: disposeBag)
        
        // Exit button Tap Action
        exitButton.rx.tap
            .bind(with: self) { vc, _ in
                vc.exitButtonAction()
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Method
    private func presentAddFolderVC() {
        guard let addFolderVC = storyboard?.instantiateViewController(identifier: "addFolderStoryboard") as? AddFolderViewController else { return }
        addFolderVC.delegate = self
        
        present(addFolderVC, animated: true, completion: nil)
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
extension PopUpArchiveViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archiveFolderArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let folderCell = tableView.dequeueReusableCell(withIdentifier: "popUpArchiveTableCell") as? PopUpArchiveFolderTableViewCell else { return UITableViewCell() }
        
        folderCell.titleLabel.text = archiveFolderArr[indexPath.row].title
        folderCell.emojiLabel.text = archiveFolderArr[indexPath.row].titleEmoji
        
        return folderCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        archiveFolderManager.appendSong(archiveFolder: archiveFolderArr[indexPath.row], song: selectedSong!)
            .subscribe(with: self, onCompleted: { vc in
                print("성공적으로 저장됨")
                vc.delegate?.popUpArchiveView(successfullyAdded: vc.selectedSong!)
            }).disposed(by: disposeBag)
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

extension PopUpArchiveViewController: AddFolderViewDelegate {
    func addFolderView(didAddFile: Bool) {
        setArchiveFolders()
    }
}
