//
//  FolderViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture
import Hero

protocol FolderViewDelegate: AnyObject {
    func folderView(didChangeFolderDescription: Bool)
}

class FolderViewController: UIViewController {
    
    // MARK: - Declaraiton
    weak var delegate: FolderViewDelegate?
    var disposeBag = DisposeBag()
    let archiveFolderManager = ArchiveFolderManager()
    var currentArchiveFolder: ArchiveFolder? // pass from superview(ArchiveViewController)
    var archivedSongArr = [ArchiveSong]()
    
    @IBOutlet weak var appbarView: UIView!
    @IBOutlet weak var appbarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var folderTitleEmojiTextField: EmojiTextField!
    @IBOutlet weak var folderTitleTextField: UITextField!
    @IBOutlet weak var archivedSongTableView: UITableView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureData()
        initView()
        initInstance()
        initEventListener()
        setArchivedSongs()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateFolderNameIfNeeded()
        updateFolderTitleEmojiIfNeeded()
    }
    
    // MARK: - Override
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setArchivedSongs()
    }
    
    // MARK: - Initialization
    private func configureData() {
        if currentArchiveFolder == nil {
            dismiss(animated: true, completion: nil)
        }
        
        folderTitleTextField.text = currentArchiveFolder?.title
        folderTitleEmojiTextField.text = currentArchiveFolder?.titleEmoji
    }
    
    private func initView() {
        self.hero.isEnabled = true
        
        // Appbar View
        appbarView.hero.id = "appbar"
        appbarView.layer.cornerRadius = 28
        appbarView.layer.maskedCorners = CACornerMask([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        appbarView.setAppbarShadow()
        
        // Appbar Height
        appbarViewHeightConstraint.constant = 90 + SafeAreaInset.top
        
        // Exit Button
        exitButton.hero.id = "exitButton"
        exitButton.makeAsCircle()
        exitButton.setExitButtonShadow()
        
        // Archived Song TableView
        archivedSongTableView.tableFooterView = UIView()
        archivedSongTableView.separatorStyle = .none
        archivedSongTableView.layer.cornerRadius = 12
        archivedSongTableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        // Folder title Textfield
        folderTitleTextField.layer.cornerRadius = 12
        folderTitleTextField.setLeftPadding(width: 16)
        folderTitleTextField.setRightPadding(width: 16)
        folderTitleTextField.setSearchBoxShadow()
        folderTitleTextField.hero.modifiers = [.fade, .translate(y: 12)]
        
        // Folder title emoji Textfield
        folderTitleEmojiTextField.layer.cornerRadius = 16
        folderTitleEmojiTextField.setSearchBoxShadow()
        folderTitleEmojiTextField.hero.modifiers = [.fade, .translate(y: 12)]
    }
    
    private func initInstance() {
        // Archived Song TableView
        let songCellNibName = UINib(nibName: "SongTableViewCell", bundle: nil)
        archivedSongTableView.register(songCellNibName, forCellReuseIdentifier: "searchResultTableViewCell")
        archivedSongTableView.dataSource = self
        archivedSongTableView.delegate = self
    }
    
    private func initEventListener() {
        // Exit Button Tap Action
        exitButton.rx.tap
            .bind(with: self) { vc, _ in
                vc.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
        
        // Title Emoji Label Tap Action
        folderTitleEmojiTextField.rx.text
            .bind(with: self) { vc, string in
                guard let string = string else { return }
                if string.count >= 1 {
                    guard let inputChar = string.last else { return }
                    
                    if !inputChar.isEmoji {
                        vc.folderTitleEmojiTextField.text = ""
                    } else {
                        vc.folderTitleEmojiTextField.text = inputChar.description
                    }
                }
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Method
    private func setArchivedSongs() {
        archivedSongArr = Array(currentArchiveFolder!.songs)
        archivedSongTableView.reloadData()
    }
    
    private func updateFolderNameIfNeeded() {
        guard let folderTitle = folderTitleTextField.text else {
            return
        }
        
        if folderTitle != currentArchiveFolder?.title {
            archiveFolderManager.updateTitle(archiveFolder: currentArchiveFolder!, newTitle: folderTitle)
                .subscribe(with: self) { vc in
                    vc.delegate?.folderView(didChangeFolderDescription: true)
                } onError: { vc, error in
                    print(error)
                    // TODO: - Handle the Error State
                }.disposed(by: disposeBag)
        }
    }
    
    private func updateFolderTitleEmojiIfNeeded() {
        guard let folderTitleEmoji = folderTitleEmojiTextField.text else { return }
        
        if folderTitleEmoji != currentArchiveFolder?.titleEmoji {
            archiveFolderManager.updateTitleEmoji(archiveFolder: currentArchiveFolder!, newEmoji: folderTitleEmoji)
                .subscribe(with: self) { vc in
                    vc.delegate?.folderView(didChangeFolderDescription: true)
                } onError: { vc, error in
                    print(error)
                    // TODO: - Handle the Error State
                }.disposed(by: disposeBag)
        }
    }
}

// MARK: - Extension
extension FolderViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return archivedSongArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let songCell = tableView.dequeueReusableCell(withIdentifier: "searchResultTableViewCell") as? SongTableViewCell else { return UITableViewCell() }
        
        songCell.titleLabel.text        = archivedSongArr[indexPath.row].title
        songCell.songNumberLabel.text   = archivedSongArr[indexPath.row].no
        songCell.singerLabel.text       = archivedSongArr[indexPath.row].singer
        songCell.brandLabel.text        = archivedSongArr[indexPath.row].brand
        
        return songCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            archiveFolderManager.deleteSong(song: archivedSongArr[indexPath.row])
                .subscribe(with: self, onCompleted: { vc in
                    vc.archivedSongArr.remove(at: indexPath.row)
                    vc.archivedSongTableView.deleteRows(at: [indexPath], with: .left)
                })
                .disposed(by: disposeBag)
        }
    }
}
