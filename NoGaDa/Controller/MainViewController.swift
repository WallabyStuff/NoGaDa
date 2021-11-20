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
    var disposeBag = DisposeBag()
    let splashView = SplashView()
    var archiveFloatingPanel: ArchiveFloatingPanelView?
    let mainViewModel = MainViewModel()
    var updatedSongBrand: KaraokeBrand {
        if brandSegmentedControl.currentPosition == 0 {
            return .tj
        } else {
            return .kumyoung
        }
    }
    
    var minimumAppbarHeight: CGFloat = 80
    var maximumAppbarHeight: CGFloat = 140
    
    @IBOutlet weak var appbarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var appbarView: AppbarView!
    @IBOutlet weak var appbarTitleLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var mainContentScrollView: UIScrollView!
    @IBOutlet weak var mainContentScrollViewContentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var archiveShortcutView: ArchiveShortcutView!
    @IBOutlet weak var archiveShortcutBackgroundImageView: UIImageView!
    @IBOutlet weak var totalArchivedSongSizeLabel: UILabel!
    @IBOutlet weak var searchBoxView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var brandSegmentedControl: BISegmentedControl!
    @IBOutlet weak var updatedSongTableView: UITableView!
    @IBOutlet weak var updatedsongLoadErrorMessageLabel: UILabel!
    @IBOutlet weak var updatedSongLoadingIndicator: UIActivityIndicatorView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        splashView.show(vc: self)
        initView()
        initInstance()
        initEventListener()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        splashView.hide()
        updateTotalSavedSongSize()
        requestTrackingAuthorization()
        updatedSongTableView.flashScrollIndicators()
    }
    
    // MARK: - Override
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        reloadUpdateChartTableView()
    }

    // MARK: - Initialization
    private func initView() {
        self.hero.isEnabled = true
        
        view.fillStatusBar(color: ColorSet.appbarBackgroundColor)
        
        // Appbar View
        appbarView.backgroundColor = .clear
        appbarView.configure(cornerRadius: 28, roundCorners: [.bottomRight])
        appbarView.setAppbarShadow()
        
        // Appbar title Label
        appbarTitleLabel.hero.id = "appbarTitle"
        
        // Setting Button
        settingButton.setPadding(width: 4)
        
        // Main content ScrollView content View
        mainContentScrollViewContentViewHeightConstraint.constant = view.frame.height
        
        // Search TextField
        searchBoxView.hero.id = "searchBox"
        searchBoxView.layer.cornerRadius = 12
        searchBoxView.setSearchBoxShadow()
        
        // Search Button
        searchButton.hero.id = "searchBoxButton"
        searchButton.layer.cornerRadius = 8
        searchButton.setSearchBoxButtonShadow()
        
        // Archive shortcut background ImageView
        archiveShortcutBackgroundImageView.layer.cornerRadius = 20
        archiveShortcutBackgroundImageView.layer.maskedCorners = [.layerMinXMaxYCorner]
        
        // Chart TableView
        updatedSongTableView.layer.cornerRadius = 12
        updatedSongTableView.tableFooterView = UIView()
        updatedSongTableView.separatorStyle = .none
        
        // Karaoke brand segmented control
        brandSegmentedControl.segmentTintColor = ColorSet.updatedSongSelectorSelectedTextColor
        brandSegmentedControl.segmentDefaultColor = ColorSet.updatedSongSelectorUnSelectedTextColor
        brandSegmentedControl.barIndicatorColor = ColorSet.updatedSongSelectorBarIndicatorColor
        brandSegmentedControl.barIndicatorHeight = 3
        brandSegmentedControl.segmentFontSize = 14
        brandSegmentedControl.addSegment(title: "tj 업데이트")
        brandSegmentedControl.addSegment(title: "금영 업데이트")
        
        DispatchQueue.main.async {
            // Appbar Height
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
    
    private func initInstance() {
        // Chart TableView
        let chartTableCellNibName = UINib(nibName: "UpdatedSongTableViewCell", bundle: nil)
        updatedSongTableView.register(chartTableCellNibName, forCellReuseIdentifier: "updatedSongTableViewCell")
        updatedSongTableView.delegate = self
        updatedSongTableView.dataSource = self
        
        setUpdatedSongChart()
        
        // Karaoke brand segmented control
        brandSegmentedControl.delegate = self
        
        // Archive floating panel
        archiveFloatingPanel = ArchiveFloatingPanelView(vc: self)
        archiveFloatingPanel?.successfullyAddedAction = { [weak self] in
            self?.updateTotalSavedSongSize()
        }
    }
    
    private func initEventListener() {
        // Search Textfield Tap Action
        searchBoxView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { vc, _ in
                vc.presentSearchVC()
                vc.archiveFloatingPanel?.hide(animated: true)
            }.disposed(by: disposeBag)
        
        // Search Textfield LongPress Action
        searchBoxView.rx.longPressGesture()
            .when(.began)
            .bind(with: self) { vc, _ in
                vc.presentSearchVC()
                vc.archiveFloatingPanel?.hide(animated: true)
            }.disposed(by: disposeBag)
        
        // Search Button Tap Action
        searchButton.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { vc, _ in
                vc.presentSearchVC()
                vc.archiveFloatingPanel?.hide(animated: true)
            }.disposed(by: disposeBag)
        
        // Archive Shortcut Tap Action
        archiveShortcutView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { vc, _ in
                vc.presentArchiveVC()
                vc.archiveFloatingPanel?.hide(animated: true)
            }.disposed(by: disposeBag)
        
        // Setting Button Tap Action
        settingButton.rx.tap
            .bind(with: self, onNext: { vc, _ in
                vc.presentSettingVC()
            }).disposed(by: disposeBag)
        
        // Main content ScrollView Slide Action
        mainContentScrollView.rx.contentOffset
            .subscribe(with: self, onNext: { vc, offset in
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
    
    // MARK: - Method
    func presentSearchVC() {
        guard let searchVC = storyboard?.instantiateViewController(identifier: "searchStoryboard") as? SearchViewController else {
            return
        }
        
        searchVC.modalPresentationStyle = .fullScreen
        present(searchVC, animated: true, completion: nil)
    }
    
    func presentArchiveVC() {
        guard let archiveVC = storyboard?.instantiateViewController(identifier: "archiveStoryboard") as? SongFolderListViewController else {
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

        mainViewModel.fetchUpdatedSong(brand: updatedSongBrand)
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
        
        if mainViewModel.updatedSongCount == 0 {
            updatedsongLoadErrorMessageLabel.text = "업데이트 된 곡이 없습니다."
            updatedsongLoadErrorMessageLabel.isHidden = false
            return
        }
        
        updatedSongTableView.scrollToTopCell(animated: false)
    }
    
    private func updateTotalSavedSongSize() {
        totalArchivedSongSizeLabel.text = mainViewModel.savedSongSizeString
    }
    
    private func requestTrackingAuthorization() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in }
        }
    }
    
    func clearUpdatedSongTableView() {
        mainViewModel.clearUpdatedSong()
        updatedSongTableView.reloadData()
    }
}

// MARK: - Extension
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainViewModel.numberOfRowsInSection(mainViewModel.sectionCount)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let updatedSongCell = tableView.dequeueReusableCell(withIdentifier: "updatedSongTableViewCell") as? UpdatedSongTableViewCell else { return UITableViewCell() }
        
        let updatedSongVM = mainViewModel.updatedSongAtIndex(indexPath)
        
        updatedSongCell.songTitleLabel.text   = "\(updatedSongVM.title)"
        updatedSongCell.singerLabel.text      = "\(updatedSongVM.singer)"
        updatedSongCell.songNumberLabel.text  = "\(updatedSongVM.songNumber)"
        
        return updatedSongCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let updatedSongVM = mainViewModel.updatedSongAtIndex(indexPath)
        archiveFloatingPanel?.show(selectedSong: updatedSongVM.song, animated: true)
    }
}

extension MainViewController: BISegmentedControlDelegate {
    func BISegmentedControl(didSelectSegmentAt index: Int) {
        setUpdatedSongChart()
    }
}
