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
import SafeAreaBrush



class SearchViewController: BaseViewController, ViewModelInjectable {
  
  // MARK: - Constants
  
  static let identifier = R.storyboard.search.searchStoryboard.identifier
  
  struct Metric {
    static let appbarViewCornerRadius = 28.f
    
    static let searchBoxViewCornerRadius = 12.f
    
    static let searchTextFieldLeftPadding = 12.f
    static let searchTextFieldRightPadding = 80.f
    
    static let filterButtonCornerRadius = 8.f
    static let filterButtonPadding = 8.f
    
    static let backButtonPadding = 4.f
    
    static let clearTextFieldButtonPadding = 6.f
    
    static let searchFilterContentSize = CGSize(width: 240, height: 160)
  }
  
  
  // MARK: - Types
  
  typealias ViewModel = SearchViewModel
  
  
  // MARK: - Properties
  
  var viewModel: SearchViewModel
  
  enum ContentsType {
    case searchHistory
    case searchResult
  }

  
  // MARK: - UI

  @IBOutlet weak var appbarView: UIView!
  @IBOutlet weak var appbarViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var appbarTitleLabel: UILabel!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var searchBoxView: UIView!
  @IBOutlet weak var searchTextField: UITextField!
  @IBOutlet weak var clearTextFieldButton: UIButton!
  @IBOutlet weak var filterButton: UIButton!
  @IBOutlet weak var contentsView: UIView!
  
