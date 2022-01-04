//
//  AddSongViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/12/07.
//

import UIKit
import RxSwift
import RxCocoa


class AddSongViewModel {
    private var disposeBag = DisposeBag()
    private var targetFolderId: String?
    private var songFolderManager = SongFolderManager()
    
    init(targetFolderId: String) {
        self.targetFolderId = targetFolderId
    }
}

extension AddSongViewModel {
    public func addSong(title: String, singer: String, songNumber: String, brand: KaraokeBrand) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self,
                  let targetFolderId = self.targetFolderId else {
                      return Disposables.create()
                  }
            
            self.songFolderManager.fetchData(targetFolderId)
                .subscribe(onNext: { folder in
                    let song = Song(brand: brand,
                                    no: songNumber,
                                    title: title,
                                    singer: singer,
                                    composer: "",
                                    lyricist: "",
                                    release: "")
                    
                    self.songFolderManager.addSong(songFolder: folder, song: song)
                        .subscribe(onCompleted: {
                            observer(.completed)
                        }).disposed(by: self.disposeBag)
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}

extension AddSongViewModel {
    var numberOfComponents: Int {
        return 1
    }
    
    var numberOfRowsInComponent: Int {
        return KaraokeBrand.allCases.count
    }
    
    func titleForRowAt(_ index: Int) -> String {
        return KaraokeBrand.allCases[index].localizedString
    }
}
