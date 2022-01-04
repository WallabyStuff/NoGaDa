//
//  PopUpSongFolderListViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/22.
//

import Foundation
import RxSwift
import RxCocoa

class PopUpArchiveFolderListViewModel {
    private var disposeBag = DisposeBag()
    private var selectedSong: Song?
    private let songFolderManager = SongFolderManager()
    private var songFolderList = [ArchiveFolder]()
    
    init(selectedSong: Song) {
        self.selectedSong = selectedSong
    }
}

extension PopUpArchiveFolderListViewModel {
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

extension PopUpArchiveFolderListViewModel {
    func addSong(_ songFolder: ArchiveFolder, _ song: Song) -> Completable {
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

extension PopUpArchiveFolderListViewModel {
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

extension PopUpArchiveFolderListViewModel {
    private func deleteFolder(_ indexPath: IndexPath) -> Completable {
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

// MARK: - Alerts🔔
extension PopUpArchiveFolderListViewModel {
    public func presentRemoveFolderAlert(viewController: UIViewController, indexPath: IndexPath) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            let selectedFolder = self.songFolderList[indexPath.row]
            let removeFolderAlert = UIAlertController(title: "삭제",
                                                      message: "정말로 「\(selectedFolder.titleEmoji)\(selectedFolder.title)」 를 삭제하시겠습니까?",
                                                      preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "취소", style: .destructive)
            let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] action in
                guard let self = self else { return }
                
                self.deleteFolder(indexPath)
                    .subscribe(onCompleted: {
                        observer(.completed)
                    }).disposed(by: self.disposeBag)
            }
            
            removeFolderAlert.addAction(confirmAction)
            removeFolderAlert.addAction(cancelAction)
            viewController.present(removeFolderAlert, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }
    
    public func presentAddSongAlert(viewController: UIViewController, indexPath: IndexPath) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self,
                  let selectedSong = self.selectedSong else { return Disposables.create() }
            
            let targetFolder = self.songFolderList[indexPath.row]
            let addSongAlert = UIAlertController(title: "저장",
                                                 message: "「\(selectedSong.title)」를 「\(targetFolder.title)」에 저장하시겠습니까?",
                                                 preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "취소", style: .destructive)
            let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] action in
                guard let self = self else { return }
                
                self.addSong(targetFolder, selectedSong)
                    .observe(on: MainScheduler.instance)
                    .subscribe(with: self, onCompleted: { vc in
                        observer(.completed)
                    }, onError: { vc, error in
                        guard let error = error as? SongFolderManagerError else { return }
                        
                        if error == .alreadyExists {
                            self.presentAlreadyExitstAlert(viewController)
                                .subscribe(onError: { error in
                                    observer(.error(error))
                                }).disposed(by: self.disposeBag)
                        }
                    }).disposed(by: self.disposeBag)
            }
            
            addSongAlert.addAction(confirmAction)
            addSongAlert.addAction(cancelAction)
            viewController.present(addSongAlert, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }
    
    public func presentAlreadyExitstAlert(_ viewController: UIViewController) -> Completable {
        return Completable.create { observer in
            let alreadyExistsAlert = UIAlertController(title: "알림",
                                                       message: "이미 저장된 곡입니다.",
                                                       preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "확인", style: .cancel) { _ in
                observer(.completed)
            }
            
            alreadyExistsAlert.addAction(confirmAction)
            viewController.present(alreadyExistsAlert, animated: true, completion: nil)
            
            return Disposables.create()
        }
    }
}
