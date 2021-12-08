//
//  FolderViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/21.
//

import Foundation

import RxSwift
import RxCocoa

class SavedSongListViewModel {
    private var disposeBag = DisposeBag()
    private let songFolderManager = SongFolderManager()
    private var songFolder = ArchiveFolder()
    private var songList = [ArchiveSong]()
}

extension SavedSongListViewModel {
    var folderTitle: String {
        return songFolder.title
    }
    
    var folderTitleEmoji: String {
        return songFolder.titleEmoji
    }
    
    func fetchSongFolder(_ id: String) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            self.songFolderManager.fetchData(id)
                .subscribe(onNext: { songFolderRealm in
                    self.songFolder = songFolderRealm
                    self.songList = Array(songFolderRealm.songs)
                    observer(.completed)
                }, onError: { error in
                    observer(.error(error))
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    func deleteSong(_ indexPath: IndexPath) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            self.songFolderManager.deleteSong(song: self.songList[indexPath.row])
                .subscribe(onCompleted: {
                    self.songList.remove(at: indexPath.row)
                    observer(.completed)
                }, onError: { error in
                    observer(.error(error))
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    // Wrapper method of fetchFolder
    func reloadFolder(_ id: String) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            self.fetchSongFolder(id)
                .subscribe {
                    observer(.completed)
                } onError: { error in
                    observer(.error(error))
                }.disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}

extension SavedSongListViewModel {
    func updateFolderTitle(_ newTitle: String) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            self.songFolderManager.updateTitle(archiveFolder: self.songFolder, newTitle: newTitle)
                .subscribe(onCompleted: {
                    observer(.completed)
                }, onError: { error in
                    observer(.error(error))
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    func updateFolderTitleEmoji(_ newEmoji: String) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            self.songFolderManager.updateTitleEmoji(songFolder: self.songFolder, newEmoji: newEmoji)
                .subscribe(onCompleted: {
                    observer(.completed)
                }, onError: { error in
                    observer(.error(error))
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}

extension SavedSongListViewModel {
    
}

extension SavedSongListViewModel {
    var sectionCount: Int {
        return 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return songFolder.songs.count
    }
    
    func archiveSongAtIndex(_ indexPath: IndexPath) -> SavedSongViewModel {
        return SavedSongViewModel(songList[indexPath.row])
    }
}

struct SongFolderViewModel {
    var songFolder: ArchiveFolder
}

extension SongFolderViewModel {
    init(_ songFolder: ArchiveFolder) {
        self.songFolder = songFolder
    }
}

extension SongFolderViewModel {
    var title: String {
        return songFolder.title
    }
    
    var titleEmoji: String {
        return songFolder.titleEmoji
    }
}

struct SavedSongViewModel {
    var song: ArchiveSong
}

extension SavedSongViewModel {
    init(_ song: ArchiveSong) {
        self.song = song
    }
}

extension SavedSongViewModel {
    var title: String {
        return song.title
    }
    
    var singer: String {
        return song.singer
    }
    
    var brand: String {
        return song.brand
    }
    
    var no: String {
        return song.no
    }
}
