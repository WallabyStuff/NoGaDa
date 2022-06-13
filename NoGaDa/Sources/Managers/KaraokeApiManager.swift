//
//  KaraokeManager.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/20.
//

import UIKit

import RxSwift
import RxCocoa

class KaraokeApiManager {
    
    private var disposeBag = DisposeBag()
    
    public func fetchUpdatedSong(brand: KaraokeBrand) -> Observable<[Song]> {
        return Observable.create { observer in
            DispatchQueue.global(qos: .background).async {
                let fullPath = "\(KaraokeAPIPath.basePath.rawValue)\(brand.path)".urlEncode()
                
                guard let url = URL(string: fullPath) else {
                    observer.onError(KaraokeAPIErrMessage.urlParsingError)
                    return
                }
                
                var request         = URLRequest(url: url)
                request.httpMethod  = "GET"
                
                URLSession.shared.dataTask(with: request) { jsonData, response, error in
                    guard let jsonData = jsonData else {
                        observer.onError(KaraokeAPIErrMessage.didNotReceiveData)
                        return
                    }
                    
                    guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                        observer.onError(KaraokeAPIErrMessage.httpRequestFailure)
                        return
                    }
                    
                    guard let updatedSongList = try? JSONDecoder().decode([Song].self, from: jsonData) else {
                        observer.onError(KaraokeAPIErrMessage.jsonParsingError)
                        return
                    }
                    
                    observer.onNext(updatedSongList)
                    observer.onCompleted()
                }.resume()
            }
            
            return Disposables.create()
        }
    }
    
    public func fetchSong(title: String, brand: KaraokeBrand) -> Observable<[Song]> {
        return Observable.create { observer in
            DispatchQueue.global(qos: .background).async {
                let fullPath = "\(KaraokeAPIPath.basePath.rawValue)\(KaraokeAPIPath.song.rawValue)/\(title)\(brand.path)".urlEncode()
                
                guard let url = URL(string: fullPath) else {
                    observer.onError(KaraokeAPIErrMessage.urlParsingError)
                    return
                }
                
                var request         = URLRequest(url: url)
                request.httpMethod  = "GET"
                
                URLSession.shared.dataTask(with: request) { jsonData, response, error in
                    guard let jsonData = jsonData else {
                        observer.onError(KaraokeAPIErrMessage.didNotReceiveData)
                        return
                    }
                    
                    guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                        observer.onError(KaraokeAPIErrMessage.httpRequestFailure)
                        return
                    }
                    
                    guard let searchResultSongList = try? JSONDecoder().decode([Song].self, from: jsonData) else {
                        observer.onError(KaraokeAPIErrMessage.jsonParsingError)
                        return
                    }
                    
                    observer.onNext(searchResultSongList)
                }.resume()
            }
            
            return Disposables.create()
        }
    }
    
    public func fetchSong(singer: String, brand: KaraokeBrand) -> Observable<[Song]> {
        return Observable.create { observer in
            DispatchQueue.global(qos: .background).async {
                let fullPath = "\(KaraokeAPIPath.basePath.rawValue)\(KaraokeAPIPath.singer.rawValue)/\(singer)\(brand.path)".urlEncode()
                
                guard let url = URL(string: fullPath) else {
                    observer.onError(KaraokeAPIErrMessage.urlParsingError)
                    return
                }
                
                var request         = URLRequest(url: url)
                request.httpMethod  = "GET"
                
                URLSession.shared.dataTask(with: request) { jsonData, response, error in
                    guard let jsonData = jsonData else {
                        observer.onError(KaraokeAPIErrMessage.didNotReceiveData)
                        return
                    }
                    
                    guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                        observer.onError(KaraokeAPIErrMessage.httpRequestFailure)
                        return
                    }
                    
                    guard let searchResultSongList = try? JSONDecoder().decode([Song].self, from: jsonData) else {
                        observer.onError(KaraokeAPIErrMessage.jsonParsingError)
                        return
                    }
                    
                    observer.onNext(searchResultSongList)
                }.resume()
            }
            
            return Disposables.create()
        }
    }
    
    public func fetchSong(titleOrSinger: String, brand: KaraokeBrand) -> Observable<[Song]> {
        let fetchWithTitle      = fetchSong(title: titleOrSinger, brand: brand)
        let fetchWithSinger     = fetchSong(singer: titleOrSinger, brand: brand)
        
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            if SearchFilterItem.searchWithTitle.state && SearchFilterItem.searchWithSinger.state {
                // Search with singer & title
                Observable.combineLatest(fetchWithTitle, fetchWithSinger, resultSelector: { resultWithTitle, resultWithSinger in
                    return Array(Set(resultWithTitle).union(Set(resultWithSinger))).sorted{ $0.title < $1.title }
                }).subscribe(onNext: { combinedSongResultList in
                    observer.onNext(combinedSongResultList)
                }, onError: { error in
                    observer.onError(error)
                }).disposed(by: self.disposeBag)
            } else if SearchFilterItem.searchWithTitle.state && !SearchFilterItem.searchWithSinger.state {
                // Search with title
                self.fetchSong(title: titleOrSinger, brand: brand)
                    .subscribe(onNext: { searchResultSongList in
                        observer.onNext(searchResultSongList)
                    }, onError: { error in
                        observer.onError(error)
                    }).disposed(by: self.disposeBag)
            } else {
                // Search with singer
                self.fetchSong(singer: titleOrSinger, brand: brand)
                    .subscribe(onNext: { searchResultSongList in
                        observer.onNext(searchResultSongList)
                    }, onError: { error in
                        observer.onError(error)
                    }).disposed(by: self.disposeBag)
            }
            
            return Disposables.create()
        }
    }
}

extension String {
    func urlEncode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
