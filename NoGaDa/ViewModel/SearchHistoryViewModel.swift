//
//  SearchHistoryViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/21.
//

import Foundation
import RxSwift
import RxCocoa

class SearchHistoryViewModel {
    
    private var disposeBag = DisposeBag()
    private let searchHistoryManager = SearchHistoryManager()
    private var searchHistoryList = [SearchHistory]()
}

extension SearchHistoryViewModel {
    func fetchSearchHistory() -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }
            
            self.searchHistoryManager.fetchData()
                .subscribe(onNext:{ searchHistoryList in
                    self.searchHistoryList = searchHistoryList
                    completable(.completed)
                }, onError: { error in
                    completable(.error(error))
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    func deleteAllHistory() -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }
            
            self.searchHistoryManager.deleteAll()
                .subscribe(onCompleted: {
                    completable(.completed)
                }, onError: { error in
                    completable(.error(error))
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    var searchHistoryCount: Int {
        return searchHistoryList.count
    }
    
    var isSearchHistoryEmpty: Bool {
        if searchHistoryList.count == 0 {
            return true
        } else {
            return false
        }
    }
}

extension SearchHistoryViewModel {
    var sectionCount: Int {
        return 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return searchHistoryList.count
    }
    
    func searchHistoryItemAtIndex(_ indexPath: IndexPath) -> SearchHistoryItemViewModel {
        return SearchHistoryItemViewModel(searchHistoryList[indexPath.row])
    }
    
    func deleteHistory(_ indexPath: IndexPath) -> Completable{
        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }
            
            self.searchHistoryManager.deleteData(self.searchHistoryList[indexPath.row].keyword)
                .subscribe(onCompleted: {
                    completable(.completed)
                }, onError: { error in
                    completable(.error(error))
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}

struct SearchHistoryItemViewModel {
    var searchHistory: SearchHistory
}

extension SearchHistoryItemViewModel {
    init(_ searchHistory: SearchHistory) {
        self.searchHistory = searchHistory
    }
}

extension SearchHistoryItemViewModel {
    var keyword: String {
        return searchHistory.keyword
    }
}
