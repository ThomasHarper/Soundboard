//
//  SoundViewController.swift
//  Soundboard
//
//  Created by Thomas Bentkowski on 04/11/2016.
//  Copyright © 2016 Thomas Bentkowski. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    /////////////////// OUTLETS ////////////////////
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    ///////////////// PROPERTIES ///////////////////
    var audioRecorder : AVAudioRecorder?
    var audioPlayer : AVAudioPlayer?
    var audioURL : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Let's setup our AVAudioRecorder
        setupRecorder()
        
        // Disabling Play and Add button if there's no audio input
        playButton.isEnabled = false
        addButton.isEnabled = false
    }
    
    func setupRecorder() {
        // Create an audio session that allows us to play and record audio
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.overrideOutputAudioPort(.speaker) // In order to play to speakers and not in ear speaker
            try session.setActive(true)
            
        // Create URL for the audio file
            let basePath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)
                
        // Create settings for the audioRecorder
            var settings : [String : AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
        // Create Audio Recorder Object
            audioRecorder =  try AVAudioRecorder(url: audioURL!, settings: settings)
            audioRecorder!.prepareToRecord()
        } catch let error as NSError {
            print(error)
        }
    }
    
    @IBAction func recordTapped(_ sender: AnyObject) {
        if audioRecorder!.isRecording {
            // Stop the recording
            audioRecorder?.stop()
            
            // Change button title to "Record"
            recordButton.setTitle("Record", for: .normal)
            
            // Enabling Play and Add button if there's an audio input
            playButton.isEnabled = true
            addButton.isEnabled = true
        } else {
            // Start the recording
            audioRecorder?.record()
            
            // Change button title to "Stop"
            recordButton.setTitle("Stop", for: .normal)
        }
    }
    
    @IBAction func playTapped(_ sender: AnyObject) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL!)
            audioPlayer?.play()
        } catch {}
    }
    
    @IBAction func addTapped(_ sender: AnyObject) {
        // Instantiating the context for coreData
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let sound = Sound(context: context)
        
        // Setting Sound attributes
        sound.name = nameTextField.text
        sound.audio = NSData(contentsOf: audioURL!)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
