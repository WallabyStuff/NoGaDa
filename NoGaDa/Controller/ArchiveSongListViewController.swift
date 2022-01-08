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

@objc protocol ArchiveSongListViewDelegate: AnyObject {
    @objc optional func didFolderNameChanged()
}

class ArchiveSongListViewController: UIViewController {
    
    // MARK: - Declaraiton
    @IBOutlet weak var appbarView: UIView!
    @IBOutlet weak var appbarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var folderTitleEmojiTextField: EmojiTextField!
    @IBOutlet weak var folderTitleTextField: UITextField!
    @IBOutlet weak var archiveSongTableView: UITableView!
    @IBOutlet weak var addSongButton: UIButton!
    
    weak var delegate: ArchiveSongListViewDelegate?
    public var viewModel: ArchiveSongListViewModel?
    private var disposeBag = DisposeBag()
    private var songOptionFloatingPanelView: SongOptionFloatingPanelView?
    private let minimumAppbarHeight: CGFloat = 88 + SafeAreaInset.top
    private let archiveSongTableViewTopInset: CGFloat = 36
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupData()
        setupView()
        setupInstance()
        bind()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateFolderNameIfNeeded()
        updateFolderTitleEmojiIfNeeded()
    }
    
    // MARK: - Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setArchiveSong()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    // MARK: - Initialization
    private func setupData() {
        if viewModel == nil {
            dismiss(animated: true, completion: nil)
            return
        }
        
        viewModel!.fetchSongFolder()
            .observe(on: MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in
                self?.archiveSongTableView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    private func setupView() {
        self.hero.isEnabled = true
        
        view.fillStatusBar(color: ColorSet.appbarBackgroundColor)
        
        // Appbar View
        appbarView.hero.id = "appbar"
        appbarView.layer.cornerRadius = 28
        appbarView.layer.maskedCorners = CACornerMask([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        appbarView.setAppbarShadow()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.appbarViewHeightConstraint.constant = self.minimumAppbarHeight
            self.appbarViewHeightConstraint.isActive = true
            print(self.minimumAppbarHeight)
        }
        
        // Exit Button
        exitButton.makeAsCircle()
        exitButton.setExitButtonShadow()
        
        // Archived Song TableView
        archiveSongTableView.tableFooterView = UIView()
        archiveSongTableView.separatorStyle = .none
        archiveSongTableView.layer.cornerRadius = 12
        archiveSongTableView.contentInset = UIEdgeInsets(top: archiveSongTableViewTopInset, left: 0, bottom: 100, right: 0)
        
        // Folder title Textfield
        folderTitleTextField.layer.cornerRadius = 12
        folderTitleTextField.setLeftPadding(width: 16)
        folderTitleTextField.setRightPadding(width: 16)
        folderTitleTextField.setSearchBoxShadow()
        folderTitleTextField.hero.modifiers = [.fade, .translate(y: -12)]
        folderTitleTextField.text = viewModel!.folderTitle
        
        // Folder title emoji Textfield
        folderTitleEmojiTextField.layer.cornerRadius = 16
        folderTitleEmojiTextField.setSearchBoxShadow()
        folderTitleEmojiTextField.hero.modifiers = [.fade, .translate(y: -12)]
        folderTitleEmojiTextField.text = viewModel!.folderTitleEmoji
        
        // Add Song Button
        addSongButton.makeAsCircle()
        addSongButton.hero.modifiers = [.fade, .translate(y: SafeAreaInset.bottom + 28)]
        addSongButton.layer.shadowColor = ColorSet.floatingButtonBackgroundColor.cgColor
        addSongButton.layer.shadowOffset = .zero
        addSongButton.layer.shadowRadius = 20
        addSongButton.layer.shadowOpacity = 0.25
    }
    
    private func setupInstance() {
        // Archive Song TableView
        let songCellNibName = UINib(nibName: "SongTableViewCell", bundle: nil)
        archiveSongTableView.register(songCellNibName, forCellReuseIdentifier: "searchResultTableViewCell")
        archiveSongTableView.dataSource = self
        archiveSongTableView.delegate = self
        
        // songOption floating panel view
        songOptionFloatingPanelView = SongOptionFloatingPanelView(parentViewConroller: self, delegate: self)
    }
    
    private func bind() {
        // Exit Button Tap Action
        exitButton.rx.tap
            .asDriver()
            .drive(with: self) { vc, _ in
                vc.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
        
        // Title Emoji Label Tap Action
        folderTitleEmojiTextField.rx.text
            .asDriver()
            .drive(with: self) { vc, string in
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
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.presentAddSongVC()
            }).disposed(by: disposeBag)
        
        // Archive song list TableView
        archiveSongTableView.rx.itemSelected
            .asDriver()
            .drive(with: self, onNext: { vc, indexPath in
                if let selectedSong = vc.viewModel?.archiveSongAtIndex(indexPath) {
                    vc.songOptionFloatingPanelView?.show(selectedSong)
                }
            }).disposed(by: disposeBag)
        
        // Appbar stretching animation
        archiveSongTableView.rx.contentOffset
            .asDriver()
            .drive(with: self, onNext: { vc, offset in
                let changedY = offset.y + vc.archiveSongTableViewTopInset
                let newAppbarHeight = vc.minimumAppbarHeight - (changedY * 0.2)
                
                if newAppbarHeight >= vc.minimumAppbarHeight {
                    vc.appbarViewHeightConstraint.constant = newAppbarHeight
                }
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Methods
    private func setArchiveSong() {
        viewModel!.fetchSongFolder()
            .subscribe(onCompleted: { [weak self] in
                self?.archiveSongTableView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    private func updateFolderNameIfNeeded() {
        guard let folderTitle = folderTitleTextField.text else {
            return
        }
        
        if folderTitle != viewModel!.folderTitle {
            viewModel!.updateFolderTitle(folderTitle)
                .subscribe(onCompleted: { [weak self] in
                    self?.delegate?.didFolderNameChanged?()
                }).disposed(by: disposeBag)
        }
    }
    
    private func updateFolderTitleEmojiIfNeeded() {
        guard let folderTitleEmoji = folderTitleEmojiTextField.text else { return }
        
        if folderTitleEmoji != viewModel!.folderTitleEmoji {
            viewModel!.updateFolderTitleEmoji(folderTitleEmoji)
                .subscribe(onCompleted: { [weak self] in
                    self?.delegate?.didFolderNameChanged?()
                }).disposed(by: disposeBag)
        }
    }
    
    private func reloadArchiveSongTableView() {
        viewModel?.fetchSongFolder()
            .subscribe(with: self, onCompleted: { vc in
                vc.archiveSongTableView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    private func presentAddSongVC() {
        guard let addSongVC = storyboard?.instantiateViewController(withIdentifier: "addSongStoryboard") as? AddSongViewController else {
            return
        }
        
        guard let folderId = viewModel?.currentFolderId else { return }
        
        let viewModel = AddSongViewModel(targetFolderId: folderId)
        addSongVC.viewModel = viewModel
        
        addSongVC.delegate = self
        addSongVC.modalPresentationStyle = .fullScreen
        present(addSongVC, animated: true, completion: nil)
    }
}

// MARK: - Extensions
extension ArchiveSongListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel!.numberOfRowsInSection(viewModel!.sectionCount)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let songCell = tableView.dequeueReusableCell(withIdentifier: "searchResultTableViewCell") as? SongTableViewCell else { return UITableViewCell() }
        
        let songViewModel = viewModel!.archiveSongAtIndex(indexPath)
        
        songCell.titleLabel.text        = songViewModel.title
        songCell.singerLabel.text       = songViewModel.singer
        songCell.songNumberLabel.text   = "\(songViewModel.brand) \(songViewModel.no)"
        
        return songCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel?.deleteSong(indexPath)
                .observe(on: MainScheduler.instance)
                .subscribe(onCompleted: { [weak self] in
                    self?.archiveSongTableView.deleteRows(at: [indexPath], with: .left)
                }).disposed(by: disposeBag)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension ArchiveSongListViewController: AddSongViewDelegate {
    func didSongAdded() {
        reloadArchiveSongTableView()
    }
}

extension ArchiveSongListViewController: PopUpSongOptionViewDelegate {
    func didSelectedSongRemoved() {
        songOptionFloatingPanelView?.hide(animated: true)
        reloadArchiveSongTableView()
    }
    
    func didSelectedItemMoved() {
        songOptionFloatingPanelView?.hide(animated: true)
        reloadArchiveSongTableView()
    }
}
