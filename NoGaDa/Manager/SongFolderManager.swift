//
//  ArchiveFolderManager.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/23.
//

import UIKit

import RealmSwift
import RxSwift
import RxCocoa

enum SongFolderManagerError: String, Error {
    case alreadyExists = "file already exists on Realm"
}

class SongFolderManager {
    
    var disposeBag = DisposeBag()
    
    func addData(title: String, titleEmoji: String) -> Completable {
        return Completable.create { completable in
            do {
                let realmInstance = try Realm()
                let archiveFolder = ArchiveFolder(title: title, titleEmoji: titleEmoji)
                
                try realmInstance.write {
                    realmInstance.add(archiveFolder)
                    completable(.completed)
                }
            } catch {
                completable(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func fetchData() -> Observable<[ArchiveFolder]> {
        return Observable.create { observable in
            do {
                let realmInstance = try Realm()
                let archiveFolders = realmInstance.objects(ArchiveFolder.self)
                observable.onNext(Array(archiveFolders))
                observable.onCompleted()
            } catch {
                observable.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
    func fetchData(_ id: String) -> Observable<ArchiveFolder> {
        return Observable.create { [weak self] observable in
            guard let self = self else { return Disposables.create() }
            
            self.fetchData()
                .subscribe(onNext: { songFolderList in
                    songFolderList.forEach { songFolderRealm in
                        if songFolderRealm.id == id {
                            observable.onNext(songFolderRealm)
                        }
                    }
                    observable.onCompleted()
                }, onError: { error in
                    observable.onError(error)
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    func deleteData(archiveFolder: ArchiveFolder) -> Completable {
        return Completable.create { completable in
            do {
                let realmInstance = try Realm()
                
                try realmInstance.write {
                    realmInstance.delete(archiveFolder.songs)
                    realmInstance.delete(archiveFolder)
                    completable(.completed)
                }
            } catch {
                completable(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func updateTitle(archiveFolder: ArchiveFolder, newTitle: String) -> Completable {
        return Completable.create { completable in
            do {
                let realmInstance = try Realm()
                try realmInstance.write {
                    archiveFolder.title = newTitle
                    completable(.completed)
                }
            } catch {
                completable(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func updateTitleEmoji(songFolder: ArchiveFolder, newEmoji: String) -> Completable {
        return Completable.create { completable in
            do {
                let realmInstance = try Realm()
                
                try realmInstance.write {
                    songFolder.titleEmoji = newEmoji
                    completable(.completed)
                }
            } catch {
                completable(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func appendSong(songFolder: ArchiveFolder, song: Song) -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else {
                return Disposables.create()
            }
            
            do {
                let realmInsatnce = try Realm()
                
                let archiveSong = ArchiveSong(no: song.no,
                                              title: song.title,
                                              singer: song.singer,
                                              brand: song.brand.localizedString,
                                              composer: song.composer,
                                              lyricists: song.lyricist,
                                              releaseDate: song.release)
                
                if self.isSongExists(archiveFolder: songFolder, song: archiveSong) {
                    completable(.error(SongFolderManagerError.alreadyExists))
                    return Disposables.create()
                }
                
                try realmInsatnce.write {
                    songFolder.songs.append(archiveSong)
                    completable(.completed)
                }
            } catch {
                completable(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func deleteSong(song: ArchiveSong) -> Completable {
        return Completable.create { completable in
            do {
                let realmInstance = try Realm()
                
                try realmInstance.write {
                    realmInstance.delete(song)
                    completable(.completed)
                    return
                }
            } catch {
                completable(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    private func isSongExists(archiveFolder: ArchiveFolder, song: ArchiveSong) -> Bool {
        var isExists = false
        for archivedSong in archiveFolder.songs {
            if archivedSong.no == song.no {
                isExists = true
            }
        }
        
        return isExists
    }
    
    func getSongsCount() -> Int {
        do {
            let realmInstance = try Realm()
            let archivedSongs = realmInstance.objects(ArchiveSong.self)
            return archivedSongs.count
        } catch {
            print(error)
            return 0
        }
    }
}
