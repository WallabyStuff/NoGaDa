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
    var updatedSongList = [Song]()
    
    @IBOutlet weak var archiveShortcutView: UIView!
    @IBOutlet weak var searchBoxView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var brandSegmentedControl: BISegmentedControl!
    @IBOutlet weak var chartTableView: UITableView!
    @IBOutlet weak var chartLoadErrorMessageLabel: UILabel!
    @IBOutlet weak var chartLoadingIndicator: UIActivityIndicatorView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initInstance()
        initEventListener()
    }
    
    // MARK: - Override
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    // MARK: - Initialization
    private func initView() {
        self.hero.isEnabled = true
        
        // Search TextField
        searchBoxView.hero.id = "searchBar"
        searchBoxView.layer.cornerRadius = 12
        
        // Search Button
        searchButton.hero.id = "searchButton"
        searchButton.layer.cornerRadius = 8
        
        // Archive Shortcut View (Button)
        archiveShortcutView.layer.cornerRadius = 20
        
        // Chart TableView
        chartTableView.layer.cornerRadius = 12
        chartTableView.tableFooterView = UIView()
        chartTableView.separatorStyle = .none
        
        // Karaoke brand segmented control
        brandSegmentedControl.segmentTintColor = .black
        brandSegmentedControl.segmentDefaultColor = .gray
        brandSegmentedControl.barIndicatorColor = ColorSet.pointColor
        brandSegmentedControl.barIndicatorHeight = 3
        brandSegmentedControl.segmentFontSize = 14
        brandSegmentedControl.addSegment(title: "tj 업데이트")
        brandSegmentedControl.addSegment(title: "금영 업데이트")
    }
    
    private func initInstance() {
        // Chart TableView
        let chartTableCellNibName = UINib(nibName: "ChartTableViewCell", bundle: nil)
        chartTableView.register(chartTableCellNibName, forCellReuseIdentifier: "chartTableViewCell")
        chartTableView.delegate = self
        chartTableView.dataSource = self
        
        setUpdatedSongChart(brand: .tj)
        
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
    
    private func configurePopUpArchivePanel(selectedSong: Song) {
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 32
        appearance.setPanelShadow(color: ColorSet.floatingPanelShadowColor)
        
        archiveFloatingPanel.removeFromParent()
        archiveFloatingPanel.isRemovalInteractionEnabled = true
        archiveFloatingPanel.contentMode = .fitToBounds
        archiveFloatingPanel.surfaceView.appearance = appearance
        archiveFloatingPanel.surfaceView.grabberHandle.barColor = ColorSet.accentSubColor
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
    
    private func setUpdatedSongChart(brand: KaraokeBrand) {
        chartLoadingIndicator.startAnimatingAndShow()
        chartLoadErrorMessageLabel.isHidden = true
        
        karaokeManager.fetchUpdatedSong(brand: brand)
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { vc, updatedSongList in
                vc.updatedSongList = updatedSongList
                vc.reloadChartTableView()
            }, onError: { vc, error in
                vc.chartLoadingIndicator.stopAnimatingAndHide()
                vc.chartLoadErrorMessageLabel.text = "오류가 발생했습니다."
                vc.chartLoadErrorMessageLabel.isHidden = false
            }).disposed(by: disposeBag)
    }
    
    private func reloadChartTableView() {
        chartLoadingIndicator.stopAnimatingAndHide()
        chartTableView.reloadData()
        
        if updatedSongList.count == 0 {
            chartLoadErrorMessageLabel.text = "업데이트 된 곡이 없습니다."
            chartLoadErrorMessageLabel.isHidden = false
        }
    }
}

// MARK: - Extension
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updatedSongList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let chartCell = tableView.dequeueReusableCell(withIdentifier: "chartTableViewCell") as? ChartTableViewCell else { return UITableViewCell() }
        
        chartCell.chartNumberLabel.text = "\(indexPath.row + 1)"
        chartCell.songTitleLabel.text   = "\(updatedSongList[indexPath.row].title)"
        chartCell.singerLabel.text      = "\(updatedSongList[indexPath.row].singer)"
        
        return chartCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showPopUpArchivePanel(selectedSong: updatedSongList[indexPath.row])
    }
}

extension ViewController: BISegmentedControlDelegate {
    func BISegmentedControl(didSelectSegmentAt index: Int) {
        if index == 0 {
            setUpdatedSongChart(brand: .tj)
        } else {
            setUpdatedSongChart(brand: .kumyoung)
        }
    }
}

extension ViewController: PopUpArchiveViewDelegate {
    func popUpArchiveView(successfullyAdded: Song) {
        archiveFloatingPanel.hide(animated: true)
    }
}
