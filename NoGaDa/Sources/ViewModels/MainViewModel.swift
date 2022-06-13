//
//  ViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/18.
//

import Foundation

import RxSwift
import RxCocoa

class MainViewModel {
    
    
    // MARK: - Properties
    
    private var disposeBag = DisposeBag()
    private let karaokeManager = KaraokeApiManager()
    private let songFolderManager = SongFolderManager()
    
    public var showArchiveFolderFloatingView = PublishRelay<Song>()
    
    public var selectedKaraokeBrand = BehaviorRelay<KaraokeBrand>(value: .tj)
    public var newUpdateSongs = BehaviorRelay<[Song]>(value: [])
    public var isLoadingNewUpdateSongs = BehaviorRelay<Bool>(value: true)
    public var newUpdateSongsErrorState = PublishRelay<String>()
    
    public var amountOfSavedSongs = PublishRelay<String>()
}

extension MainViewModel {
    func fetchUpdatedSong() {
        let selectedBrand = selectedKaraokeBrand.value
        newUpdateSongs.accept([])
        isLoadingNewUpdateSongs.accept(true)
        
        karaokeManager.fetchUpdatedSong(brand: selectedBrand)
            .retry(3)
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { strongSelf, songs in
                if songs.isEmpty {
                    strongSelf.newUpdateSongsErrorState.accept("업데이트 된 곡이 없습니다.")
                } else {
                    strongSelf.newUpdateSongsErrorState.accept("")
                    strongSelf.newUpdateSongs.accept(songs)
                }
                
                strongSelf.isLoadingNewUpdateSongs.accept(false)
            }, onError: { strongSelf, error  in
                strongSelf.newUpdateSongsErrorState.accept("오류가 발생했습니다.")
                strongSelf.isLoadingNewUpdateSongs.accept(false)
            }).disposed(by: disposeBag)
    }
}

extension MainViewModel {
    public func songItemSelectAction(_ indexPath: IndexPath) {
        let song = newUpdateSongs.value[indexPath.row]
        showArchiveFolderFloatingView.accept(song)
    }
}

extension MainViewModel {
    public func updateAmountOfSavedSongs() {
        let text = "총 \(savedSongsAmount)곡"
        amountOfSavedSongs.accept(text)
    }
    
    private var savedSongsAmount: Int {
        return songFolderManager.getAmountOfSongs()
    }
}

extension MainViewModel {
    public func updatedSelectedKaraokeBrank(_ karaokeBrand: KaraokeBrand) {
        selectedKaraokeBrand.accept(karaokeBrand)
        fetchUpdatedSong()
    }
}
