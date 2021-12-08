//
//  PopUpSongFolderListViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/22.
//

import Foundation
import RxSwift
import RxCocoa

class PopUpSongFolderListViewModel {
    
    private var disposeBag = DisposeBag()
    private let songFolderManager = SongFolderManager()
    private var songFolderList = [ArchiveFolder]()
}

extension PopUpSongFolderListViewModel {
    func fetchSongFolder() -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            self.songFolderManager.fetchData()
                .subscribe(onNext: { [weak self] songFolderList in
                    self?.songFolderList = songFolderList
                    observer(.completed)
                }, onError: { error in
                    observer(.error(error))
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}

extension PopUpSongFolderListViewModel {
    func appendSong(_ songFolder: ArchiveFolder, _ song: Song) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            self.songFolderManager.addSong(songFolder: songFolder, song: song)
                .subscribe(onCompleted: {
                    observer(.completed)
                }, onError: { error in
                    observer(.error(error))
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}

extension PopUpSongFolderListViewModel {
    var sectionCount: Int {
        return 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return songFolderList.count
    }
    
    func songFolderAtIndex(_ indexPath: IndexPath) -> SongFolderViewModel {
        return SongFolderViewModel(songFolderList[indexPath.row])
    }
}

extension PopUpSongFolderListViewModel {
    func deleteFolder(_ indexPath: IndexPath) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            self.songFolderManager.deleteData(archiveFolder: self.songFolderList[indexPath.row])
                .subscribe(onCompleted: { [weak self] in
                    self?.songFolderList.remove(at: indexPath.row)
                    observer(.completed)
                }, onError: { error in
                    observer(.error(error))
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}
