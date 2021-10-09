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
import Hero

class SearchViewController: UIViewController {

    // MARK: - Declaraiton
    var disposeBag = DisposeBag()
    var karaokeManager = KaraokeManager()
    var searchResultArr = [Song]()
    var searchKeyword = ""
    var archiveFloatingPanel: ArchiveFloatingPanel?
    
    @IBOutlet weak var appbarView: UIView!
    @IBOutlet weak var appbarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var appbarTitleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var brandSelector: UISegmentedControl!
    @IBOutlet weak var searchBoxView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var clearTextFieldButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var searchResultContentView: UIView!
    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet weak var searchResultPlaceholderLabel: UILabel!
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
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        setSearchResult()
    }

    // MARK: - Initialization
    private func initView() {
        self.hero.isEnabled = true
        
        view.fillStatusBar(color: ColorSet.appbarBackgroundColor)
        
        // Appbar
        appbarView.hero.id = "appbar"
        appbarView.layer.cornerRadius = 28
        appbarView.layer.cornerCurve = .circular
        appbarView.layer.maskedCorners = CACornerMask([.layerMinXMaxYCorner])
        appbarView.setAppbarShadow()
        
        // Appbar height constraint
        appbarViewHeightConstraint.constant = 140 + SafeAreaInset.top
        
        // Appbar Title Label
        appbarTitleLabel.hero.id = "appbarTitle"
        
        // SearchBox View
        searchBoxView.hero.id = "searchBox"
        searchBoxView.layer.cornerRadius = 12
        searchBoxView.layer.masksToBounds = true
        searchBoxView.setSearchBoxShadow()
        
        // Search result ContentView
        searchResultContentView.clipsToBounds = true
        searchResultContentView.layer.cornerRadius = 12
        
        // Search TextField
        searchTextField.setPlaceholderColor(ColorSet.appbarTextfieldPlaceholderColor)
        searchTextField.setLeftPadding(width: 12)
        searchTextField.setRightPadding(width: 80)
        
        // Search Button
        filterButton.hero.id = "searchBoxButton"
        filterButton.layer.cornerRadius = 8
        filterButton.setPadding(width: 8)
        filterButton.setSearchBoxButtonShadow()
        
        // Brand Selector SegmentedControl
        brandSelector.setSelectedTextColor(ColorSet.segmentedControlSelectedTextColor)
        brandSelector.setDefaultTextColor(ColorSet.segmentedControlDefaultTextColor)
        
        // Back Button
        backButton.hero.modifiers = [.fade]
        backButton.setPadding(width: 6)
        
        // SearchResult TableView
        searchResultTableView.tableFooterView = UIView()
        searchResultTableView.separatorStyle = .none
        searchResultTableView.layer.cornerRadius = 16
        
        // Search loading IndicatorView
        searchIndicator.stopAnimatingAndHide()
        
        // Clear search textfield Button
        clearTextFieldButton.setPadding(width: 6)
        
        // Search result placeholder label
        searchResultPlaceholderLabel.text = "검색창에 제목 또는 가수명으로 노래를 검색하세요!"
        searchResultPlaceholderLabel.isHidden = false
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
        
        // Archive floating panel
        archiveFloatingPanel = ArchiveFloatingPanel(vc: self)
    }
    
    private func initEventListener() {
        // Exit Button Tap Action
        backButton.rx.tap
            .bind(with: self) { vc, _ in
                vc.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
        
        // Filter Button Tap Action
        filterButton.rx.tap
            .bind(with: self) { vc, _ in
                vc.presentSearchFilterPopoverVC()
            }.disposed(by: disposeBag)
        
        // Brand Segmented Control Action
        brandSelector.rx.selectedSegmentIndex
            .bind(with: self) { vc, _ in
                // TODO - replace table cells according to brand catalog
                vc.setSearchResult()
            }.disposed(by: disposeBag)
        
        // Clear TextField Button Tap Action
        clearTextFieldButton.rx.tap
            .bind(with: self, onNext: { vc, _ in
                vc.searchTextField.text = ""
                vc.searchTextField.becomeFirstResponder()
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Method
    private func dismissKeyboardAndArchivePanel() {
        view.endEditing(true)
        archiveFloatingPanel?.hide(animated: true)
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
        searchKeyword = titleOrSinger
        searchResultPlaceholderLabel.isHidden = true
        searchResultArr.removeAll()
        searchResultTableView.reloadData()
        
        karaokeManager.fetchSong(titleOrSinger: titleOrSinger, brand: brand)
            .retry(3)
            .subscribe(with: self, onNext: { vc, searchResultList in
                DispatchQueue.main.async {
                    vc.searchResultArr = searchResultList
                    vc.reloadSearchResult()
                }
            }, onError: { vc, error in
                DispatchQueue.main.async {
                    vc.searchIndicator.stopAnimatingAndHide()
                    vc.searchResultPlaceholderLabel.text = "오류가 발생했습니다."
                    vc.searchResultPlaceholderLabel.isHidden = false
                }
            }).disposed(by: disposeBag)
    }
    
    private func reloadSearchResult() {
        searchIndicator.stopAnimatingAndHide()
        searchResultTableView.reloadData()
        
        if searchResultArr.count == 0 {
            searchResultPlaceholderLabel.text = "검색 결과가 없습니다."
            searchResultPlaceholderLabel.isHidden = false
            return
        }
        
        searchResultTableView.scrollToTopCell(animated: false)
    }
    
    func presentSearchFilterPopoverVC() {
        guard let searchFilterVC = storyboard?.instantiateViewController(identifier: "popOverSearchFilterStoryboard") as? PopOverSearchFilterViewController else { return }
        
        searchFilterVC.navigationController?.popoverPresentationController?.backgroundColor = .white
        searchFilterVC.delegate = self
        searchFilterVC.modalPresentationStyle = .popover
        searchFilterVC.preferredContentSize = CGSize(width: 240, height: 160)
        searchFilterVC.popoverPresentationController?.permittedArrowDirections = .up
        searchFilterVC.popoverPresentationController?.sourceRect = filterButton.bounds
        searchFilterVC.popoverPresentationController?.sourceView = filterButton
        searchFilterVC.presentationController?.delegate = self
        
        present(searchFilterVC, animated: true, completion: nil)
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
        searchResultCell.brandLabel.text        = searchResultArr[indexPath.row].brand.localizedString
        
        if !SearchFilterItem.searchWithTitle.state && SearchFilterItem.searchWithSinger.state {
            searchResultCell.singerLabel.setAccentColor(string: searchKeyword)
        } else if SearchFilterItem.searchWithTitle.state && !SearchFilterItem.searchWithSinger.state {
            searchResultCell.titleLabel.setAccentColor(string: searchKeyword)
        } else {
            searchResultCell.titleLabel.setAccentColor(string: searchKeyword)
            searchResultCell.singerLabel.setAccentColor(string: searchKeyword)
        }
        
        return searchResultCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        archiveFloatingPanel?.show(selectedSong: searchResultArr[indexPath.row], animated: true)
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let searchResultCell = tableView.cellForRow(at: indexPath) as? SongTableViewCell else { return }
        
        searchResultCell.cellContentView.backgroundColor = ColorSet.songCellSelectedBackgroundColor
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let searchResultCell = tableView.cellForRow(at: indexPath) as? SongTableViewCell else { return }
        
        searchResultCell.cellContentView.backgroundColor = ColorSet.songCellBackgroundColor
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

extension SearchViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension SearchViewController: PopOverSearchFilterViewDelegate {
    func popOverSearchFilterView(didTapApply: Bool) {
        self.setSearchResult()
    }
}
