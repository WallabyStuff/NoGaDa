//
//  FolderViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/21.
//

import Foundation

import RxSwift
import RxCocoa

class ArchiveSongViewModel {
    
    
    // MARK: - Properties
    
    private var currentFolder: ArchiveFolder
    private var disposeBag = DisposeBag()
    private let songFolderManager = SongFolderManager()
    
    public var songs = BehaviorRelay<[ArchiveSong]>(value: [])
    public var showSongOptionFlowtingPanelView = PublishRelay<ArchiveSong>()
    public var presentAddSongVC = PublishRelay<ArchiveFolder>()
    
    
    // MARK: - Initializers
    
    init() {
        fatalError("Missed arguemnt currentFolder")
    }
    
    init(currentFolder: ArchiveFolder) {
        self.currentFolder = currentFolder
        songs.accept(Array(currentFolder.songs))
    }
}

extension ArchiveSongViewModel {
    public func fetchSongs() {
        songFolderManager.fetchData(currentFolder.id)
            .subscribe(with: self, onNext: { strongSelf, folder in
                let songs = Array(folder.songs)
                strongSelf.songs.accept(songs)
            })
            .disposed(by: disposeBag)
    }
}

extension ArchiveSongViewModel {
    public func songItemTapAction(_ indexPath: IndexPath) {
        let selectedItem = songs.value[indexPath.row]
        showSongOptionFlowtingPanelView.accept(selectedItem)
    }
}

extension ArchiveSongViewModel {
    public func addSongButtonTapAction() {
        presentAddSongVC.accept(currentFolder)
    }
}

extension ArchiveSongViewModel {
    public func deleteSong(_ indexPath: IndexPath) {
        let song = songs.value[indexPath.row]
        
        songFolderManager.deleteSong(song: song)
            .subscribe(with: self, onCompleted: { strongSelf in
                strongSelf.fetchSongs()
            }).disposed(by: disposeBag)
    }
}

extension ArchiveSongViewModel {
    public func updateFolderTitle(_ newTitle: String) {
        if newTitle != currentFolder.title {
            songFolderManager.updateTitle(archiveFolder: currentFolder,
                                          newTitle: newTitle)
                .subscribe()
                .dispose()
        }
    }
    
    public func updateTitleEmoji(_ newEmoji: String) {
        if newEmoji != currentFolder.titleEmoji {
            songFolderManager.updateTitleEmoji(songFolder: currentFolder,
                                               newEmoji: newEmoji)
                .subscribe()
                .dispose()
        }
    }
}

extension ArchiveSongViewModel {
    public var folderTitle: String {
        return currentFolder.title
    }
    
    public var folderTitleEmoji: String {
        return currentFolder.titleEmoji
    }
}
