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
    let searchResultViewModel = SearchResultViewModel()
    var disposeBag = DisposeBag()
    weak var delegate: SearchResultViewDelegate?
    var searchKeyword = ""
    
    @IBOutlet weak var brandSelector: UISegmentedControl!
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
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        searchResultTableView.reloadData()
    }
    
    // MARK: - Initialization
    private func initView() {
        // Search result ContentView
        searchResultContentView.clipsToBounds = true
        searchResultContentView.layer.cornerRadius = 12
        
        // Brand Selector SegmentedControl
        brandSelector.setSelectedTextColor(ColorSet.segmentedControlSelectedTextColor)
        brandSelector.setDefaultTextColor(ColorSet.segmentedControlDefaultTextColor)
        
        // SearchResult TableView
        searchResultTableView.tableFooterView = UIView()
        searchResultTableView.separatorStyle = .none
        searchResultTableView.layer.cornerRadius = 16
        
        // Search loading IndicatorView
        searchIndicator.stopAnimatingAndHide()
        
        // Search result placeholder label
        searchResultPlaceholderLabel.text = "검색창에 제목이나 가수명으로 노래를 검색하세요!"
        searchResultPlaceholderLabel.isHidden = true
    }
    
    private func initInstance() {
        // SearchResult TableView
        let searchResultCellNibName = UINib(nibName: "SongTableViewCell", bundle: nil)
        searchResultTableView.register(searchResultCellNibName, forCellReuseIdentifier: "searchResultTableViewCell")
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        
        // Brand Segmented Control Action
        brandSelector.rx.selectedSegmentIndex
            .bind(with: self) { vc, _ in
                // TODO - replace table cells according to brand catalog
                vc.setSearchResult(vc.searchKeyword)
            }.disposed(by: disposeBag)
    }
    
    private func initEventListener() {
        
    }
    
    // MARK: - Method
    public func setSearchResult(_ searchKeyword: String) {
        self.searchKeyword = searchKeyword
        
        var brand: KaraokeBrand = .tj
        if brandSelector.selectedSegmentIndex == 1 {
            brand = .kumyoung
        }
        
        searchIndicator.startAnimatingAndShow()
        searchResultPlaceholderLabel.isHidden = true
        clearSearchResult()
        
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
    
    private func clearSearchResult() {
        searchResultViewModel.clearSearchResult()
        searchResultTableView.reloadData()
    }
}

// MARK: - Extension
extension SearchResultViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultViewModel.numberOfRowsInSection(searchResultViewModel.sectionCount)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let searchResultCell = tableView.dequeueReusableCell(withIdentifier: "searchResultTableViewCell") as? SongTableViewCell else { return UITableViewCell() }
        
        let searchResultVM = searchResultViewModel.searchResultSongAtIndex(indexPath)
        
        searchResultCell.titleLabel.text        = searchResultVM.title
        searchResultCell.singerLabel.text       = searchResultVM.singer
        searchResultCell.songNumberLabel.text   = searchResultVM.no
        searchResultCell.brandLabel.text        = searchResultVM.brand
        
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
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let searchResultCell = tableView.cellForRow(at: indexPath) as? SongTableViewCell else { return }
        
        searchResultCell.cellContentView.backgroundColor = ColorSet.songCellSelectedBackgroundColor
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let searchResultCell = tableView.cellForRow(at: indexPath) as? SongTableViewCell else { return }
        
        searchResultCell.cellContentView.backgroundColor = ColorSet.songCellBackgroundColor
    }
}
