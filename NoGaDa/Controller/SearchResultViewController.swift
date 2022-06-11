//
//  SearchResultViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/09.
//

import UIKit

import RxSwift
import RxCocoa

protocol SearchResultViewDelegate: AnyObject {
    func searchResultView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, selectedSongRowAt selectedSong: Song)
}

class SearchResultViewController: UIViewController {

    // MARK: - Declaration
    @IBOutlet weak var brandSelector: UISegmentedControl!
    @IBOutlet weak var searchResultContentView: UIView!
    @IBOutlet weak var searchResultTableView: UITableView!
    @IBOutlet weak var searchResultPlaceholderLabel: UILabel!
    @IBOutlet weak var searchIndicator: UIActivityIndicatorView!
    
    weak var delegate: SearchResultViewDelegate?
    private let searchResultViewModel = SearchResultViewModel()
    private var disposeBag = DisposeBag()
    private var searchKeyword = ""
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        bind()
    }
    
    // MARK: - Overrides
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        searchResultTableView.reloadData()
    }
    
    // MARK: - Initializers
    private func setupView() {
        setupSearchResultContentView()
        setupBrandSelector()
        setupSearchResultTableView()
        setupLoadingIndicatorView()
        setupSearchResultPlaceholderLabel()
    }
    
    private func bind() {
        bindBrandSelector()
    }
    
    // MARK: - Setups
    private func setupSearchResultContentView() {
        searchResultContentView.clipsToBounds = true
        searchResultContentView.layer.cornerRadius = 12
    }
    
    private func setupBrandSelector() {
        brandSelector.setSelectedTextColor(ColorSet.segmentedControlSelectedTextColor)
        brandSelector.setDefaultTextColor(ColorSet.segmentedControlDefaultTextColor)
    }
    
    private func setupSearchResultTableView() {
        searchResultTableView.tableFooterView = UIView()
        searchResultTableView.separatorStyle = .none
        searchResultTableView.layer.cornerRadius = 16
        
        let nibName = UINib(nibName: "SongTableViewCell", bundle: nil)
        searchResultTableView.register(nibName, forCellReuseIdentifier: "searchResultTableViewCell")
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
    }
    
    private func setupLoadingIndicatorView() {
        searchIndicator.stopAnimatingAndHide()
    }
    
    private func setupSearchResultPlaceholderLabel() {
        searchResultPlaceholderLabel.text = "검색창에 제목이나 가수명으로 노래를 검색하세요!"
        searchResultPlaceholderLabel.isHidden = true
    }
    
    // MARK: - Binds
    private func bindBrandSelector() {
        brandSelector.rx.selectedSegmentIndex
            .asDriver()
            .drive(with: self) { vc, _ in
                // TODO - replace table cells according to brand catalog
                vc.setSearchResult(vc.searchKeyword)
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Methods
    public func setSearchResult(_ searchKeyword: String) {
        self.searchKeyword = searchKeyword
        
        var brand: KaraokeBrand = .tj
        if brandSelector.selectedSegmentIndex == 1 {
            brand = .kumyoung
        }
        
        searchIndicator.startAnimatingAndShow()
        searchResultPlaceholderLabel.isHidden = true
        clearSearchResultTableView()
        
        searchResultViewModel.fetchSearchResult(keyword: searchKeyword, brand: brand)
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onCompleted: { vc in
                vc.reloadSearchResult()
            }, onError: { vc, error in
                vc.searchIndicator.stopAnimatingAndHide()
                vc.searchResultPlaceholderLabel.text = "오류가 발생했습니다"
                vc.searchResultPlaceholderLabel.isHidden = false
            }).disposed(by: disposeBag)
    }
    
    private func reloadSearchResult() {
        searchIndicator.stopAnimatingAndHide()
        searchResultTableView.reloadData()
        
        if searchResultViewModel.isSearchResultSongEmpty {
            searchResultPlaceholderLabel.text = "검색 결과가 없습니다"
            searchResultPlaceholderLabel.isHidden = false
            return
        }
        
        searchResultTableView.scrollToTopCell(animated: false)
    }
    
    private func clearSearchResultTableView() {
        searchResultViewModel.clearSearchResult()
        searchResultTableView.reloadData()
    }
}

// MARK: - Extensions
extension SearchResultViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultViewModel.numberOfRowsInSection(searchResultViewModel.sectionCount)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let searchResultCell = tableView.dequeueReusableCell(withIdentifier: "searchResultTableViewCell") as? SongTableViewCell else { return UITableViewCell() }
        
        let searchResultVM = searchResultViewModel.searchResultSongAtIndex(indexPath)
        
        searchResultCell.titleLabel.text        = searchResultVM.title
        searchResultCell.singerLabel.text       = searchResultVM.singer
        searchResultCell.songNumberLabel.text   = "\(searchResultVM.brand) \(searchResultVM.no)"
        
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
        
        let searchResultVM = searchResultViewModel.searchResultSongAtIndex(indexPath)
        delegate?.searchResultView(tableView, didSelectRowAt: indexPath, selectedSongRowAt: searchResultVM.song)
    }
}
