//
//  ViewController.swift
//  HIIT Timer
//
//  Created by Luís Machado on 10/10/16.
//  Copyright © 2016 LuisMachado. All rights reserved.
//

import UIKit

class StartActivityViewController: UIViewController, PresetViewProtocol {

    @IBOutlet var editingView: PresetEditView!
    @IBOutlet var startButton: UIButton!
    var currentPreset: Activity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 55/255, green: 96/255, blue: 254/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
        
        if let savedCurrentPresetData = UserDefaults.standard.object(forKey: "currentPreset") {
            if let savedCurrentPreset = NSKeyedUnarchiver.unarchiveObject(with: savedCurrentPresetData as! Data) {
                currentPreset =  savedCurrentPreset as! Activity
            }
        }
        
        if currentPreset == nil {
            currentPreset = Activity(name: "", exerciseDistance: 0, exerciseSeconds: 0, restDistance: 0, restSeconds: 0, exerciseModeIsDistance: true, restModeIsDistance: false, numOfRepeats: 1)!
        }
        
        editingView.hideName()
        editingView.setView(viewController: self)
        editingView.configurePreset(preset: currentPreset)
        
    }
    
    func enableButtons() {
        startButton.isEnabled = true
    }
    
    func disableButtons() {
        startButton.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let data:Data = NSKeyedArchiver.archivedData(withRootObject: editingView.getPreset())
        UserDefaults.standard.set(data, forKey: "currentPreset")        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "StartActivity" {
            let activityViewController = segue.destination as! ActivityViewController
            
            activityViewController.activity = editingView.getPreset()
        }
        else if segue.identifier == "AddExercise" {
            print("ViewController: Adding new exercise.")
        }
    }
    
    @IBAction func unwindToStartActivity(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? PresetListViewController, let preset = sourceViewController.selectedPreset {
            editingView.configurePreset(preset: preset)
        }
    }

}

