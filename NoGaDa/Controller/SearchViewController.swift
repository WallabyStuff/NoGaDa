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

enum ContentsType {
    case searchHistory
    case searchResult
}

class SearchViewController: UIViewController {

    // MARK: - Declaraiton
    private var searchViewModel = SearchViewModel()
    private var disposeBag = DisposeBag()
    private var archiveFloatingPanel: ArchiveFloatingPanelView?
    private var searchHistoryVC = SearchHistoryViewController()
    private var searchResultVC = SearchResultViewController()
    
    @IBOutlet weak var appbarView: UIView!
    @IBOutlet weak var appbarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var appbarTitleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchBoxView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var clearTextFieldButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var contentsView: UIView!
    
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

    // MARK: - Initialization
    private func initView() {
        self.hero.isEnabled = true
        
        // Appbar
        appbarView.hero.id = "appbar"
        appbarView.layer.cornerRadius = 28
        appbarView.layer.cornerCurve = .circular
        appbarView.layer.maskedCorners = CACornerMask([.layerMinXMaxYCorner])
        appbarView.setAppbarShadow()
        view.fillStatusBar(color: ColorSet.appbarBackgroundColor)
        
        // Appbar height constraint
        appbarViewHeightConstraint.constant = 140 + SafeAreaInset.top
        
        // Appbar Title Label
        appbarTitleLabel.hero.id = "appbarTitle"
        
        // SearchBox View
        searchBoxView.hero.id = "searchBox"
        searchBoxView.layer.cornerRadius = 12
        searchBoxView.layer.masksToBounds = true
        searchBoxView.setSearchBoxShadow()
        
        // Search TextField
        searchTextField.setPlaceholderColor(ColorSet.appbarTextfieldPlaceholderColor)
        searchTextField.setLeftPadding(width: 12)
        searchTextField.setRightPadding(width: 80)
        
        // Search Button
        filterButton.hero.id = "searchBoxButton"
        filterButton.layer.cornerRadius = 8
        filterButton.setPadding(width: 8)
        filterButton.setSearchBoxButtonShadow()
        
        // Back Button
        backButton.hero.modifiers = [.fade]
        backButton.setPadding(width: 4)
        
        // Clear search textfield Button
        clearTextFieldButton.setPadding(width: 6)
        
        // Set up ContainerView
        configureContainerView()
        
        // Archive floating panel
        archiveFloatingPanel = ArchiveFloatingPanelView(vc: self)
    }
    
    private func initInstance() {
        // Search TextField
        searchTextField.delegate = self
        searchTextField.becomeFirstResponder()
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
    
    private func presentSearchFilterPopoverVC() {
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
    
    private func setSearchResult() {
        guard let searchKeyword = searchTextField.text else {
            return
        }
        
        if searchKeyword.isEmpty {
            return
        }
        
        if !SearchFilterItem.searchWithTitle.state && !SearchFilterItem.searchWithSinger.state {
            presentSearchFilterPopoverVC()
            return
        }
        
        view.endEditing(true)
        
        searchViewModel.addSearchHistory(searchKeyword)
        searchResultVC.setSearchResult(searchKeyword)
        replaceContents(type: .searchResult)
    }
    
    private func configureContainerView() {
        searchHistoryVC = storyboard?.instantiateViewController(withIdentifier: "searchHistoryStoryboard") as! SearchHistoryViewController
        searchResultVC = storyboard?.instantiateViewController(withIdentifier: "searchResultStoryboard") as! SearchResultViewController
        
        searchHistoryVC.delegate = self
        searchResultVC.delegate = self
        
        addChild(searchHistoryVC)
        addChild(searchResultVC)
        
        contentsView.addSubview(searchHistoryVC.view)
        contentsView.addSubview(searchResultVC.view)

        searchHistoryVC.didMove(toParent: self)
        searchResultVC.didMove(toParent: self)
        
        searchHistoryVC.view.frame = contentsView.bounds
        searchResultVC.view.frame = contentsView.bounds
        
        searchResultVC.view.isHidden = true
    }
    
    private func replaceContents(type: ContentsType) {
        if type == .searchHistory {
            searchHistoryVC.updateSearchHistory()
            searchHistoryVC.view.isHidden = false
            searchResultVC.view.isHidden = true
        } else {
            searchHistoryVC.view.isHidden = true
            searchResultVC.view.isHidden = false
        }
    }
}

// MARK: - Extension
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        replaceContents(type: .searchHistory)
    }
}

extension SearchViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension SearchViewController: PopOverSearchFilterViewDelegate {
    func popOverSearchFilterView(didTapApply: Bool) {
        setSearchResult()
    }
}

extension SearchViewController: SearchResultViewDelegate {
    func searchResultView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, selectedSongRowAt selectedSong: Song) {
        archiveFloatingPanel?.show(selectedSong: selectedSong, animated: true)
    }
}

extension SearchViewController: SearchHistoryViewDelegate {
    func searchHistoryView(_ tableViewTouchesBegan: Bool) {
        dismissKeyboardAndArchivePanel()
    }
    
    func searchHistoryView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, selectedHistoryRowAt selectedHistory: SearchHistory) {
        searchTextField.text = selectedHistory.keyword
        searchTextField.becomeFirstResponder()
    }
}
