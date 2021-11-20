//
//  SearchResultViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/21.
//

import Foundation
import RxSwift
import RxCocoa

class SearchResultViewModel {
    
    var disposeBag = DisposeBag()
    var karaokeManager = KaraokeManager()
    var searchResultSongList = [Song]()
}

extension SearchResultViewModel {
    func fetchSearchResult(keyword: String, brand: KaraokeBrand) -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }
            
            self.karaokeManager.fetchSong(titleOrSinger: keyword, brand: brand)
                .retry(3)
                .subscribe(onNext: { searchResultSongList in
                    self.searchResultSongList = searchResultSongList
                    completable(.completed)
                }, onError: { error in
                    completable(.error(error))
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    var searchResultSongCount: Int {
        return searchResultSongList.count
    }
    
    var isSearchResultSongEmpty: Bool {
        if searchResultSongList.count == 0 {
            return true
        } else {
            return false
        }
    }
    
    func clearSearchResult() {
        searchResultSongList.removeAll()
    }
}

extension SearchResultViewModel {
    var sectionCount: Int {
        return 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return searchResultSongList.count
    }
    
    func searchResultSongAtIndex(_ indexPath: IndexPath) -> SearchResultSongViewModel {
        let song = searchResultSongList[indexPath.row]
        return SearchResultSongViewModel(song)
    }
}

struct SearchResultSongViewModel {
    var song: Song
}

extension SearchResultSongViewModel {
    init(_ song: Song) {
        self.song = song
    }
}

extension SearchResultSongViewModel {
    var title: String {
        return song.title
    }
    
    var singer: String {
        return song.singer
    }
    
    var brand: String {
        return song.brand.localizedString
    }
    
    var no: String {
        return song.no
    }
}
