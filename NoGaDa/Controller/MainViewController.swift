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
import RealmSwift
import AppTrackingTransparency

class MainViewController: UIViewController {

    // MARK: Declaration
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
    @IBOutlet weak var updatedSongTableView: UITableView!
    @IBOutlet weak var updatedsongLoadErrorMessageLabel: UILabel!
    @IBOutlet weak var updatedSongLoadingIndicator: UIActivityIndicatorView!
    
    private var disposeBag = DisposeBag()
    private let splashView = SplashView()
    private let viewModel = MainViewModel()
    private var updatedSongBrand: KaraokeBrand {
        if brandSegmentedControl.currentPosition == 0 {
            return .tj
        } else {
            return .kumyoung
        }
    }
    private var archiveFolderFloatingView: ArchiveFolderFloatingPanelView?
    private var minimumAppbarHeight: CGFloat = 80
    private var maximumAppbarHeight: CGFloat = 140
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splashView.show(vc: self)
        setupView()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        hideSplashView()
        updateTotalSavedSongSize()
        requestTrackingAuthorization()
    }
    
    // MARK: - Overrides
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        reloadUpdateChartTableView()
    }

    // MARK: - Initializers
    private func setupView() {
        self.hero.isEnabled = true
        setupAppbarView()
        setupSettingButton()
        setupMainContentScrollView()
        setupSearchTextField()
        setupSearchButton()
        setupArchiveShortcutBackgroundImageView()
        setupUpdatedSongTableView()
        setupBrandSegmentedControl()
    }
    
    private func bind() {
        bindSearchBoxView()
        bindSearchButton()
        bindArchiveShorcutView()
        bindSettingButton()
        bindMainContentScrollView()
        bindUpdatedSongTableView()
    }
    
    // MARK: - Setups
    private func setupAppbarView() {
        view.fillStatusBar(color: ColorSet.appbarBackgroundColor)
        appbarView.backgroundColor = .clear
        appbarView.configure(cornerRadius: 28, roundCorners: [.bottomRight])
        appbarView.setAppbarShadow()
        appbarTitleLabel.hero.id = "appbarTitle"
        
        // Appbar Height
        DispatchQueue.main.async {
            self.minimumAppbarHeight = 80 + SafeAreaInset.top
            self.maximumAppbarHeight = 140 + SafeAreaInset.top
            self.appbarViewHeightConstraint.constant = AppbarHeight.maximum
            
            // Main content ScrollView
            self.mainContentScrollView.contentInset = UIEdgeInsets(top: self.appbarViewHeightConstraint.constant,
                                                                   left: 0,
                                                                   bottom: 0,
                                                                   right: 0)
            self.mainContentScrollView.scrollToTop(animated: true)
        }
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
    
    private func setupUpdatedSongTableView() {
        updatedSongTableView.layer.cornerRadius = 12
        updatedSongTableView.tableFooterView = UIView()
        updatedSongTableView.separatorStyle = .none
        
        let nibName = UINib(nibName: "UpdatedSongTableViewCell", bundle: nil)
        updatedSongTableView.register(nibName, forCellReuseIdentifier: "updatedSongTableViewCell")
        updatedSongTableView.delegate = self
        updatedSongTableView.dataSource = self
        setUpdatedSongChart()
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
                let changedY = offset.y + vc.maximumAppbarHeight
                
                if -vc.maximumAppbarHeight < offset.y {
                    // Shrink Appbar
                    if vc.maximumAppbarHeight - changedY >= vc.minimumAppbarHeight {
                        let modifiedAppbarHeight: CGFloat = vc.maximumAppbarHeight - changedY
                        vc.appbarViewHeightConstraint.constant = modifiedAppbarHeight
                        
                        let appbarTitleLabelAlpha: CGFloat = 1 - (vc.maximumAppbarHeight - modifiedAppbarHeight) / (vc.maximumAppbarHeight - vc.minimumAppbarHeight)
                        vc.appbarTitleLabel.alpha = appbarTitleLabelAlpha
                        vc.settingButton.alpha = appbarTitleLabelAlpha
                    } else {
                        vc.appbarViewHeightConstraint.constant = vc.minimumAppbarHeight
                        vc.appbarTitleLabel.alpha = 0
                        vc.settingButton.alpha = 0
                    }
                } else {
                    // Stretch Appbar
                    vc.appbarViewHeightConstraint.constant = vc.maximumAppbarHeight - changedY * 0.2
                    vc.appbarTitleLabel.alpha = 1
                    vc.settingButton.alpha = 1
                }
            }).disposed(by: disposeBag)
    }
    
    private func bindUpdatedSongTableView() {
        updatedSongTableView.rx.itemSelected
            .asDriver()
            .drive(with: self, onNext: { vc, indexPath in
                let selectedSong = vc.viewModel.updatedSongAtIndex(indexPath)
                vc.showArchiveFolderFloatingView(selectedSong)
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Methods
    func presentSearchVC() {
        guard let searchVC = storyboard?.instantiateViewController(identifier: "searchStoryboard") as? SearchViewController else {
            return
        }
        
        searchVC.modalPresentationStyle = .fullScreen
        present(searchVC, animated: true, completion: nil)
    }
    
    func presentArchiveFolderVC() {
        guard let archiveVC = storyboard?.instantiateViewController(identifier: "archiveFolderListStoryboard") as? ArchiveFolderListViewController else {
            return
        }
        
        archiveVC.modalPresentationStyle = .fullScreen
        present(archiveVC, animated: true, completion: nil)
    }
    
    func presentSettingVC() {
        guard let settingVC = storyboard?.instantiateViewController(withIdentifier: "settingStoryboard") as? SettingViewController else {
            return
        }
        
        present(settingVC, animated: true, completion: nil)
    }
    
    private func setUpdatedSongChart() {
        updatedSongLoadingIndicator.startAnimatingAndShow()
        updatedsongLoadErrorMessageLabel.isHidden = true
        clearUpdatedSongTableView()

        viewModel.fetchUpdatedSong(brand: updatedSongBrand)
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onCompleted: { vc in
                vc.reloadUpdateChartTableView()
            }, onError: { vc, error in
                vc.updatedSongLoadingIndicator.stopAnimatingAndHide()
                vc.updatedsongLoadErrorMessageLabel.text = "오류가 발생했습니다."
                vc.updatedsongLoadErrorMessageLabel.isHidden = false
            }).disposed(by: disposeBag)
    }
    
    private func reloadUpdateChartTableView() {
        updatedSongLoadingIndicator.stopAnimatingAndHide()
        updatedSongTableView.reloadData()
        
        if viewModel.updatedSongCount == 0 {
            updatedsongLoadErrorMessageLabel.text = "업데이트 된 곡이 없습니다."
            updatedsongLoadErrorMessageLabel.isHidden = false
            return
        }
        
        updatedSongTableView.scrollToTopCell(animated: false)
    }
    
    private func updateTotalSavedSongSize() {
        totalArchivedSongSizeLabel.text = viewModel.savedSongSizeString
    }
    
    private func requestTrackingAuthorization() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
    }
    
    private func clearUpdatedSongTableView() {
        viewModel.clearUpdatedSong()
        updatedSongTableView.reloadData()
    }
    
    private func hideSplashView() {
        splashView.hide { [weak self] in
            self?.updatedSongTableView.flashScrollIndicators()
        }
    }
    
    private func showArchiveFolderFloatingView(_ selectedSong: Song) {
        archiveFolderFloatingView?.hide(animated: false)
        archiveFolderFloatingView = ArchiveFolderFloatingPanelView(parentViewController: self, delegate: self)
        archiveFolderFloatingView?.show(selectedSong)
        
    }
}

// MARK: - Extensions
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(viewModel.sectionCount)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let updatedSongCell = tableView.dequeueReusableCell(withIdentifier: "updatedSongTableViewCell") as? UpdatedSongTableViewCell else { return UITableViewCell() }
        
        let updatedSongVM = viewModel.updatedSongAtIndex(indexPath)
        
        updatedSongCell.songTitleLabel.text   = "\(updatedSongVM.title)"
        updatedSongCell.singerLabel.text      = "\(updatedSongVM.singer)"
        updatedSongCell.songNumberLabel.text  = "\(updatedSongVM.no)"
        
        return updatedSongCell
    }
}

extension MainViewController: BISegmentedControlDelegate {
    func BISegmentedControl(didSelectSegmentAt index: Int) {
        setUpdatedSongChart()
    }
}

extension MainViewController: PopUpArchiveFolderViewDelegate {
    func didSongAdded() {
        archiveFolderFloatingView?.hide(animated: true)
        totalArchivedSongSizeLabel.text = viewModel.savedSongSizeString
    }
}

extension MainViewController: ArchiveFolderListViewDelegate {
    func didFileChanged() {
        totalArchivedSongSizeLabel.text = viewModel.savedSongSizeString
    }
}

