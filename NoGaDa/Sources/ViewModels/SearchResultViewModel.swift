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
    
    
    // MARK: - Properties
    
    private var disposeBag = DisposeBag()
    private var karaokeManager = KaraokeApiManager()
    private var searchKeyword = ""
    
    public var selectedKaraokeBrand = BehaviorRelay<KaraokeBrand>(value: .tj)
    
    public var searchResultSongs = BehaviorRelay<[Song]>(value: [])
    public var isLoadingSearchResultSongs = BehaviorRelay<Bool>(value: false)
    public var searchResultSongsErrorState = PublishRelay<String>()
    public var didSelectSongItem = PublishRelay<Song>()
}

extension SearchResultViewModel {
    public func fetchSearchResult(keyword: String) {
        if keyword.isEmpty {
            return
        }
        
        let karaokeBrand = selectedKaraokeBrand.value
        searchKeyword = keyword
        searchResultSongs.accept([])
        isLoadingSearchResultSongs.accept(true)
        
        karaokeManager.fetchSong(titleOrSinger: keyword, brand: karaokeBrand)
            .retry(3)
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { strongSelf, songs in
                if songs.isEmpty {
                    strongSelf.searchResultSongsErrorState.accept("검색 결과가 없습니다.")
                } else {
                    strongSelf.searchResultSongs.accept(songs)
                    strongSelf.searchResultSongsErrorState.accept("")
                }
                
                strongSelf.isLoadingSearchResultSongs.accept(false)
            }, onError: { strongSelf, error in
                print(error.localizedDescription)
                strongSelf.searchResultSongsErrorState.accept("오류가 발생했습니다.")
                strongSelf.isLoadingSearchResultSongs.accept(false)
            }).disposed(by: self.disposeBag)
    }
}

extension SearchResultViewModel {
    public func songItemSelectAction(_ indexPath: IndexPath) {
        let selectedSong = searchResultSongs.value[indexPath.row]
        didSelectSongItem.accept(selectedSong)
    }
}

extension SearchResultViewModel {
    public func updateKaraokeBrand(_ karaokeBrand: KaraokeBrand) {
        selectedKaraokeBrand.accept(karaokeBrand)
        fetchSearchResult(keyword: searchKeyword)
    }
}
