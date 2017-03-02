//
//  PresetViewController.swift
//  HIIT Timer
//
//  Created by Luís Machado on 20/10/16.
//  Copyright © 2016 LuisMachado. All rights reserved.
//

import UIKit

class PresetViewController: UIViewController, PresetViewProtocol {
    
    @IBOutlet var editingView: PresetEditView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var applyPresetButton: UIButton!
    
    var preset:Activity?
    var applyPreset:Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 55/255, green: 96/255, blue: 254/255, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.tintColor = UIColor.white
        
        editingView.setView(viewController: self)
        
        if let preset = preset {
            editingView.configurePreset(preset: preset)
            navigationItem.title = preset.name
        }
        
        applyPreset = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func enableButtons() {
        saveButton.isEnabled = true
        applyPresetButton.isEnabled = true
    }
    
    func disableButtons() {
        saveButton.isEnabled = false
        applyPresetButton.isEnabled = false
    }
    
    
    @IBAction func save(_ sender: AnyObject) {
        preset = editingView.getPreset()
        self.performSegue(withIdentifier: "unwindToPresetList", sender: self)
        
    }
    
    @IBAction func applyPreset(_ sender: AnyObject) {
        applyPreset = true
        save(self)
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        
        if presentingViewController is UINavigationController {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController!.popViewController(animated: true)
        }
        
    }
}
