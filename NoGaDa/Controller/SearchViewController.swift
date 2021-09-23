//
//  SearchViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture
import FloatingPanel
import Hero

class SearchViewController: UIViewController {

    // MARK: - Declaraiton
    var disposeBag = DisposeBag()
    let archiveFloatingPanel = FloatingPanelController()
    var karaokeManager = KaraokeManager()
    var searchResultArr = [Song]()
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var brandSelector: UISegmentedControl!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet weak var noSearchResultLabel: UILabel!
    @IBOutlet weak var searchIndicator: UIActivityIndicatorView!
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - Initialization
    private func initView() {
        self.hero.isEnabled = true
        
        // Search TextField
        searchTextField.hero.id = "searchBar"
        searchTextField.layer.cornerRadius = 12
        searchTextField.setPlaceholderColor(ColorSet.searchBarPlaceholderColor)
        searchTextField.setLeftPadding(width: 12)
        searchTextField.setRightPadding(width: 52)
        searchTextField.layer.shadowColor = ColorSet.searchbarShadowColor.cgColor
        searchTextField.layer.shadowOffset = .zero
        searchTextField.layer.shadowRadius = 20
        searchTextField.layer.shadowOpacity = 1
        
        // Search Button
        filterButton.hero.id = "searchButton"
        filterButton.layer.cornerRadius = 8
        filterButton.setPadding(width: 8)
        
        // Brand Selector SegmentedControl
        brandSelector.setTextColor(color: ColorSet.segmentedControlTextColor)
        
        // Exit Button
        exitButton.makeAsCircle()
        
        // SearchResult TableView
        searchResultTableView.tableFooterView = UIView()
        searchResultTableView.separatorStyle = .none
        searchResultTableView.layer.cornerRadius = 12
        
        // Search loading IndicatorView
        searchIndicator.stopAnimatingAndHide()
    }
    
    private func initInstance() {
        // SearchResult TableView
        let searchResultCellNibName = UINib(nibName: "SongTableViewCell", bundle: nil)
        searchResultTableView.register(searchResultCellNibName, forCellReuseIdentifier: "searchResultTableViewCell")
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        
        // Search TextField
        searchTextField.delegate = self
        searchTextField.becomeFirstResponder()
    }
    
    private func initEventListener() {
        // Exit Button Tap Action
        exitButton.rx.tap
            .bind(with: self) { vc, _ in
                vc.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
        
        // Filter Button Tap Action
        filterButton.rx.tap
            .bind(with: self) { vc, _ in
                vc.presentSearchFilterPopoverVC()
            }.disposed(by: disposeBag)
        
        // Search TextField Tap Action
        searchTextField.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { vc, _ in
                vc.archiveFloatingPanel.hide(animated: true)
            }.disposed(by: disposeBag)
        
        // Brand Segmented Control Action
        brandSelector.rx.selectedSegmentIndex
            .bind(with: self) { vc, _ in
                // TODO - replace table cells according to brand catalog
                vc.setSearchResult()
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Method
    private func showPopUpArchivePanel(selectedSong: Song) {
        configurePopUpArchivePanel(selectedSong: selectedSong)
        archiveFloatingPanel.show(animated: true, completion: nil)
        archiveFloatingPanel.move(to: .half, animated: true)
    }
    
    private func dismissKeyboardAndArchivePanel() {
        view.endEditing(true)
        archiveFloatingPanel.hide(animated: true)
    }
    
    private func setSearchResult() {
        dismissKeyboardAndArchivePanel()
        
        var brand: KaraokeBrand = .tj
        if brandSelector.selectedSegmentIndex == 1 {
            brand = .kumyoung
        }
        
        let titleOrSinger = searchTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if titleOrSinger.isEmpty { return }
        
        if !SearchFilterItem.searchWithTitle.state && !SearchFilterItem.searchWithSinger.state {
            presentSearchFilterPopoverVC()
            return
        }
        
        searchIndicator.startAnimatingAndShow()
        noSearchResultLabel.isHidden = true
        
        karaokeManager.fetchSong(titleOrSinger: titleOrSinger, brand: brand)
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { vc, searchResultList in
                vc.searchResultArr = searchResultList
                vc.reloadSearchResult()
            }, onError: { vc, error in
                print(error)
                vc.searchIndicator.stopAnimatingAndHide()
                vc.noSearchResultLabel.isHidden = false
            }).disposed(by: disposeBag)
    }
    
    private func reloadSearchResult() {
        searchIndicator.stopAnimatingAndHide()
        searchResultTableView.reloadData()
        
        if searchResultArr.count == 0 { noSearchResultLabel.isHidden = false }
    }
    
    func presentSearchFilterPopoverVC() {
        guard let searchFilterVC = storyboard?.instantiateViewController(identifier: "popOverSearchFilterStoryboard") as? PopOverSearchFilterViewController else { return }
        
        searchFilterVC.modalPresentationStyle = .popover
        searchFilterVC.preferredContentSize = CGSize(width: 240, height: 100)
        searchFilterVC.popoverPresentationController?.permittedArrowDirections = .up
        searchFilterVC.popoverPresentationController?.sourceRect = filterButton.bounds
        searchFilterVC.popoverPresentationController?.sourceView = filterButton
        searchFilterVC.presentationController?.delegate = self
        
        present(searchFilterVC, animated: true, completion: nil)
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
    
}

// MARK: - Extension
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let searchResultCell = tableView.dequeueReusableCell(withIdentifier: "searchResultTableViewCell") as? SongTableViewCell else { return UITableViewCell() }
        
        searchResultCell.titleLabel.text        = searchResultArr[indexPath.row].title
        searchResultCell.singerLabel.text       = searchResultArr[indexPath.row].singer
        searchResultCell.songNumberLabel.text   = searchResultArr[indexPath.row].no
        
        searchResultCell.titleLabel.setAccentColor(string: searchTextField.text?.trimmingCharacters(in: .whitespaces) ?? "")
        searchResultCell.singerLabel.setAccentColor(string: searchTextField.text?.trimmingCharacters(in: .whitespaces) ?? "")
        
        return searchResultCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        showPopUpArchivePanel(selectedSong: searchResultArr[indexPath.row])
    }
}

extension SearchViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboardAndArchivePanel()
    }
}

extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        setSearchResult()
        return false
    }
}

extension SearchViewController: PopUpArchiveViewDelegate {
    func popUpArchiveView(successfullyAdded: Song) {
        archiveFloatingPanel.hide(animated: true)
    }
}

extension UIViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
