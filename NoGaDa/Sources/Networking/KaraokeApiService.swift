//
//  KaraokeManager.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/20.
//

import UIKit

import RxSwift
import RxCocoa


final class KaraokeApiService {
  
  // MARK: - Properties
  
  private var disposeBag = DisposeBag()
  
  
  // MARK: - Methods
  
  public func fetchUpdatedSong(brand: KaraokeBrand) -> Single<[Song]> {
    return Single.create { observer in
      guard let basePath = URL(string: KaraokeAPIPath.basePath.rawValue) else {
        observer(.failure(KaraokeAPIError.urlParsingError))
        return Disposables.create()
      }
      
      let path = basePath
        .appendingPathComponent(brand.path)
      
      var request         = URLRequest(url: path)
      request.httpMethod  = "GET"
      
      URLSession.shared.dataTask(with: request) { jsonData, response, error in
        guard let jsonData = jsonData else {
          observer(.failure(KaraokeAPIError.didNotReceiveData))
          return
        }
        
        guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
          observer(.failure(KaraokeAPIError.httpRequestFailure))
          return
        }
        
        guard let newSongs = try? JSONDecoder().decode([Song].self, from: jsonData) else {
          observer(.failure(KaraokeAPIError.jsonParsingError))
          return
        }
        
        observer(.success(newSongs))
      }.resume()
      
      return Disposables.create()
    }
  }
  
  public func fetchSong(term: String, brand: KaraokeBrand) -> Single<[Song]> {
    return Single.create { observer in
      var term = term
      if term.isKorean() {
        term.removeAllEmptySpaces()
      }
      
      guard let basePath = URL(string: KaraokeAPIPath.basePath.rawValue) else {
        observer(.failure(KaraokeAPIError.urlParsingError))
        return Disposables.create()
      }
      
      let path = basePath
        .appendingPathComponent(KaraokeAPIPath.song.rawValue)
        .appendingPathComponent("\(term)\(brand.path)")
      
      var request         = URLRequest(url: path)
      request.httpMethod  = "GET"
      
      URLSession.shared.dataTask(with: request) { jsonData, response, error in
        guard let jsonData = jsonData else {
          observer(.failure(KaraokeAPIError.didNotReceiveData))
          return
        }
        
        guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
          observer(.failure(KaraokeAPIError.httpRequestFailure))
          return
        }
        
        guard let songs = try? JSONDecoder().decode([Song].self, from: jsonData) else {
          observer(.failure(KaraokeAPIError.jsonParsingError))
          return
        }
        
        observer(.success(songs))
      }.resume()
      
      return Disposables.create()
    }
  }
  
  public func fetchSong(singer: String, brand: KaraokeBrand) -> Single<[Song]> {
    return Single.create { observer in
      guard let basePath = URL(string: KaraokeAPIPath.basePath.rawValue) else {
        observer(.failure(KaraokeAPIError.urlParsingError))
        return Disposables.create()
      }
      
      let path = basePath
        .appendingPathComponent(KaraokeAPIPath.singer.rawValue)
        .appendingPathComponent("\(singer)\(brand.path)")
      
      var request         = URLRequest(url: path)
      request.httpMethod  = "GET"
      
      URLSession.shared.dataTask(with: request) { jsonData, response, error in
        guard let jsonData = jsonData else {
          observer(.failure(KaraokeAPIError.didNotReceiveData))
          return
        }
        
        guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
          observer(.failure(KaraokeAPIError.httpRequestFailure))
          return
        }
        
        guard let songs = try? JSONDecoder().decode([Song].self, from: jsonData) else {
          observer(.failure(KaraokeAPIError.jsonParsingError))
          return
        }
        
        observer(.success(songs))
      }.resume()
      
      return Disposables.create()
    }
  }
  
  public func fetchSong(titleOrSinger: String, brand: KaraokeBrand) -> Single<[Song]> {
    let fetchWithTitle      = fetchSong(term: titleOrSinger, brand: brand).asObservable()
    let fetchWithSinger     = fetchSong(singer: titleOrSinger, brand: brand).asObservable()

    return Single.create { [weak self] observer in
      guard let self = self else { return Disposables.create() }

      if UserDefaultsManager.searchWithTitle == true &&
          UserDefaultsManager.searchWithSinger == true {
        // Search with singer & title
        Observable.combineLatest(
          fetchWithTitle,
          fetchWithSinger,
          resultSelector: { resultWithTitle, resultWithSinger in
          return Array(Set(resultWithTitle).union(Set(resultWithSinger))).sorted{ $0.title < $1.title }
        }).subscribe(onNext: { combinedSongResultList in
          observer(.success(combinedSongResultList))
        }, onError: { error in
          observer(.failure(error))
        }).disposed(by: self.disposeBag)
        
      }
      else if UserDefaultsManager.searchWithTitle == true &&
                UserDefaultsManager.searchWithSinger == false {
        // Search with title
        fetchWithTitle
          .subscribe(onNext: { songs in
            observer(.success(songs))
          }, onError: { error in
            observer(.failure(error))
          })
          .disposed(by: self.disposeBag)
        
      }
      else if UserDefaultsManager.searchWithTitle == false &&
                UserDefaultsManager.searchWithSinger == true {
        // Search with singer
        fetchWithSinger
          .subscribe(onNext: { songs in
            observer(.success(songs))
          }, onError: { error in
            observer(.failure(error))
          })
          .disposed(by: self.disposeBag)
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
