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

protocol ArchiveSongListViewDelegate: AnyObject {
    func folderView(didChangeFolderDescription: Bool)
}

class ArchiveSongListViewController: UIViewController {
    
    // MARK: - Declaraiton
    private let savedSongListViewModel = ArchiveSongListViewModel()
    weak var delegate: ArchiveSongListViewDelegate?
    private var disposeBag = DisposeBag()
    public var currentFolderId: String?
    
    @IBOutlet weak var appbarView: UIView!
    @IBOutlet weak var appbarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var folderTitleEmojiTextField: EmojiTextField!
    @IBOutlet weak var folderTitleTextField: UITextField!
    @IBOutlet weak var savedSongTableView: UITableView!
    @IBOutlet weak var addSongButton: UIButton!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureData()
        initView()
        initInstance()
        initEventListener()
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
        setSavedSong()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Initialization
    private func configureData() {
        guard let currentSongFolderId = currentFolderId else {
            dismiss(animated: true, completion: nil)
            return
        }

        savedSongListViewModel.fetchSongFolder(currentSongFolderId)
            .observe(on: MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in
                self?.savedSongTableView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    private func initView() {
        self.hero.isEnabled = true
        
        view.fillStatusBar(color: ColorSet.appbarBackgroundColor)
        
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
        savedSongTableView.tableFooterView = UIView()
        savedSongTableView.separatorStyle = .none
        savedSongTableView.layer.cornerRadius = 12
        savedSongTableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 100, right: 0)
        
        // Folder title Textfield
        folderTitleTextField.layer.cornerRadius = 12
        folderTitleTextField.setLeftPadding(width: 16)
        folderTitleTextField.setRightPadding(width: 16)
        folderTitleTextField.setSearchBoxShadow()
        folderTitleTextField.hero.modifiers = [.fade, .translate(y: -12)]
        folderTitleTextField.text = savedSongListViewModel.folderTitle
        
        // Folder title emoji Textfield
        folderTitleEmojiTextField.layer.cornerRadius = 16
        folderTitleEmojiTextField.setSearchBoxShadow()
        folderTitleEmojiTextField.hero.modifiers = [.fade, .translate(y: -12)]
        folderTitleEmojiTextField.text = savedSongListViewModel.folderTitleEmoji
        
        // Add Song Button
        addSongButton.makeAsCircle()
        addSongButton.hero.modifiers = [.fade, .translate(y: SafeAreaInset.bottom + 28)]
        addSongButton.layer.shadowColor = ColorSet.floatingButtonBackgroundColor.cgColor
        addSongButton.layer.shadowOffset = .zero
        addSongButton.layer.shadowRadius = 20
        addSongButton.layer.shadowOpacity = 0.25
    }
    
    private func initInstance() {
        // Archived Song TableView
        let songCellNibName = UINib(nibName: "SongTableViewCell", bundle: nil)
        savedSongTableView.register(songCellNibName, forCellReuseIdentifier: "searchResultTableViewCell")
        savedSongTableView.dataSource = self
        savedSongTableView.delegate = self
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
        
        // Add Song Button Tab Action
        addSongButton.rx.tap
            .bind(with: self, onNext: { vc, _ in
                vc.presentAddSongVC()
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Method
    private func setSavedSong() {
        savedSongListViewModel.fetchSongFolder(currentFolderId!)
            .subscribe(onCompleted: { [weak self] in
                self?.savedSongTableView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    private func updateFolderNameIfNeeded() {
        guard let folderTitle = folderTitleTextField.text else {
            return
        }
        
        if folderTitle != savedSongListViewModel.folderTitle {
            savedSongListViewModel.updateFolderTitle(folderTitle)
                .subscribe(onCompleted: { [weak self] in
                    self?.delegate?.folderView(didChangeFolderDescription: true)
                }).disposed(by: disposeBag)
        }
    }
    
    private func updateFolderTitleEmojiIfNeeded() {
        guard let folderTitleEmoji = folderTitleEmojiTextField.text else { return }
        
        if folderTitleEmoji != savedSongListViewModel.folderTitleEmoji {
            savedSongListViewModel.updateFolderTitleEmoji(folderTitleEmoji)
                .subscribe(onCompleted: { [weak self] in
                    self?.delegate?.folderView(didChangeFolderDescription: true)
                }).disposed(by: disposeBag)
        }
    }
    
    private func presentAddSongVC() {
        guard let addSongVC = storyboard?.instantiateViewController(withIdentifier: "addSongStoryboard") as? AddSongViewController else { return }
        
        addSongVC.modalPresentationStyle = .fullScreen
        addSongVC.currentFolderId = currentFolderId
        addSongVC.delegate = self
        
        present(addSongVC, animated: true, completion: nil)
    }
    
    private func reloadSavedSongTableView() {
        savedSongListViewModel.reloadFolder(currentFolderId!)
            .subscribe(onCompleted: { [weak self] in
                self?.savedSongTableView.reloadData()
            }).disposed(by: disposeBag)
    }
}

// MARK: - Extension
extension ArchiveSongListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedSongListViewModel.numberOfRowsInSection(savedSongListViewModel.sectionCount)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let songCell = tableView.dequeueReusableCell(withIdentifier: "searchResultTableViewCell") as? SongTableViewCell else { return UITableViewCell() }
        
        let savedSongVM = savedSongListViewModel.archiveSongAtIndex(indexPath)
        
        songCell.titleLabel.text        = savedSongVM.title
        songCell.singerLabel.text       = savedSongVM.singer
        songCell.songNumberLabel.text   = "\(savedSongVM.brand) \(savedSongVM.no)"
        
        return songCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            savedSongListViewModel.deleteSong(indexPath)
                .observe(on: MainScheduler.instance)
                .subscribe(onCompleted: { [weak self] in
                    self?.savedSongTableView.deleteRows(at: [indexPath], with: .left)
                }).disposed(by: disposeBag)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension ArchiveSongListViewController: AddSongViewDelegate {
    func didSongUpdated() {
        reloadSavedSongTableView()
    }
}
