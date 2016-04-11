//
//  ViewController.swift
//  MusicLooper
//
//  Created by 藤原和樹 on 2016/04/11.
//  Copyright © 2016年 mycompany. All rights reserved.
//


import UIKit
import MediaPlayer
import AVFoundation
import Foundation

class ViewController: UIViewController, MPMediaPickerControllerDelegate {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var rateSlider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var repeatButton: UIButton!
    
    @IBOutlet weak var startSlider: UISlider!
    @IBOutlet weak var endSlider: UISlider!
    @IBOutlet weak var panL: UIButton!
    @IBOutlet weak var panLR: UIButton!
    @IBOutlet weak var panR: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    
    
    var audioPlayer:AVAudioPlayer?
    var startTime:NSTimeInterval?
    var endTime: NSTimeInterval?
    var repeatFlag: Bool = false
    
    var timer: NSTimer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        repeatFlag = false
        repeatButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        
        startSlider.setThumbImage(UIImage(named:"arrow_green.png"), forState: .Normal)
        endSlider.setThumbImage(UIImage(named:"arrow_red.png"), forState: .Normal)
        timeSlider.setThumbImage(UIImage(named:"player.png"), forState: .Normal)
    }
    
    @IBAction func pick(sender: AnyObject) {
        let picker = MPMediaPickerController()
        picker.delegate = self
        picker.allowsPickingMultipleItems = false
        presentViewController(picker, animated: true, completion: nil)
        
    }
    
    // called after picking item by MediaItemPicker
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        defer {
            dismissViewControllerAnimated(true, completion: nil)
        }
        
        let items = mediaItemCollection.items
        if items.isEmpty {
            return
        }
        
        
        let item = items[0]
        if let url: NSURL = item.assetURL {
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: url)
            } catch  {
                messageLabel.text = "cannot play this URL"
                
                audioPlayer = nil
                
                return
            }
            
            if let player = audioPlayer {
                
                player.enableRate = true
                durationLabel.text = String("\(Int(player.duration))")
                timeSlider.minimumValue = 0.0
                timeSlider.maximumValue = Float(player.duration)
                startSlider.minimumValue = 0.0
                startSlider.maximumValue = Float(player.duration)
                endSlider.minimumValue = 0.0
                endSlider.maximumValue = Float(player.duration)
                
                startSlider.value = 0.0
                endSlider.value = Float(player.duration)
                
                startTime = 0.0
                endTime = player.duration
                startLabel.text = String("\(Int(startTime!))")
                endLabel.text = String("\(Int(endTime!))")
                
                player.play()
                
                let title = item.title ?? ""
                messageLabel.text = title
                
                timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "timeFunc", userInfo: nil, repeats: true)
                
            }
        } else {
            messageLabel.text = "nil"
            
            audioPlayer = nil
        }
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func timeFunc() {
        if let player = audioPlayer {
            currentTimeLabel.text = String("\(Int(player.currentTime))")
            timeSlider.value = Float(player.currentTime)
            
            if (repeatFlag == true && startTime != nil && endTime != nil) {
                if (player.currentTime > endTime) {
                    player.currentTime = NSTimeInterval(startTime!)
                }
            }
        }
    }
    
    @IBAction func timeChanged(sender: AnyObject) {
        if let player = audioPlayer {
            player.currentTime = NSTimeInterval(timeSlider.value)
        }
        
    }
    
    @IBAction func pushPlay(sender: AnyObject) {
        if let player = audioPlayer {
            player.play()
        }
    }
    
    @IBAction func pushPause(sender: AnyObject) {
        if let player = audioPlayer {
            player.pause()
        }
    }
    
    @IBAction func pushStop(sender: AnyObject) {
        if let player = audioPlayer {
            player.stop()
        }
    }
    
    @IBAction func changeRate(sender: AnyObject) {
        if let player = audioPlayer {
            player.rate = rateSlider.value
            rateLabel.text = String("x \(rateSlider.value)")
        }
    }
    
    @IBAction func resetRate(sender: AnyObject) {
        if let player = audioPlayer {
            player.rate = 1.0
            rateSlider.value = 1.0
            rateLabel.text = String("\(rateSlider.value)")
        }
    }
    
    @IBAction func setStartTime(sender: AnyObject) {
        if let player = audioPlayer {
            
            startTime = player.currentTime
            startSlider.value = Float(startTime!)
            
            startLabel.text = String("\(startTime!)")
            if (startTime > endTime) {
                endTime = startTime
                endSlider.value = startSlider.value
            }
            repeatFlag = false
            repeatButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            startLabel.text = String("\(Int(startTime!))")
            endLabel.text = String("\(Int(endTime!))")
        }
        
    }
    
    @IBAction func setEndTime(sender: AnyObject) {
        if let player = audioPlayer {
            
            endTime = player.currentTime
            endSlider.value = Float(endTime!)
            
            repeatFlag = false
            repeatButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            
            
            if (startTime > endTime) {
                startTime = endTime
                startSlider.value = endSlider.value
            }
            
            
            startLabel.text = String("\(Int(startTime!))")
            endLabel.text = String("\(Int(endTime!))")
        }
    }
    
    @IBAction func pushRepeatButton(sender: AnyObject) {
        if let player = audioPlayer {
            if (repeatFlag == false) {
                repeatFlag = true
                repeatButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
                
                let current = player.currentTime
                if (current < startTime) {
                    player.currentTime = startTime!
                } else if (endTime < current) {
                    player.currentTime = startTime!
                } else {
                    
                }
                
            } else {
                repeatFlag = false
                repeatButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
                
            }
        }
    }
    
    @IBAction func changeStartSlider(sender: AnyObject) {
        
        if let player = audioPlayer {
            
            startTime = NSTimeInterval(startSlider.value)
            startLabel.text = String("\(Int(startTime!))")
            if (startTime > endTime) {
                endTime = startTime
                endSlider.value = startSlider.value
            }
            repeatFlag = false
            repeatButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            startLabel.text = String("\(Int(startTime!))")
            endLabel.text = String("\(Int(endTime!))")
            
            
            player.currentTime = NSTimeInterval(startSlider.value)
            currentTimeLabel.text = String("\(Int(player.currentTime))")
        }
    }
    
    @IBAction func changeEndSlider(sender: AnyObject) {
        
        if let player = audioPlayer {
            endTime = NSTimeInterval("\(endSlider.value)")
            repeatFlag = false
            repeatButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
            
            
            if (startTime > endTime) {
                startTime = endTime
                startSlider.value = endSlider.value
            }
            
            startLabel.text = String("\(Int(startTime!))")
            endLabel.text = String("\(Int(endTime!))")
        }
    }
    
    @IBAction func pushedPanL(sender: AnyObject) {
        if let player = audioPlayer {
            player.pan = -1.0
        }
        panL.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        panLR.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        panR.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
    }
    
    @IBAction func pushedPanLR(sender: AnyObject) {
        if let player = audioPlayer {
            player.pan = 0
        }
        panL.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        panLR.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        panR.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
    }
    
    @IBAction func pushedPanR(sender: AnyObject) {
        if let player = audioPlayer {
            player.pan = 1.0
        }
        panL.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        panLR.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        panR.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
    }
    
    @IBAction func changeVolume(sender: AnyObject) {
        if let player = audioPlayer {
            player.volume = volumeSlider.value
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
