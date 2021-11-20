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
    func popUpArchiveView(isSuccessfullyAdded: Bool)
}

class PopUpSongFolderListViewController: UIViewController {

    // MARK: - Declaraiton
    private let popUpSongFolderListViewModel = PopUpSongFolderListViewModel()
    weak var delegate: PopUpArchiveViewDelegate?
    private var disposeBag = DisposeBag()
    var selectedSong: Song? // Passed from superview (main/search)View | Necessary instance
    var exitButtonAction: () -> Void = {}
    
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
        folderTableView.separatorInset = UIEdgeInsets(top: 0, left: 44, bottom: 0, right: 0)
        
        // Exit Button
        exitButton.makeAsCircle()
        
        // Add folder Button
        addFolderButton.layer.shadowColor = UIColor.gray.cgColor
        addFolderButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        addFolderButton.layer.shadowRadius = 8
        addFolderButton.layer.shadowOpacity = 0.2
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
        popUpSongFolderListViewModel.fetchSongFolder()
            .observe(on: MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in
                self?.folderTableView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    private func presentAddSongAlert(targetFolder: ArchiveFolder, selectedSong: Song) {
        let addSongAlert = UIAlertController(title: "저장",
                                             message: "「\(selectedSong.title)」를 「\(targetFolder.title)」에 저장하시겠습니까?",
                                             preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .destructive)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] action in
            guard let self = self else { return }
            
            self.popUpSongFolderListViewModel.appendSong(targetFolder, selectedSong)
                .observe(on: MainScheduler.instance)
                .subscribe(with: self, onCompleted: { vc in
                    vc.delegate?.popUpArchiveView(isSuccessfullyAdded: true)
                }, onError: { vc, error in
                    guard let error = error as? SongFolderManagerError else { return }
                    
                    if error == .alreadyExists {
                        vc.presentAlreadyExitstAlert()
                    }
                }).disposed(by: self.disposeBag)
        }
        
        addSongAlert.addAction(confirmAction)
        addSongAlert.addAction(cancelAction)
        
        present(addSongAlert, animated: true, completion: nil)
    }
    
    private func presentRemoveFolderAlert(_ indexPath: IndexPath, _ completion: @escaping () -> Void ) {
        let songFolderVM = popUpSongFolderListViewModel.songFolderAtIndex(indexPath)
        
        let removeFolderAlert = UIAlertController(title: "삭제",
                                                  message: "정말로 「\(songFolderVM.titleEmoji)\(songFolderVM.title)」 를 삭제하시겠습니까?",
                                                  preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .destructive)
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] action in
            guard let self = self else { return }
            
            self.popUpSongFolderListViewModel.deleteFolder(indexPath)
                .subscribe(onCompleted: {
                    completion()
                }).disposed(by: self.disposeBag)
        }
        
        removeFolderAlert.addAction(confirmAction)
        removeFolderAlert.addAction(cancelAction)
        
        present(removeFolderAlert, animated: true, completion: nil)
    }
    
    private func presentAlreadyExitstAlert() {
        let alreadyExistsAlert = UIAlertController(title: "알림",
                                                   message: "이미 저장된 곡입니다.",
                                                   preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "확인", style: .cancel) { [weak self] action in
            self?.delegate?.popUpArchiveView(isSuccessfullyAdded: false)
        }
        alreadyExistsAlert.addAction(confirmAction)
        
        present(alreadyExistsAlert, animated: true, completion: nil)
    }
}

// MARK: - Extension
extension PopUpSongFolderListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return popUpSongFolderListViewModel.numberOfRowsInSection(popUpSongFolderListViewModel.sectionCount)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let folderCell = tableView.dequeueReusableCell(withIdentifier: "popUpArchiveTableCell") as? PopUpArchiveFolderTableViewCell else { return UITableViewCell() }
        
        let songFolderVM = popUpSongFolderListViewModel.songFolderAtIndex(indexPath)
        
        folderCell.titleLabel.text = songFolderVM.title
        folderCell.emojiLabel.text = songFolderVM.titleEmoji
        
        return folderCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let songFolderVM = popUpSongFolderListViewModel.songFolderAtIndex(indexPath)
        
        presentAddSongAlert(targetFolder: songFolderVM.songFolder, selectedSong: selectedSong!)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            presentRemoveFolderAlert(indexPath) { [weak self] in
                self?.folderTableView.deleteRows(at: [indexPath], with: .left)
            }
        }
    }
}

extension PopUpSongFolderListViewController: AddFolderViewDelegate {
    func addFolderView(didAddFile: Bool) {
        setArchiveFolders()
    }
}
