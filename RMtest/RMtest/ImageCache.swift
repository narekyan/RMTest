//
//  ViewController.swift
//  RMtest
//
//  Created by Narek on 20.02.22.
//

import UIKit

protocol IImageCache {
    func setImage(_ image: UIImage?, key: String)
    func getImage(forKey key: String) -> UIImage?
}

final class ImageCache: IImageCache {
    private var memory = [String: UIImage]()
    private let group = DispatchQueue(label: "Serial")
    
    func setImage(_ image: UIImage?, key: String) {
        group.async {
            self.memory[key] = image
        }
    }
    
    func getImage(forKey key: String) -> UIImage? {
        group.sync {
            return self.memory[key]
        }
    }
}
