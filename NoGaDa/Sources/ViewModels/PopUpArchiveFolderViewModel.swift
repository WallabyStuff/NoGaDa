//
//  PopUpSongFolderListViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/22.
//

import Foundation

import RxSwift
import RxCocoa
import UIKit

class PopUpArchiveFolderViewModel {
    
    
    // MARK: - Properties
    
    private var disposeBag = DisposeBag()
    public var selectedSong: Song
    private let songFolderManager = SongFolderManager()
    
    public var folders = BehaviorRelay<[ArchiveFolder]>(value: [])
    public var presentAlreadyExitstAlert = PublishRelay<Song>()
    public var playNotificationFeedback = PublishRelay<UINotificationFeedbackGenerator.FeedbackType>()
    public var didSongAdded = PublishRelay<Bool>()
    
    init() {
        fatalError("SelectedSong argument missing")
    }
    
    init(selectedSong: Song) {
        self.selectedSong = selectedSong
    }
}

extension PopUpArchiveFolderViewModel {
    func fetchFolder() {
        folders.accept([])
        
        songFolderManager.fetchData()
            .subscribe(with: self, onNext: { strongSelf, folders in
                strongSelf.folders.accept(folders)
            }, onError: { strongSelf, error in
                print(error.localizedDescription)
            }).disposed(by: self.disposeBag)
    }
}

extension PopUpArchiveFolderViewModel {
    private func deleteFolder(_ indexPath: IndexPath) {
        let folder = folders.value[indexPath.row]

        songFolderManager.deleteData(folder)
            .subscribe(with: self, onCompleted: { strongSelf in
                strongSelf.fetchFolder()
            }, onError: { strongSelf, error in
                print(error.localizedDescription)
            }).disposed(by: self.disposeBag)
    }
}

extension PopUpArchiveFolderViewModel {
    public func addSongAction(_ indexPath: IndexPath) {
        let targetFolder = folders.value[indexPath.row]
        
        self.songFolderManager.addSong(songFolder: targetFolder, song: selectedSong)
            .subscribe(with: self, onCompleted: { strongSelf in
                strongSelf.playNotificationFeedback.accept(.success)
                strongSelf.didSongAdded.accept(true)
            }, onError: { strongSelf, error in
                guard let error = error as? SongFolderManagerError else {
                    return
                }
                
                if error == .alreadyExists {
                    strongSelf.presentAlreadyExitstAlert.accept(strongSelf.selectedSong)
                }
            }).disposed(by: self.disposeBag)
    }
}

extension PopUpArchiveFolderViewModel {
    public func removeFolderAction(_ indexPath: IndexPath) {
        let folder = folders.value[indexPath.row]
        songFolderManager.deleteData(folder)
            .subscribe(with: self, onCompleted: { strongSelf in
                strongSelf.fetchFolder()
            })
            .disposed(by: disposeBag)
    }
    
    public func folderAt(_ indexPath: IndexPath) -> ArchiveFolder {
        return folders.value[indexPath.row]
    }
}
