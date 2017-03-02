//
//  CountdownViewController.swift
//  HIIT Timer
//
//  Created by Luís Machado on 31/10/16.
//  Copyright © 2016 LuisMachado. All rights reserved.
//

import UIKit
import AudioToolbox

class CountdownViewController: UIViewController {

    @IBOutlet var counterLabel: UILabel!
    var counter:Int = 3
    lazy var timer = Timer()
    var soundID:SystemSoundID = 0
    var soundID_End:SystemSoundID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        counterLabel.text = "\(counter)"
        
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = UIColor(red: 55/255, green: 96/255, blue: 254/255, alpha: 1)
        
        var fileURL = NSURL(string: "/System/Library/Audio/UISounds/Tink.caf")
        AudioServicesCreateSystemSoundID(fileURL!, &soundID)
        //fileURL = NSURL(string: "/System/Library/Audio/UISounds/begin_record.caf")
        fileURL = NSURL(string: "/System/Library/Audio/UISounds/alarm.caf")
        AudioServicesCreateSystemSoundID(fileURL!, &soundID_End)
        AudioServicesPlaySystemSound(soundID);
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(CountdownViewController.count), userInfo: nil, repeats: true)
    }
    
    func count() {
        
        counter -= 1
        if counter <= 0 {            
            AudioServicesPlaySystemSound(soundID_End);
            self.performSegue(withIdentifier: "unwindToStart", sender: self)
        } else {
            counterLabel.text = "\(counter)"
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            AudioServicesPlaySystemSound(soundID);
        }
    
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    

    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        timer.invalidate()
        self.navigationController?.isNavigationBarHidden = false
    }

}
