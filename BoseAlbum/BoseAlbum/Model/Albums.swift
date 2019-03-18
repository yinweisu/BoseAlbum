//
//  Albums.swift
//  BoseAlbum
//
//  Created by Weisu Yin on 3/17/19.
//  Copyright © 2019 UCDavis. All rights reserved.
//

import Foundation
import UIKit

struct Albums: Decodable {
    var albumCounts: Int = 0
    var albums: [String] = []
}

protocol AlbumDelegate {
    func updateCollectionView()
}

struct Album {
    var delegate: AlbumDelegate?
    var photos: [UIImage] = [] {
        didSet {
            delegate?.updateCollectionView()
        }
    }
    var photoNames: [String] = []
}
