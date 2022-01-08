//
//  SearchHistoryViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/09.
//

import UIKit

import RxSwift
import RxCocoa

protocol SearchHistoryViewDelegate: AnyObject {
    func searchHistoryView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, selectedHistoryRowAt selectedHistory: SearchHistory)
    func searchHistoryView(_ tableView: Bool)
}

class SearchHistoryViewController: UIViewController {
    
    // MARK: - Declaration
    @IBOutlet weak var searchHistoryTableView: UITableView!
    @IBOutlet weak var searchHistoryTableViewPlaceholderLabel: UILabel!
    @IBOutlet weak var clearHistoryButton: UIButton!
    
    weak var delegate: SearchHistoryViewDelegate?
    private let searchHistoryViewModel = SearchHistoryViewModel()
    private var disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupInstance()
        bind()
    }
    
    // MARK: - Initializers
    private func setupView() {
        // Search history tableView
        searchHistoryTableView.separatorStyle = .none
        searchHistoryTableView.tableFooterView = UIView()
        updateSearchHistory()
    }
    
    private func setupInstance() {
        // Search history tableView
        let searchHistoryCellNibName = UINib(nibName: "SearchHistoryTableViewCell", bundle: nil)
        searchHistoryTableView.register(searchHistoryCellNibName, forCellReuseIdentifier: "searchHistoryTableCell")
        searchHistoryTableView.dataSource = self
        searchHistoryTableView.delegate = self
    }
    
    private func bind() {
        // Clear history Button
        clearHistoryButton.rx.tap
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.searchHistoryViewModel.deleteAllHistory()
                    .observe(on: MainScheduler.instance)
                    .subscribe(onCompleted: { [weak vc] in
                        vc?.updateSearchHistory()
                    }).disposed(by: vc.disposeBag)
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Methods
    func updateSearchHistory() {
        searchHistoryViewModel.fetchSearchHistory()
            .observe(on: MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in
                self?.reloadSearchHistoryTableView()
            }).disposed(by: disposeBag)
    }
    
    private func reloadSearchHistoryTableView() {
        if searchHistoryViewModel.isSearchHistoryEmpty {
            searchHistoryTableViewPlaceholderLabel.isHidden = false
            searchHistoryTableView.reloadData()
        } else {
            searchHistoryTableViewPlaceholderLabel.isHidden = true
            searchHistoryTableView.reloadData()
        }
    }
}

// MARK: - Extensions
extension SearchHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistoryViewModel.numberOfRowsInSection(searchHistoryViewModel.sectionCount)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let searchHistoryCell = tableView.dequeueReusableCell(withIdentifier: "searchHistoryTableCell") as? SearchHistoryTableViewCell else {
            return UITableViewCell()
        }
        
        let searchHistoryItemVM = searchHistoryViewModel.searchHistoryItemAtIndex(indexPath)
        
        searchHistoryCell.titleLabel.text = searchHistoryItemVM.keyword
        searchHistoryCell.removeButtonTapAction = { [weak self] in
            guard let self = self else { return }
            
            self.searchHistoryViewModel.deleteHistory(indexPath)
                .observe(on: MainScheduler.instance)
                .subscribe(onCompleted: { [weak self] in
                    self?.updateSearchHistory()
                }).disposed(by: self.disposeBag)
        }
        
        return searchHistoryCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchHistoryItemVM = searchHistoryViewModel.searchHistoryItemAtIndex(indexPath)
        
        delegate?.searchHistoryView(tableView, didSelectRowAt: indexPath, selectedHistoryRowAt: searchHistoryItemVM.searchHistory)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.searchHistoryView(true)
    }
}
