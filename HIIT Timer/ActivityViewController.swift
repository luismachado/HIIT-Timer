//
//  ActivityViewController.swift
//  HIIT Timer
//
//  Created by Luís Machado on 10/10/16.
//  Copyright © 2016 LuisMachado. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import AudioToolbox

class ActivityViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var map: MKMapView!
    @IBOutlet var remainingSets: UILabel!
    @IBOutlet var currentMode: UILabel!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var remainingValue: UILabel!
    
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    
    var locationManager = CLLocationManager()
    var currentSet:Int = 1
    var lastSavedLocation: CLLocation!
    var traveledDistance:Double = 0
    var currentTargetIsDistance:Bool = true
    var remaining:Int = 0
    var initial:Int = 0
    lazy var timer = Timer()
    let timerValue: Double = 0.1
    var paused:Bool = false
    
    var soundID:SystemSoundID = 0
    var soundID_End:SystemSoundID = 0
    
    //Exercise setup
    var activity: Activity = Activity(name: "name", exerciseDistance: 100, exerciseSeconds: 0, restDistance: 0, restSeconds: 60, exerciseModeIsDistance: true, restModeIsDistance: false, numOfRepeats: 5)!
    
    @IBOutlet var currentModeLabel: UILabel!
    var currentModeIsExercise:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        //var fileURL = NSURL(string: "/System/Library/Audio/UISounds/alarm.caf")
        var fileURL = NSURL(string: "/System/Library/Audio/UISounds/alarm.caf")
        AudioServicesCreateSystemSoundID(fileURL!, &soundID)
        fileURL = NSURL(string: "/System/Library/Audio/UISounds/sms-received3.caf")
        AudioServicesCreateSystemSoundID(fileURL!, &soundID_End)
        
        pauseButton.layer.cornerRadius = pauseButton.bounds.size.width * 0.5
        pauseButton.backgroundColor = UIColor.white
        pauseButton.setImage(UIImage(named: "pause.ico"), for: .normal)
        
        pauseButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        pauseButton.clipsToBounds = false
        pauseButton.layer.borderWidth = 2
        pauseButton.layer.borderColor = UIColor(red: 55/255, green: 98/255, blue: 254/255, alpha: 1).cgColor
        pauseButton.layer.shadowColor = UIColor.gray.cgColor
        pauseButton.layer.shadowOpacity = 0.5
        pauseButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        pauseButton.layer.shadowRadius = 2
        
        stopButton.layer.cornerRadius = pauseButton.bounds.size.width * 0.5
        stopButton.backgroundColor = UIColor(red: 55/255, green: 98/255, blue: 254/255, alpha: 1)
        stopButton.setImage(UIImage(named: "stop.png"), for: .normal)
        stopButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        stopButton.clipsToBounds = false
        stopButton.layer.borderWidth = 2
        stopButton.layer.borderColor = UIColor.white.cgColor
        stopButton.layer.shadowColor = UIColor.gray.cgColor
        stopButton.layer.shadowOpacity = 0.5
        stopButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        stopButton.layer.shadowRadius = 2
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = CLActivityType.fitness
        locationManager.distanceFilter = 10
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        map.delegate = self
        
        currentMode.text = "EXERCISE"
        
        if activity.numOfRepeats == -1 {
            remainingSets.text = "\(currentSet) / ∞"
        } else {
            remainingSets.text = "\(currentSet) / \(activity.numOfRepeats)"
        }
        
        
        remaining = 30
        performSegue(withIdentifier: "ShowTimer", sender: self)
        
        
        
    }
    
    func changeMode() {
        
        timer.invalidate()
        traveledDistance = 0.0
        lastSavedLocation = nil
        map.removeOverlays(map.overlays)
        
        if currentModeIsExercise {
            currentModeIsExercise = false
            currentMode.text = "REST"
            AudioServicesPlaySystemSound(soundID);
            startMode()
            
        } else {
            if activity.numOfRepeats == -1 || currentSet < activity.numOfRepeats {
                currentSet += 1
                currentModeIsExercise = true
                currentMode.text = "EXERCISE"
                performSegue(withIdentifier: "ShowTimer", sender: self)
            } else {
                remainingValue.text = "FINISHED!"
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                AudioServicesPlaySystemSound(soundID_End);
                
                
                pauseButton.isEnabled = false
                pauseButton.layer.borderColor = UIColor.white.cgColor
                stopButton.setImage(UIImage(named: "flag.png"), for: .normal)
                stopButton.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15)
            }
        }
    }
    
    
    func startMode() {
        
        currentTargetIsDistance = currentModeIsExercise && activity.exerciseModeIsDistance || !currentModeIsExercise && activity.restModeIsDistance
        
        if currentTargetIsDistance {            
            if currentModeIsExercise {
                remaining = activity.exerciseDistance
            } else {
                remaining = activity.restDistance
            }
            
        } else {
            if currentModeIsExercise {
                remaining = activity.exerciseSeconds * 10 // count tenth of seconds
            } else {
                remaining = activity.restSeconds * 10 // count tenth of seconds
            }
        }
        
        initial = remaining
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        locationManager.startUpdatingLocation()
        timer = Timer.scheduledTimer(timeInterval: timerValue, target: self, selector: #selector(ActivityViewController.refreshValues), userInfo: nil, repeats: true)
        
        
    }
    
    @IBAction func unwindToStart(_ sender: UIStoryboardSegue) {
        
        startMode()
        
    }
    
    
    @IBOutlet var pause: UIButton!
    
    func refreshValues() {
        // Remaining Sets
        if activity.numOfRepeats == -1 {
            remainingSets.text = "\(currentSet) / ∞"
        } else {
            remainingSets.text = "\(currentSet) / \(activity.numOfRepeats)"
        }
        
        if currentTargetIsDistance {
            remaining = initial - Int(traveledDistance)
            if remaining <= 0 {
                changeMode()
            } else {
                remainingValue.text = "\(remaining) meters"
            }
        } else {
            remaining -= Int(timerValue * 10)
            if Float(remaining)/10.0 <= 3.0  && !currentModeIsExercise && (currentSet < activity.numOfRepeats || activity.numOfRepeats == -1) {
                changeMode()
            } else if remaining <= 0 {
                changeMode()
            } else {
                remainingValue.text = "\(Int(remaining/10)).\((remaining%10)*10) sec"
            }
        }
        
        progressBar.progress = Float(initial - remaining) / Float(initial)
    
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopActivity()
    }
    
    
    func resumeActivity() {
        
        refreshValues()
        timer = Timer.scheduledTimer(timeInterval: timerValue, target: self, selector: #selector(ActivityViewController.refreshValues), userInfo: nil, repeats: true)
        locationManager.startUpdatingLocation()
        
    }
    
    func pauseActivity() {
        stopActivity()
        self.lastSavedLocation = nil
        remainingValue.text = "PAUSED"
    }
    
    func stopActivity() {
        locationManager.stopUpdatingLocation()
        timer.invalidate()
    }
    
    func setPauseButton() {
        if paused {
            pauseButton.setImage(UIImage(named: "play.png"), for: .normal)
            pauseButton.imageEdgeInsets = UIEdgeInsetsMake(15,15, 15, 5)
        } else {
            pauseButton.setImage(UIImage(named: "pause.ico"), for: .normal)
            pauseButton.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        }
        
    }
    
    @IBAction func pausePressed(_ sender: Any) {
        
        if paused {
            resumeActivity()
        } else {
            pauseActivity()
        }
        
        paused = !paused
        setPauseButton()
    }
    
    @IBAction func Stop(_ sender: AnyObject) {
        
        stopActivity()
        navigationController!.popViewController(animated: true)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let lastLocation = locations.last {
            let howRecent = lastLocation.timestamp.timeIntervalSinceNow
            // Discard noisy gps points
            if abs(howRecent) < 12 && lastLocation.horizontalAccuracy < 17 && lastLocation.horizontalAccuracy >= 0 {

                if self.lastSavedLocation != nil {
                    traveledDistance += lastLocation.distance(from: lastSavedLocation)
                    
                    var coords = [CLLocationCoordinate2D]()
                    coords.append(lastSavedLocation.coordinate)
                    coords.append(lastLocation.coordinate)
                    
                    // Draw on the map TEMP
                    let region = MKCoordinateRegionMakeWithDistance(lastLocation.coordinate, 400, 400)
                    map.setRegion(region, animated: true)
                    if currentTargetIsDistance {
                        map.add(MKPolyline(coordinates: &coords, count: coords.count))
                    }    
                    
                    self.map.removeAnnotations(self.map.annotations)
                    
                    let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(lastLocation.coordinate.latitude, lastLocation.coordinate.longitude)
                    let objectAnnotation = MKPointAnnotation()
                    objectAnnotation.coordinate = pinLocation
                    self.map.addAnnotation(objectAnnotation)
                }
                
                lastSavedLocation = locations.last
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowTimer" {
            let countdownViewController = segue.destination as! CountdownViewController
            countdownViewController.counter = Int(round(Double(remaining)/10))
        }
        
        
    }
    

}

// MARK: - MKMapViewDelegate
extension ActivityViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        assert(overlay is MKPolyline, "overlay must be polyline")
        
        let polyline = overlay as! MKPolyline
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3
        return renderer
    }
}
