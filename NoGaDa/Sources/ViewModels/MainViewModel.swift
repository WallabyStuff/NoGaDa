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
    private var disposeBag = DisposeBag()
    private let karaokeManager = KaraokeApiManager()
    private var updatedSongList = [Song]()
    private let songFolderManager = SongFolderManager()
    private var archiveFolderFloatingPanelView: ArchiveFolderFloatingPanelView?
}

extension MainViewModel {
    func fetchUpdatedSong(brand: KaraokeBrand) -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }
            
            self.karaokeManager.fetchUpdatedSong(brand: brand)
                .retry(3)
                .subscribe(with: self, onNext: { strongSelf, updatedSongList in
                    strongSelf.updatedSongList = updatedSongList
                    completable(.completed)
                }, onError: { vc, error  in
                    completable(.error(error))
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    var updatedSongCount: Int {
        return updatedSongList.count
    }
    
    func clearUpdatedSong() {
        updatedSongList.removeAll()
    }
}

extension MainViewModel {
    var savedSongSize: Int {
        return songFolderManager.getSongsCount()
    }
    
    var savedSongSizeString: String {
        return "총 \(savedSongSize)곡"
    }
}

extension MainViewModel {
    var sectionCount: Int {
        return 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return updatedSongList.count
    }
    
    func updatedSongAtIndex(_ indexPath: IndexPath) -> Song {
        let song = updatedSongList[indexPath.row]
        return song
    }
}
