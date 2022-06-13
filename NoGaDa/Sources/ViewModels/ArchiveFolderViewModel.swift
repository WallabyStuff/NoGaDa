//
//  ArchiveViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/21.
//

import Foundation
import RxSwift
import RxCocoa

class ArchiveFolderViewModel {
    
    
    // MARK: - Properties
    
    private var disposeBag = DisposeBag()
    private let folderManager = SongFolderManager()
    
    public var folders = BehaviorRelay<[ArchiveFolder]>(value: [])
    public var presentArchiveSongVC = PublishRelay<ArchiveFolder>()
}

extension ArchiveFolderViewModel {
    public func fetchFolders() {
        folderManager.fetchData()
            .subscribe(with: self, onNext: { strongSelf, folders in
                strongSelf.folders.accept(folders)
            }, onError: { strongSelf, error in
                print(error.localizedDescription)
            }).disposed(by: self.disposeBag)
    }
    
    public func deleteFolder(_ indexPath: IndexPath) {
        var folders = folders.value
        let selectedFolder = folders.remove(at: indexPath.row)
        
        folderManager.deleteData(selectedFolder)
            .subscribe(with: self, onCompleted: { strongSelf in
                strongSelf.folders.accept(folders)
            }, onError: { strongSelf, error in
                print(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}

extension ArchiveFolderViewModel {
    public func folderItemSelectAction(_ indexPath: IndexPath) {
        let selectedItem = folders.value[indexPath.row]
        presentArchiveSongVC.accept(selectedItem)
    }
    
    public func folderAt(_ indexPath: IndexPath) -> ArchiveFolder {
        return folders.value[indexPath.row]
    }
}
