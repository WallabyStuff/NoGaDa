//
//  ViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

import RxCocoa
import RxSwift
import RxGesture

class MainViewController: BaseViewController, ViewModelInjectable {

    
    // MARK: Properties
    
    typealias ViewModel = MainViewModel
    static let identifier = R.storyboard.main.mainStoryboard.identifier
    
    @IBOutlet weak var appbarView: AppbarView!
    @IBOutlet weak var appbarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var appbarTitleLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var mainContentScrollView: UIScrollView!
    @IBOutlet weak var mainContentScrollViewContentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var archiveShortcutView: ArchiveFolderShortcutView!
    @IBOutlet weak var archiveShortcutBackgroundImageView: UIImageView!
    @IBOutlet weak var totalArchivedSongSizeLabel: UILabel!
    @IBOutlet weak var searchBoxView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var brandSegmentedControl: BISegmentedControl!
    @IBOutlet weak var newUpdateSongTableView: UITableView!
    @IBOutlet weak var newUpdateSongErrorMessageLabel: UILabel!
    @IBOutlet weak var newUpdateSongLoadingIndicator: UIActivityIndicatorView!
    
    var viewModel: ViewModel
    private let splashView = SplashView()
    private var archiveFolderFloatingView: ArchiveFolderFloatingPanelView?
    
    
    // MARK: - Initializers
    
    required init(_ viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        dismiss(animated: true)
    }
    
