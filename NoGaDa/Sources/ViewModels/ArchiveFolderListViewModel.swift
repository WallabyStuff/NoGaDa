//
//  ArchiveViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/21.
//

import Foundation
import RxSwift
import RxCocoa

class ArchiveFolderListViewModel {
    private var disposeBag = DisposeBag()
    private let songFolderManager = SongFolderManager()
    private var songFolderList = [ArchiveFolder]()
}

extension ArchiveFolderListViewModel {
    func fetchFolders() -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            self.songFolderManager.fetchData()
                .subscribe(onNext: { [weak self] songFolderList in
                    guard let self = self else { return }
                    self.songFolderList = songFolderList
                    observer(.completed)
                }, onError: { error in
                    observer(.error(error))
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    func deleteFolder(_ indexPath: IndexPath) -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }
            
            self.songFolderManager.deleteData(archiveFolder: self.songFolderList[indexPath.row])
                .subscribe(onCompleted: {
                    self.songFolderList.remove(at: indexPath.row)
                    completable(.completed)
                }, onError: { error in
                    completable(.error(error))
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}

extension ArchiveFolderListViewModel {
    var sectionCount: Int {
        return 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return songFolderList.count
    }
    
    func archiveFolderAtIndex(_ indexPath: IndexPath) -> ArchiveFolder {
        return songFolderList[indexPath.row]
    }
}

struct ArchiveFolderViewModel {
    var archiveFolder: ArchiveFolder
}
