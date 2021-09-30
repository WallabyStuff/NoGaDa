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
import FloatingPanel

class ViewController: UIViewController {

    // MARK: Declaration
    var disposeBag = DisposeBag()
    let archiveFloatingPanel = FloatingPanelController()
    let karaokeManager = KaraokeManager()
    var updatedSongArr = [Song]()
    let archiveFolderManager = ArchiveFolderManager()
    
    var minimumAppbarHeight: CGFloat = 80
    var maximumAppbarHeight: CGFloat = 140
    
    @IBOutlet weak var appbarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var appbarView: AppbarView!
    @IBOutlet weak var appbarTitleLabel: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var mainContentScrollView: UIScrollView!
    @IBOutlet weak var mainContentScrollViewContentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var archiveShortcutView: UIView!
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
        
        initView()
        initInstance()
        initEventListener()
    }
    
    // MARK: - Override
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setUpdatedSongChart()
    }

    // MARK: - Initialization
    private func initView() {
        self.hero.isEnabled = true
        
        // Appbar View
        appbarView.backgroundColor = .clear
        appbarView.configure(cornerRadius: 28, roundCorners: [.bottomRight])
        appbarView.setAppbarShadow()
        
        // Appbar Height
        DispatchQueue.main.async {
            self.minimumAppbarHeight = 80 + SafeAreaInset.top
            self.maximumAppbarHeight = 140 + SafeAreaInset.top
            self.appbarViewHeightConstraint.constant = AppbarHeight.maximum
        }
        
        // Appbar title Label
        appbarTitleLabel.hero.id = "appbarTitle"
        
        // Setting Button
        settingButton.setPadding(width: 6)
        
        // Main content ScrollView
        DispatchQueue.main.async {
            self.mainContentScrollView.contentInset = UIEdgeInsets(top: self.appbarViewHeightConstraint.constant, left: 0, bottom: 0, right: 0)
            self.mainContentScrollView.scrollToTop(animated: false)
        }
        
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
        
        // Archive Shortcut View (Button)
        archiveShortcutView.layer.cornerRadius = 20
        archiveShortcutView.setArchiveShortCutShadow()
        
        // Archive shortcut background ImageView
        archiveShortcutBackgroundImageView.layer.cornerRadius = 20
        archiveShortcutBackgroundImageView.layer.maskedCorners = [.layerMinXMaxYCorner]
        
        // Total archived song size Label
        totalArchivedSongSizeLabel.text = "총 \(archiveFolderManager.getSongsCount())곡"
        
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
    }
    
    private func initInstance() {
        // Chart TableView
        let chartTableCellNibName = UINib(nibName: "ChartTableViewCell", bundle: nil)
        updatedSongTableView.register(chartTableCellNibName, forCellReuseIdentifier: "chartTableViewCell")
        updatedSongTableView.delegate = self
        updatedSongTableView.dataSource = self
        
        setUpdatedSongChart()
        
        // Karaoke brand segmented control
        brandSegmentedControl.delegate = self
    }
    
    private func initEventListener() {
        // Search Textfield Tap Action
        searchBoxView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { vc, _ in
                vc.presentSearchVC()
                vc.archiveFloatingPanel.hide(animated: true)
            }.disposed(by: disposeBag)
        
        // Search Textfield LongPress Action
        searchBoxView.rx.longPressGesture()
            .when(.began)
            .bind(with: self) { vc, _ in
                vc.presentSearchVC()
                vc.archiveFloatingPanel.hide(animated: true)
            }.disposed(by: disposeBag)
        
        // Search Button Tap Action
        searchButton.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { vc, _ in
                vc.presentSearchVC()
                vc.archiveFloatingPanel.hide(animated: true)
            }.disposed(by: disposeBag)
        
        // Archive Shortcut Tap Action
        archiveShortcutView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { vc, _ in
                vc.presentArchiveVC()
                vc.archiveFloatingPanel.hide(animated: true)
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
        guard let searchVC = storyboard?.instantiateViewController(identifier: "searchStoryboard") as? SearchViewController else { return }
        searchVC.modalPresentationStyle = .fullScreen
        
        present(searchVC, animated: true, completion: nil)
    }
    
    func presentArchiveVC() {
        guard let archiveVC = storyboard?.instantiateViewController(identifier: "archiveStoryboard") as? ArchiveViewController else { return }
        archiveVC.modalPresentationStyle = .fullScreen
        
        present(archiveVC, animated: true, completion: nil)
    }
    
    func presentSettingVC() {
        guard let settingVC = storyboard?.instantiateViewController(withIdentifier: "settingStoryboard") as? SettingViewController else { return }
        
        present(settingVC, animated: true, completion: nil)
    }
    
    private func configurePopUpArchivePanel(selectedSong: Song) {
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 32
        
        archiveFloatingPanel.removeFromParent()
        archiveFloatingPanel.contentMode = .fitToBounds
        archiveFloatingPanel.backdropView.dismissalTapGestureRecognizer.isEnabled = true
        archiveFloatingPanel.surfaceView.appearance = appearance
        archiveFloatingPanel.surfaceView.grabberHandle.barColor = ColorSet.floatingPanelHandleColor
        archiveFloatingPanel.layout = PopUpArchiveFloatingPanelLayout()
        
        guard let popUpArchiveVC = storyboard?.instantiateViewController(identifier: "popUpArchiveStoryboard") as? PopUpArchiveViewController else { return }
        popUpArchiveVC.delegate = self
        popUpArchiveVC.selectedSong = selectedSong
        popUpArchiveVC.exitButtonAction = { [weak self] in
            self?.archiveFloatingPanel.hide(animated: true)
        }
        archiveFloatingPanel.set(contentViewController: popUpArchiveVC)
        archiveFloatingPanel.addPanel(toParent: self)
    }
    
    private func showPopUpArchivePanel(selectedSong: Song) {
        configurePopUpArchivePanel(selectedSong: selectedSong)
        archiveFloatingPanel.show(animated: true, completion: nil)
        archiveFloatingPanel.move(to: .half, animated: true)
    }
    
    private func setUpdatedSongChart() {
        var brand: KaraokeBrand = .tj
        if brandSegmentedControl.currentPosition != 0 {
            brand = .kumyoung
        }
        
        updatedSongLoadingIndicator.startAnimatingAndShow()
        updatedsongLoadErrorMessageLabel.isHidden = true
        updatedSongArr.removeAll()
        updatedSongTableView.reloadData()
        
        karaokeManager.fetchUpdatedSong(brand: brand)
            .retry(3)
            .subscribe(with: self, onNext: { vc, updatedSongList in
                DispatchQueue.main.async {
                    vc.updatedSongArr = updatedSongList
                    vc.reloadChartTableView()
                }
            }, onError: { vc, error in
                DispatchQueue.main.async {
                    vc.updatedSongLoadingIndicator.stopAnimatingAndHide()
                    vc.updatedsongLoadErrorMessageLabel.text = "오류가 발생했습니다."
                    vc.updatedsongLoadErrorMessageLabel.isHidden = false
                }
            }).disposed(by: disposeBag)
    }
    
    private func reloadChartTableView() {
        updatedSongLoadingIndicator.stopAnimatingAndHide()
        updatedSongTableView.reloadData()
        updatedSongTableView.scrollToTopCell(animated: false)
        
        if updatedSongArr.count == 0 {
            updatedsongLoadErrorMessageLabel.text = "업데이트 된 곡이 없습니다."
            updatedsongLoadErrorMessageLabel.isHidden = false
        }
    }
}

// MARK: - Extension
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updatedSongArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let chartCell = tableView.dequeueReusableCell(withIdentifier: "chartTableViewCell") as? ChartTableViewCell else { return UITableViewCell() }
        
        chartCell.chartNumberLabel.text = "\(indexPath.row + 1)"
        chartCell.songTitleLabel.text   = "\(updatedSongArr[indexPath.row].title)"
        chartCell.singerLabel.text      = "\(updatedSongArr[indexPath.row].singer)"
        
        return chartCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showPopUpArchivePanel(selectedSong: updatedSongArr[indexPath.row])
    }
}

extension ViewController: BISegmentedControlDelegate {
    func BISegmentedControl(didSelectSegmentAt index: Int) {
        setUpdatedSongChart()
    }
}

extension ViewController: PopUpArchiveViewDelegate {
    func popUpArchiveView(isSuccessfullyAdded: Bool) {
        archiveFloatingPanel.hide(animated: true)
    }
}
