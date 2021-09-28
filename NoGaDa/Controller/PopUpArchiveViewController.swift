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
    
    private func presentAddSongAlert(targetFolder: ArchiveFolder, selectedSong: Song) {
        let addSongAlert = UIAlertController(title: "저장",
                                             message: "「\(selectedSong.title)」를 「\(targetFolder.title)」에 저장하시겠습니까?",
                                             preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .destructive)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] action in
            guard let self = self else { return }
            
            self.archiveFolderManager.appendSong(archiveFolder: targetFolder, song: selectedSong)
                .subscribe(with: self, onCompleted: { vc in
                    vc.delegate?.popUpArchiveView(successfullyAdded: vc.selectedSong!)
                }).disposed(by: self.disposeBag)
        }
        
        addSongAlert.addAction(confirmAction)
        addSongAlert.addAction(cancelAction)
        
        present(addSongAlert, animated: true, completion: nil)
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
        presentAddSongAlert(targetFolder: archiveFolderArr[indexPath.row], selectedSong: selectedSong!)
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

extension PopUpArchiveViewController: AddFolderViewDelegate {
    func addFolderView(didAddFile: Bool) {
        setArchiveFolders()
    }
}
