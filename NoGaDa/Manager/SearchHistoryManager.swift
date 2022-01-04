//
//  SearchHistoryManager.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/10.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa

class SearchHistoryManager {
    public func addData(searchKeyword: String) -> Completable {
        return Completable.create { observer in
            do {
                let realmInstance = try Realm()
                
                try realmInstance.write {
                    let searchHistory = SearchHistory(keyword: searchKeyword)
                    realmInstance.add(searchHistory, update: .modified)
                    observer(.completed)
                }
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    public func fetchData() -> Observable<[SearchHistory]> {
        return Observable.create { observer in
            do {
                let realmInstance = try Realm()
                var searchHistoryList = Array(realmInstance.objects(SearchHistory.self))
                searchHistoryList.sort { return $0.date > $1.date }
                
                observer.onNext(searchHistoryList)
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    public func deleteData(_ keyword: String) -> Completable {
        return Completable.create { observer in
            do {
                let realmInstance = try Realm()
                let searchHistoryList = realmInstance.objects(SearchHistory.self)
                
                try searchHistoryList.forEach { searchHistory in
                    if searchHistory.keyword == keyword {
                        try realmInstance.write {
                            realmInstance.delete(searchHistory)
                            observer(.completed)
                        }
                    }
                }
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    public func deleteAll() -> Completable {
        return Completable.create { observer in
            do {
                let realmInstance = try Realm()
                let searchHistoryList = Array(realmInstance.objects(SearchHistory.self))
                
                try realmInstance.write {
                    realmInstance.delete(searchHistoryList)
                    observer(.completed)
                }
            } catch {
                observer(.error(error))
            }
            
            return Disposables.create()
        }
    }
}
