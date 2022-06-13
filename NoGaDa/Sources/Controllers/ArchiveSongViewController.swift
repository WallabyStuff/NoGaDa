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

class ArchiveSongViewController: BaseViewController, ViewModelInjectable {
    
    
    // MARK: - Properties
    
    static let identifier = R.storyboard.archive.archiveSongStoryboard.identifier
    typealias ViewModel = ArchiveSongViewModel
    
    @IBOutlet weak var appbarView: UIView!
    @IBOutlet weak var appbarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var folderTitleEmojiTextField: EmojiTextField!
    @IBOutlet weak var folderTitleTextField: UITextField!
    @IBOutlet weak var archiveSongTableView: UITableView!
    @IBOutlet weak var addSongButton: UIButton!
    
    weak var delegate: ArchiveSongListViewDelegate?
    var viewModel: ViewModel
    private var songOptionFloatingPanelView: SongOptionFloatingPanelView?
    private let archiveSongTableViewTopInset: CGFloat = 36
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateFolderNameIfNeeded()
        updateFolderTitleEmojiIfNeeded()
    }
    
    
    // MARK: - Overrides
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        archiveSongTableView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    
    // MARK: - Initialization
    
    required init(_ viewModel: ArchiveSongViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(_ coder: NSCoder, _ viewModel: ArchiveSongViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Setups
    
    private func setupView() {
        setupStatusBar()
        setupAppbarView()
        setupExitButton()
        setupArchiveSongTableView()
        setupFolderTitleTextField()
        setupTitleEmojiTextField()
        setupAddSongButton()
        setupSongOptionFloatingPanelView()
    }
    
    private func setupStatusBar() {
        view.fillStatusBar(color: R.color.accentColor()!)
    }
    
    private func setupAppbarView() {
        appbarView.hero.id = "appbar"
        appbarView.layer.cornerRadius = 28
        appbarView.layer.maskedCorners = CACornerMask([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        appbarView.setAppbarShadow()
        appbarViewHeightConstraint.constant = compactAppbarHeight
    }
    
    private func setupExitButton() {
        exitButton.makeAsCircle()
        exitButton.setExitButtonShadow()
    }
    
    private func setupArchiveSongTableView() {
        registerArchiveSongTableCell()
        archiveSongTableView.tableFooterView = UIView()
        archiveSongTableView.separatorStyle = .none
        archiveSongTableView.layer.cornerRadius = 12
        archiveSongTableView.contentInset = UIEdgeInsets(top: archiveSongTableViewTopInset, left: 0, bottom: 100, right: 0)
        
        archiveSongTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func registerArchiveSongTableCell() {
        let songCellNibName = UINib(nibName: R.nib.songTableViewCell.name, bundle: nil)
        archiveSongTableView.register(songCellNibName, forCellReuseIdentifier: SongTableViewCell.identifier)
    }
    
    private func setupFolderTitleTextField() {
        folderTitleTextField.layer.cornerRadius = 12
        folderTitleTextField.setLeftPadding(width: 16)
        folderTitleTextField.setRightPadding(width: 16)
        folderTitleTextField.setSearchBoxShadow()
        folderTitleTextField.hero.modifiers = [.fade, .translate(y: -12)]
        folderTitleTextField.text = viewModel.folderTitle
    }
    
    private func setupTitleEmojiTextField() {
        folderTitleEmojiTextField.layer.cornerRadius = 16
        folderTitleEmojiTextField.setSearchBoxShadow()
        folderTitleEmojiTextField.hero.modifiers = [.fade, .translate(y: -12)]
        folderTitleEmojiTextField.text = viewModel.folderTitleEmoji
    }
    
    private func setupAddSongButton() {
        addSongButton.makeAsCircle()
        addSongButton.hero.modifiers = [.fade, .translate(y: view.safeAreaInsets.bottom + 28)]
        addSongButton.layer.shadowColor = ColorSet.floatingButtonBackgroundColor.cgColor
        addSongButton.layer.shadowOffset = .zero
        addSongButton.layer.shadowRadius = 20
        addSongButton.layer.shadowOpacity = 0.25
    }
    
    private func setupSongOptionFloatingPanelView() {
        songOptionFloatingPanelView = SongOptionFloatingPanelView(parentViewConroller: self, delegate: self)
    }
    
    
    // MARK: - Binds
    
    private func bind() {
        bindAppbarView()
        bindExitButton()
        bindFolderTitleEmojiTextField()
        bindAddSongButton()
        
        bindArchiveSongTableView()
        bindArchiveSongTableCell()
    }
    
    private func bindAppbarView() {
        archiveSongTableView.rx.contentOffset
            .asDriver()
            .drive(with: self, onNext: { vc, offset in
                let changedY = offset.y + vc.archiveSongTableViewTopInset
                let newAppbarHeight = vc.compactAppbarHeight - (changedY * 0.2)
                
                if newAppbarHeight >= vc.compactAppbarHeight {
                    vc.appbarViewHeightConstraint.constant = newAppbarHeight
                }
            }).disposed(by: disposeBag)
    }
    
    private func bindExitButton() {
        exitButton.rx.tap
            .asDriver()
            .drive(with: self) { vc, _ in
                vc.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
    }
    
    private func bindFolderTitleEmojiTextField() {
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
    }
    
    private func bindAddSongButton() {
        addSongButton.rx.tap
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.viewModel.addSongButtonTapAction()
            }).disposed(by: disposeBag)
        
        viewModel.presentAddSongVC
            .subscribe(with: self, onNext: { vc, currentFolder in
                vc.presentAddSongVC(currentFolder)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindArchiveSongTableView() {
        viewModel.songs
            .bind(to: archiveSongTableView.rx.items(cellIdentifier: SongTableViewCell.identifier,
                                                    cellType: SongTableViewCell.self)) { index, item, cell in
                cell.titleLabel.text = item.title
                cell.singerLabel.text = item.singer
                cell.songNumberLabel.text = "\(item.brand) \(item.no)"
            }.disposed(by: disposeBag)
    }
    
    private func bindArchiveSongTableCell() {
        archiveSongTableView.rx.itemSelected
            .asDriver()
            .drive(with: self, onNext: { vc, indexPath in
                vc.viewModel.songItemTapAction(indexPath)
            }).disposed(by: disposeBag)
        
        viewModel.showSongOptionFlowtingPanelView
            .subscribe(with: self, onNext: { vc, archiveSong in
                vc.songOptionFloatingPanelView?.show(archiveSong)
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - Methods
    
    private func updateFolderNameIfNeeded() {
        guard let newTitle = folderTitleTextField.text else {
            return
        }
        
        viewModel.updateFolderTitle(newTitle)
    }
    
    private func updateFolderTitleEmojiIfNeeded() {
        guard let newEmoji = folderTitleEmojiTextField.text else {
            return
        }
        
        viewModel.updateTitleEmoji(newEmoji)
    }
    
    private func presentAddSongVC(_ archiveFolder: ArchiveFolder) {
        let storyboard = UIStoryboard(name: R.storyboard.archive.name, bundle: nil)
        let addSongVC = storyboard.instantiateViewController(identifier: AddSongViewController.identifier) { coder -> AddSongViewController in
            let viewModel = AddSongViewModel(targetFolderId: archiveFolder.id)
            return .init(coder, viewModel) ?? AddSongViewController(viewModel)
        }
        
        addSongVC.modalPresentationStyle = .fullScreen
        addSongVC.delegate = self
        present(addSongVC, animated: true, completion: nil)
    }
}


// MARK: - Extensions

extension ArchiveSongViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, _ in
            self?.viewModel.deleteSong(indexPath)
        }
        let actions = [deleteAction]
        
        return .init(actions: actions)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension ArchiveSongViewController: AddSongViewDelegate {
    func didSongAdded() {
        viewModel.fetchSongs()
    }
}

extension ArchiveSongViewController: PopUpSongOptionViewDelegate {
    func didSelectedSongRemoved() {
        songOptionFloatingPanelView?.hide(animated: true)
        viewModel.fetchSongs()
    }
    
    func didSelectedItemMoved() {
        songOptionFloatingPanelView?.hide(animated: true)
        viewModel.fetchSongs()
    }
}
