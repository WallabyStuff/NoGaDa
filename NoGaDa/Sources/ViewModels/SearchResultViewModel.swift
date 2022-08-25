//
//  SearchResultViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/21.
//

import Foundation
import RxSwift
import RxCocoa

class SearchResultViewModel: ViewModelType {
    
    
    // MARK: - Properties
    
    struct Input {
        let changeKaraokeBrand = PublishRelay<KaraokeBrand>()
        let search = PublishRelay<String>()
        let tapSongItem = PublishSubject<IndexPath>()
    }
    
    struct Output {
        let searchKeyword = BehaviorRelay<String>(value: "")
        let selectedKaraokeBrand = BehaviorRelay<KaraokeBrand>(value: .tj)
        let searchResultSongs = BehaviorRelay<[Song]>(value: [])
        let isLoading = BehaviorRelay<Bool>(value: false)
        let searchResultErrorState = PublishRelay<String>()
        let didSelectSongItem = PublishRelay<Song>()
    }
    
    private(set) var input: Input!
    private(set) var output: Output!
    private(set) var disposeBag = DisposeBag()
    private var karaokeManager = KaraokeApiManager()

    
    // MARK: - Initializers
    
    init() {
        setupInputOutput()
    }
    
    
    // MARK: - Setups
    
    private func setupInputOutput() {
        let input = Input()
        let output = Output()
        
        Observable.merge(
            input.search
                .map { keyword in
                    output.searchKeyword.accept(keyword)
                },
            input.changeKaraokeBrand
                .skip(1)
                .map { karaokeBrand in
                    output.selectedKaraokeBrand.accept(karaokeBrand)
                }
        )
        .map {
            output.searchResultErrorState.accept("")
            output.isLoading.accept(true)
            output.searchResultSongs.accept([])
        }
        .flatMap { [weak self] () -> Observable<[Song]> in
            guard let self = self else { return .empty() }
            if output.searchKeyword.value.isEmpty {
                return .empty()
            }
            
            return self.karaokeManager.fetchSong(titleOrSinger: output.searchKeyword.value,
                                                 brand: output.selectedKaraokeBrand.value)
        }
        .subscribe(onNext: { songs in
            output.isLoading.accept(false)
            
            if songs.isEmpty {
                output.searchResultErrorState.accept("검색 결과가 없습니다")
            } else {
                output.searchResultErrorState.accept("")
                output.searchResultSongs.accept(songs)
            }
        }, onError: { error in
            print(error.localizedDescription)
            output.isLoading.accept(false)
            output.searchResultErrorState.accept("오류가 발생했습니다")
        })
        .disposed(by: disposeBag)
        
        input.tapSongItem
            .subscribe(onNext: { indexPath in
                let selectedSong = output.searchResultSongs.value[indexPath.row]
                output.didSelectSongItem.accept(selectedSong)
            })
            .disposed(by: disposeBag)
        
        self.input = input
        self.output = output
    }
}

extension SearchResultViewModel {
    public var searchKeyword: String {
        return output.searchKeyword.value
    }
}