    required init?(_ coder: NSCoder, _ viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
        
        AdMobManager.shared.presentAd(vc: self)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("ViewModel has not been implemented")
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        splashView.show(vc: self)
        setup()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideSplashView()
        requestTrackingAuthorization()
        viewModel.updateAmountOfSavedSongs()
        
        // Update constraints
        appbarView.setNeedsLayout()
    }
    
    
    // MARK: - Constraints
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        newUpdateSongTableView.reloadData()
    }
    
    
    // MARK: - Setups
    
    private func setup() {
        setupView()
        setupData()
    }
    
    private func setupData() {
        viewModel.fetchUpdatedSong()
    }
    
    private func setupView() {
        setupStatusBar()
        setupAppbarView()
        setupAppbarTitleLabel()
        setupSettingButton()
        setupMainContentScrollView()
        setupSearchTextField()
        setupSearchButton()
        setupArchiveShortcutBackgroundImageView()
        setupNewUpdateSongTableView()
        setupBrandSegmentedControl()
    }
    
    private func setupStatusBar() {
        view.fillStatusBar(color: R.color.accentColor()!)
    }
    
    private func setupAppbarView() {
        appbarView.backgroundColor = .clear
        appbarView.configure(cornerRadius: 28, roundCorners: [.bottomRight])
        appbarView.setAppbarShadow()
        appbarViewHeightConstraint.constant = regularAppbarHeight
        mainContentScrollView.contentInset = UIEdgeInsets(top: regularAppbarHeight,
                                                               left: 0, bottom: 0, right: 0)
        mainContentScrollView.scrollToTop(animated: true)
    }
    
    private func setupAppbarTitleLabel() {
        appbarTitleLabel.hero.id = "appbarTitle"
    }
    
    private func setupSettingButton() {
        settingButton.setPadding(width: 4)
    }
    
    private func setupMainContentScrollView() {
        mainContentScrollViewContentViewHeightConstraint.constant = view.frame.height
    }
    
    private func setupSearchTextField() {
        searchBoxView.layer.cornerRadius = 12
        searchBoxView.setSearchBoxShadow()
    }
    
    private func setupSearchButton() {
        searchButton.layer.cornerRadius = 8
        searchButton.setSearchBoxButtonShadow()
    }
    
    private func setupArchiveShortcutBackgroundImageView() {
        archiveShortcutBackgroundImageView.layer.cornerRadius = 20
        archiveShortcutBackgroundImageView.layer.maskedCorners = [.layerMinXMaxYCorner]
    }
    
    private func setupNewUpdateSongTableView() {
        registerNewUpdateSongTableView()
        newUpdateSongTableView.layer.cornerRadius = 12
        newUpdateSongTableView.tableFooterView = UIView()
        newUpdateSongTableView.separatorStyle = .none
    }
    
    private func registerNewUpdateSongTableView() {
        let nibName = UINib(nibName: R.nib.updatedSongTableViewCell.name, bundle: nil)
        newUpdateSongTableView.register(nibName, forCellReuseIdentifier: UpdatedSongTableViewCell.identifier)
    }
    
    private func setupBrandSegmentedControl() {
        brandSegmentedControl.segmentTintColor = ColorSet.updatedSongSelectorSelectedTextColor
        brandSegmentedControl.segmentDefaultColor = ColorSet.updatedSongSelectorUnSelectedTextColor
        brandSegmentedControl.barIndicatorColor = ColorSet.updatedSongSelectorBarIndicatorColor
        brandSegmentedControl.barIndicatorHeight = 3
        brandSegmentedControl.segmentFontSize = 14
        brandSegmentedControl.addSegment(title: "tj 업데이트")
        brandSegmentedControl.addSegment(title: "금영 업데이트")
        brandSegmentedControl.delegate = self
    }
    
    
    // MARK: - Bindss
    
    private func bind() {
        bindSearchBoxView()
        bindSearchButton()
        bindArchiveShorcutView()
        bindSettingButton()
        bindMainContentScrollView()

        bindAmountOfSavedSongsSizeLabel()
        
        bindNewUpdateSongTableView()
        bindNewUpdateSongTableCell()
        bindNewUpdateSongLoadingState()
        bindNewUpdateSongsFailState()
        
        bindShowArchiveFolderFloatingView()
    }
    
    private func bindSearchBoxView() {
        searchBoxView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { vc, _ in
                vc.presentSearchVC()
            }.disposed(by: disposeBag)
        
        searchBoxView.rx.longPressGesture()
            .when(.began)
            .bind(with: self) { vc, _ in
                vc.presentSearchVC()
            }.disposed(by: disposeBag)
    }
    
    private func bindSearchButton() {
        searchButton.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { vc, _ in
                vc.presentSearchVC()
            }.disposed(by: disposeBag)
    }
    
    private func bindArchiveShorcutView() {
        archiveShortcutView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { vc, _ in
                vc.presentArchiveFolderVC()
            }.disposed(by: disposeBag)
    }
    
    private func bindSettingButton() {
        settingButton.rx.tap
            .bind(with: self, onNext: { vc, _ in
                vc.presentSettingVC()
            }).disposed(by: disposeBag)
    }
    
    private func bindMainContentScrollView() {
        mainContentScrollView.rx.contentOffset
            .asDriver()
            .drive(with: self, onNext: { vc, offset in
                let compactAppbarHeight = vc.compactAppbarHeight
                let regularAppbarHeight = vc.regularAppbarHeight
                let changedY = offset.y + regularAppbarHeight
                
                if -regularAppbarHeight < offset.y {
                    // Shrink Appbar
                    if regularAppbarHeight - changedY >= compactAppbarHeight {
                        let modifiedAppbarHeight: CGFloat = regularAppbarHeight - changedY
                        vc.appbarViewHeightConstraint.constant = modifiedAppbarHeight
                        
                        let appbarTitleLabelAlpha: CGFloat = 1 - (regularAppbarHeight - modifiedAppbarHeight) / (regularAppbarHeight - compactAppbarHeight)
                        vc.appbarTitleLabel.alpha = appbarTitleLabelAlpha
                        vc.settingButton.alpha = appbarTitleLabelAlpha
                    } else {
                        vc.appbarViewHeightConstraint.constant = compactAppbarHeight
                        vc.appbarTitleLabel.alpha = 0
                        vc.settingButton.alpha = 0
                    }
                } else {
                    // Stretch Appbar
                    vc.appbarViewHeightConstraint.constant = regularAppbarHeight - changedY * 0.2
                    vc.appbarTitleLabel.alpha = 1
                    vc.settingButton.alpha = 1
                }
            }).disposed(by: disposeBag)
    }

    
    
    private func bindAmountOfSavedSongsSizeLabel() {
        viewModel.amountOfSavedSongs
            .subscribe(with: self, onNext: { vc, text in
                vc.totalArchivedSongSizeLabel.text = text
            })
            .disposed(by: disposeBag)
    }
    
    private func bindNewUpdateSongTableView() {
        viewModel.newUpdateSongs
            .bind(to: newUpdateSongTableView.rx.items(cellIdentifier: UpdatedSongTableViewCell.identifier,
                                                      cellType: UpdatedSongTableViewCell.self)) { index, song, cell in
                cell.songTitleLabel.text = song.title
                cell.songNumberLabel.text = song.no
                cell.singerLabel.text = song.singer
            }
            .disposed(by: disposeBag)
    }
    
    private func bindNewUpdateSongTableCell() {
        newUpdateSongTableView.rx.itemSelected
            .asDriver()
            .drive(with: self, onNext: { vc, indexPath in
                vc.viewModel.songItemSelectAction(indexPath)
            }).disposed(by: disposeBag)
    }
    
    private func bindNewUpdateSongLoadingState() {
        viewModel.isLoadingNewUpdateSongs
            .subscribe(with: self, onNext: { vc, isLoading in
                if isLoading {
                    vc.newUpdateSongLoadingIndicator.isHidden = false
                    vc.newUpdateSongLoadingIndicator.startAnimating()
                } else {
                    vc.newUpdateSongLoadingIndicator.isHidden = true
                    vc.newUpdateSongLoadingIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindNewUpdateSongsFailState() {
        viewModel.newUpdateSongsErrorState
            .subscribe(with: self, onNext: { vc, message in
                if message.isEmpty {
                    vc.newUpdateSongErrorMessageLabel.isHidden = true
                } else {
                    vc.newUpdateSongErrorMessageLabel.isHidden = false
                    vc.newUpdateSongErrorMessageLabel.text = message
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindShowArchiveFolderFloatingView() {
        viewModel.showArchiveFolderFloatingView
            .subscribe(with: self, onNext: { vc, song in
                vc.showArchiveFolderFloatingView(song)
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - Methods
    
    func presentSearchVC() {
        let storyboard = UIStoryboard(name: R.storyboard.search.name, bundle: nil)
        let searchVC = storyboard.instantiateViewController(identifier: SearchViewController.identifier) { coder -> SearchViewController in
            let viewModel = SearchViewModel()
            return .init(coder, viewModel) ?? SearchViewController(.init())
        }
        
        HapticFeedbackManager.playImpactFeedback(.light)
        searchVC.modalPresentationStyle = .fullScreen
        present(searchVC, animated: true)
    }
    
    func presentArchiveFolderVC() {
        let storyboard = UIStoryboard(name: R.storyboard.archive.name, bundle: nil)
        let archiveVC = storyboard.instantiateViewController(identifier: ArchiveFolderViewController.identifier) { coder -> ArchiveFolderViewController in
            let viewModel = ArchiveFolderViewModel()
            return .init(coder, viewModel) ?? ArchiveFolderViewController(viewModel)
        }
        
        archiveVC.modalPresentationStyle = .fullScreen
        present(archiveVC, animated: true, completion: nil)
    }
    
    func presentSettingVC() {
        let storyboard = UIStoryboard(name: R.storyboard.setting.name, bundle: nil)
        guard let settingVC = storyboard.instantiateViewController(withIdentifier: SettingViewController.identifier) as? SettingViewController else {
            return
        }
        
        present(settingVC, animated: true, completion: nil)
    }
    
    private func hideSplashView() {
        splashView.hide { [weak self] in
            self?.newUpdateSongTableView.flashScrollIndicators()
        }
    }
    
    private func showArchiveFolderFloatingView(_ selectedSong: Song) {
        archiveFolderFloatingView?.hide(animated: false)
        archiveFolderFloatingView = ArchiveFolderFloatingPanelView(parentViewController: self, delegate: self)
        archiveFolderFloatingView?.show(selectedSong)
    }
}


// MARK: - Extensions

extension MainViewController: PopUpArchiveFolderViewDelegate {
    func didSongAdded() {
        archiveFolderFloatingView?.hide(animated: true)
        viewModel.updateAmountOfSavedSongs()
    }
}

extension MainViewController: ArchiveFolderListViewDelegate {
    func didFileChanged() {
        viewModel.updateAmountOfSavedSongs()
    }
}

extension MainViewController: BISegmentedControlDelegate {
    func BISegmentedControl(didSelectSegmentAt index: Int) {
        if index == 0 {
            viewModel.updatedSelectedKaraokeBrank(.tj)
        } else {
            viewModel.updatedSelectedKaraokeBrank(.kumyoung)
        }
    }
}
