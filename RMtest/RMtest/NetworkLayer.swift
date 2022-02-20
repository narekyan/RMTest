//
//  ViewController.swift
//  RMtest
//
//  Created by Narek on 20.02.22.
//

import UIKit
import Combine


enum Endpoint {
    case characters(_ page: Int)
    
    var rawValue: String {
        switch self {
        case .characters(let page):
            return "/character/?page=\(page)"
        }
    }
}

protocol INetworkLayer {
    func downloadImage(_ url: URL, completion: @escaping (Result<UIImage, Error>) -> Void)
    func get<T: Decodable>(_ endpoint: Endpoint, decodingType: T.Type) -> PassthroughSubject<T, Error>
}

class NetworkLayer: INetworkLayer {
    private var baseUrl: String!
    private var session: URLSession!
    private let imageCache: IImageCache!
    private var cancelables = Set<AnyCancellable>()
    
    init(baseUrl: String, imageCache: IImageCache, _ session: URLSession = URLSession.shared) {
        self.baseUrl = baseUrl
        self.imageCache = imageCache
        self.session = session
    }
    
    func get<T: Decodable>(_ endpoint: Endpoint, decodingType: T.Type) -> PassthroughSubject<T, Error> {
        let result = PassthroughSubject<T, Error>()
        if let url = URL(string: baseUrl + endpoint.rawValue) {
            session
                .dataTaskPublisher(for: url)
                .tryMap { data in
                    guard let httpResponse = data.response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                              throw URLError(.badServerResponse)
                          }
                    return data.data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .sink(
                    receiveCompletion: {completion in
                        result.send(completion: completion)
                    },
                    receiveValue: { data in
                        result.send(data)
                    }).store(in: &cancelables)
        } else {
            result.send(completion: .failure(RMError.wrongUrl))
        }
        return result
    }
    
    func downloadImage(_  url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let image = self.imageCache.getImage(forKey: url.absoluteString) {
            completion(.success(image))
            return
        }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            let imageData = data
            let operationError = error
            
            if let error = operationError {
                completion(.failure(error))
            } else if let imageData = imageData,
                      let image = UIImage(data: imageData) {
                
                self.imageCache.setImage(image, key: url.absoluteString)
                
                completion(.success(image))
            } else {
                completion(.failure(RMError.wrongImage))
            }
        }
        task.resume()
    }
}
