//
//  ViewController.swift
//  RMtest
//
//  Created by Narek on 20.02.22.
//

import UIKit
import Combine


protocol IViewModel {
    var items: [Item] { get }
    func getNextItems() -> PassthroughSubject<Never, Error>
    func getImage(_ index: Int) -> AnyPublisher<UIImage?, Never>
}

final class ViewModel: IViewModel {
    
    @Published var items = [Item]()
    private var networkLayer: INetworkLayer!
    private var page = 1
    private var inProcess = false
    private var cancelables = Set<AnyCancellable>()
    
    init(_ networkLayer: INetworkLayer) {
        self.networkLayer = networkLayer
    }
    
    func getNextItems() -> PassthroughSubject<Never, Error> {
        let result = PassthroughSubject<Never, Error>()
        if inProcess {
            result.send(completion: .failure(RMError.inProcess))
            return result
        }
        inProcess = true
        
        networkLayer.get(.characters(page), decodingType: Response.self).sink { [weak self] completion in
            DispatchQueue.main.async {
                result.send(completion: completion)
            }
            guard let self = self else { return }
            print("finished page=\(self.page)")
            self.page += 1
            self.inProcess = false
        } receiveValue: { [weak self] response in
            self?.items.append(contentsOf: response.results)
            self?.inProcess = false
        }.store(in: &cancelables)
        return result
    }
    
    func getImage(_ index: Int) -> AnyPublisher<UIImage?, Never> {
        let result = CurrentValueSubject<UIImage?, Never>(nil)
        if let url = URL(string: items[index].image) {
            networkLayer.downloadImage(url) { response in
                switch response {
                case .failure(_):
                    DispatchQueue.main.async {
                        result.send(nil)
                    }
                case .success(let image):
                    DispatchQueue.main.async {
                        result.send(image)
                    }
                }
            }
        } else {
            result.send(nil)
        }
        return result.eraseToAnyPublisher()
    }
}