  private var searchHistoryVC: SearchHistoryViewController?
  private var searchResultVC: SearchResultViewController?
  private var archiveFolderFloatingPanelView: ArchiveFolderFloatingPanelView?
  
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    bind()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    searchTextField.becomeFirstResponder()
  }
  
  
  // MARK: - Overrides
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
  
  
  // MARK: - Initializers
  
  required init(_ viewModel: SearchViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(_ coder: NSCoder, _ viewModel: SearchViewModel) {
    self.viewModel = viewModel
    super.init(coder: coder)
  }
  
  required init?(coder: NSCoder) {
    fatalError("ViewModel has not been implemented")
  }
  
  
  // MARK: - Setups
  
  private func setupView() {
    self.hero.isEnabled = true
    
    setupStatusBar()
    setupAppBarView()
    setupAppbarTitleLabel()
    setupSearchBoxView()
    setupSearchTextField()
    setupSearchButton()
    setupBackButton()
    setupClearTextFieldButton()
    setupArchiveFloatingPanelView()
    setupSearchHistoryVC()
    setupSearchResultVC(searchKeyword)
  }
  
  private func setupStatusBar() {
    fillSafeArea(position: .top, color: R.color.accentPurple()!, insertAt: 0)
  }
  
  private func setupAppBarView() {
    appbarView.layer.cornerRadius = Metric.appbarViewCornerRadius
    appbarView.layer.cornerCurve = .circular
    appbarView.layer.maskedCorners = CACornerMask([.layerMinXMaxYCorner])
    appbarView.setAppBarShadow()
    appbarViewHeightConstraint.constant = regularAppBarHeight
  }
  
  private func setupAppbarTitleLabel() {
    appbarTitleLabel.hero.id = "appbarTitle"
  }
  
  private func setupSearchBoxView() {
    searchBoxView.layer.cornerRadius = Metric.searchBoxViewCornerRadius
    searchBoxView.layer.masksToBounds = true
    searchBoxView.setSearchBoxShadow()
  }
  
  private func setupSearchTextField() {
    searchTextField.setPlaceholderColor(R.color.textTertiary()!)
    searchTextField.setLeftPadding(width: Metric.searchTextFieldLeftPadding)
    searchTextField.setRightPadding(width: Metric.searchTextFieldRightPadding)
    searchTextField.delegate = self
  }
  
  private func setupSearchButton() {
    filterButton.layer.cornerRadius = Metric.filterButtonCornerRadius
    filterButton.setPadding(width: Metric.filterButtonPadding)
    filterButton.setSearchBoxButtonShadow()
  }
  
  private func setupBackButton() {
    backButton.hero.modifiers = [.fade]
    backButton.setPadding(width: Metric.backButtonPadding)
  }
  
  private func setupClearTextFieldButton() {
    clearTextFieldButton.setPadding(width: Metric.clearTextFieldButtonPadding)
  }
  
  private func setupArchiveFloatingPanelView() {
    archiveFolderFloatingPanelView = ArchiveFolderFloatingPanelView(parentViewController: self, delegate: self)
  }
  
  private func setupSearchHistoryVC() {
    let storyboard = UIStoryboard(name: R.storyboard.search.name, bundle: nil)
    let searchHistoryVC = storyboard.instantiateViewController(identifier: SearchHistoryViewController.identifier) { coder -> SearchHistoryViewController in
      let viewModel = SearchHistoryViewModel()
      return .init(coder, viewModel) ?? SearchHistoryViewController(viewModel)
    }
    
    addChild(searchHistoryVC)
    contentsView.addSubview(searchHistoryVC.view)
    searchHistoryVC.didMove(toParent: self)
    searchHistoryVC.view.frame = contentsView.bounds
    
    searchHistoryVC.delegate = self
    self.searchHistoryVC = searchHistoryVC
  }
  
  private func setupSearchResultVC(_ searchKeyword: String) {
    let storyboard = UIStoryboard(name: R.storyboard.search.name, bundle: nil)
    let searchResultVC = storyboard.instantiateViewController(identifier: SearchResultViewController.identifier) { coder -> SearchResultViewController in
      let viewModel = SearchResultViewModel()
      return .init(coder, viewModel) ?? SearchResultViewController(viewModel)
    }
    
    addChild(searchResultVC)
    contentsView.addSubview(searchResultVC.view)
    searchResultVC.didMove(toParent: self)
    searchResultVC.view.frame = contentsView.bounds
    searchResultVC.view.isHidden = true
    
    searchResultVC.delegate = self
    self.searchResultVC = searchResultVC
  }
  
  
  // MARK: - Binds
  
  private func bind() {
    bindBackButton()
    bindFilterButton()
    bindClearTextFieldButton()
  }
  
  private func bindBackButton() {
    backButton.rx.tap
      .asDriver()
      .drive(with: self) { vc, _ in
        vc.dismiss(animated: true, completion: nil)
      }.disposed(by: disposeBag)
  }
  
  private func bindFilterButton() {
    filterButton.rx.tap
      .asDriver()
      .drive(with: self) { vc, _ in
        vc.presentSearchFilterPopoverVC()
      }.disposed(by: disposeBag)
  }
  
  private func bindClearTextFieldButton() {
    clearTextFieldButton.rx.tap
      .asDriver()
      .drive(with: self, onNext: { vc, _ in
        vc.searchTextField.text = ""
        vc.searchTextField.becomeFirstResponder()
      }).disposed(by: disposeBag)
  }
  
  
  // MARK: - Methods
  
  private func dismissKeyboardAndArchivePanel() {
    view.endEditing(true)
    archiveFolderFloatingPanelView?.hide(animated: true)
  }
  
  private func presentSearchFilterPopoverVC() {
    let storyboard = UIStoryboard(name: R.storyboard.search.name, bundle: nil)
    let viewController = storyboard.instantiateViewController(identifier: PopOverSearchFilterViewController.identifier,
                                                              creator: { coder -> PopOverSearchFilterViewController in
      let viewModel = PopOverSearchFilterViewModel()
      return .init(coder, viewModel) ?? PopOverSearchFilterViewController(viewModel)
    })
    
    viewController.navigationController?.popoverPresentationController?.backgroundColor = .white
    viewController.delegate = self
    viewController.modalPresentationStyle = .popover
    viewController.preferredContentSize = Metric.searchFilterContentSize
    viewController.popoverPresentationController?.permittedArrowDirections = .up
    viewController.popoverPresentationController?.sourceRect = filterButton.bounds
    viewController.popoverPresentationController?.sourceView = filterButton
    viewController.presentationController?.delegate = self
    
    present(viewController, animated: true, completion: nil)
  }
  
  private func setSearchResult() {
    if !SearchFilterItem.searchWithTitle.state && !SearchFilterItem.searchWithSinger.state {
      presentSearchFilterPopoverVC()
      return
    }
    
    view.endEditing(true)
    
    guard let searchResultVC = searchResultVC else {
      return
    }
    
    Observable.just(searchKeyword)
      .bind(to: searchResultVC.viewModel.input.search)
      .disposed(by: disposeBag)
    
    viewModel.addSearchHistory(searchKeyword)
    replaceContents(type: .searchResult)
  }
  
  private func replaceContents(type: ContentsType) {
    guard let searchHistoryVC = searchHistoryVC,
          let searchResultVC = searchResultVC else {
      return
    }
    
    if type == .searchHistory {
      // Show search result
      searchHistoryVC.view.isHidden = false
      searchResultVC.view.isHidden = true
    } else {
      // Show search history
      searchHistoryVC.view.isHidden = true
      searchResultVC.view.isHidden = false
      
      // Refresh saerch history
      Observable.just(Void())
        .bind(to: searchHistoryVC.viewModel.input.refresh)
        .disposed(by: disposeBag)
    }
  }
  
  private var searchKeyword: String {
    guard let searchKeyword = searchTextField.text?.trimmingCharacters(in: .whitespaces) else {
      return ""
    }
    
    if searchKeyword.isEmpty {
      return ""
    }
    
    return searchKeyword
  }
}


// MARK: - Extensions

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


// MARK: - SearchResultView Delegate

extension SearchViewController: SearchResultViewDelegate {
  func didSelectSongItem(_ selectedSong: Song) {
    archiveFolderFloatingPanelView?.show(selectedSong)
  }
}


// MARK: - SearchHistoryView Delegate

extension SearchViewController: SearchHistoryViewDelegate {
  func didCallEndEditing() {
    dismissKeyboardAndArchivePanel()
  }
  
  func didSelectHistoryItem(_ keyword: String) {
    searchTextField.text = keyword
    setSearchResult()
  }
}

// MARK: - PopOverSearchFilterView Delegate

extension SearchViewController: PopOverSearchFilterViewDelegate {
  func popOverSearchFilterView(didTapApply: Bool) {
    setSearchResult()
  }
}


// MARK: - PopUpArchiveFolderView Delegate

extension SearchViewController: PopUpArchiveFolderViewDelegate {
  func didSongAdded() {
    archiveFolderFloatingPanelView?.hide(animated: true)
  }
}
