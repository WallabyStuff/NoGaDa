//
//  PopUpSongOptionViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/12/14.
//

import Foundation

import RxSwift
import RxCocoa

class PopUpSongOptionViewModel {
    public var selectedSong: ArchiveSong?
    private var disposeBag = DisposeBag()
    private let songFolderManager = SongFolderManager()
    public var parentViewController: UIViewController?
    
    init() {
        fatalError("You must give 'parentViewController' and 'selectedSong' paramenter to initialize")
    }
    
    init(parentViewController: UIViewController, selectedSong: ArchiveSong) {
        self.parentViewController = parentViewController
        self.selectedSong = selectedSong
    }
}

extension PopUpSongOptionViewModel {
    var sectionCount: Int {
        return 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return songOptions.count
    }
    
    func optionAtIndex(_ indexPath: IndexPath) -> SongOption {
        return songOptions[indexPath.row]
    }
}

extension PopUpSongOptionViewModel {
    var songOptions: [SongOption] {
        let moveToOtherFolder = MoveToOtherFolder()
        let removeFromFolder = RemoveFromFolder()
        
        return [moveToOtherFolder, removeFromFolder]
    }
}

extension PopUpSongOptionViewModel {
    func deleteSong() -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self,
                  let selectedSong = self.selectedSong else {
                  return Disposables.create()
              }
            
            self.songFolderManager.deleteSong(song: selectedSong)
                .subscribe(onCompleted: {
                    observer(.completed)
                }, onError: { error in
                    observer(.error(error))
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}
