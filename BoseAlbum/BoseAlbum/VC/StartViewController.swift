//
//  ViewController.swift
//  BoseAlbum
//
//  Created by Weisu Yin on 3/15/19.
//  Copyright © 2019 UCDavis. All rights reserved.
//

import UIKit
import AVFoundation

var songPath: [URL]?
var mySongs: [String] = []
var songIndex = 0 {
    didSet {
        if songIndex >= mySongs.count {
            songIndex = 0
        }
        if songIndex < 0 {
            songIndex = mySongs.count - 1
        }
    }
}
var audioPlayer = AVAudioPlayer()

class StartViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gettingSongName()
        do {
            let audioPath = Bundle.main.path(forResource: mySongs[songIndex], ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            audioPlayer.play()
        }
        catch {
            print("Error loading music")
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func gettingSongName() {
        let folderURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
        
        do {
            songPath = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for song in songPath! {
                let mySong = song.absoluteString
                
                if mySong.contains(".mp3") {
                    var findString = mySong.components(separatedBy: "/").last
                    findString = findString?.replacingOccurrences(of: "%20", with: " ")
                    findString = findString?.replacingOccurrences(of: ".mp3", with: "")
                    mySongs.append(findString!)
                }
                print(mySongs)
            }
        } catch {
            
        }
    }


}

