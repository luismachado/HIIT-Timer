//
//  PresetListViewController.swift
//  HIIT Timer
//
//  Created by Luís Machado on 20/10/16.
//  Copyright © 2016 LuisMachado. All rights reserved.
//

import UIKit

class PresetListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var presets = [Activity]()
    var selectedPreset:Activity?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        // Load any saved meals, otherwise load sample data.
        if let savedPresets = loadPresets() {
            presets += savedPresets
        } else {
            // Load the sample data.
            let exercise =  Activity(name: "Preset 1", exerciseDistance: 100, exerciseSeconds: 0, restDistance: 0, restSeconds: 60, exerciseModeIsDistance: true, restModeIsDistance: false, numOfRepeats: 3)!
            let exercise1 = Activity(name: "Preset 2", exerciseDistance: 200, exerciseSeconds: 0, restDistance: 0, restSeconds: 20, exerciseModeIsDistance: true, restModeIsDistance: false, numOfRepeats: 4)!
            let exercise2 = Activity(name: "Preset 3", exerciseDistance: 100, exerciseSeconds: 15, restDistance: 123, restSeconds: 60, exerciseModeIsDistance: false, restModeIsDistance: true, numOfRepeats: 5)!
            presets.append(exercise)
            presets.append(exercise1)
            presets.append(exercise2)
        }

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presets.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PresetCell", for: indexPath)
        let preset = presets[indexPath.row]
        
        cell.textLabel?.text = preset.name
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            presets.remove(at: (indexPath as NSIndexPath).row)
            savePresets()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditPreset" {
            let presetViewController = segue.destination as! PresetViewController
            // Get the cell that generated this segue.
            if let selectedPresetCell = sender as? UITableViewCell {
                let indexPath = tableView.indexPath(for: selectedPresetCell)!
                let selectedPreset = presets[(indexPath as NSIndexPath).row]
                
                presetViewController.preset = selectedPreset
            }
        }
        else if segue.identifier == "AddPreset" {
            print("PresetListViewController: Adding new preset.")
        }
    }
    
    @IBAction func unwindToPresetList(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? PresetViewController, let preset = sourceViewController.preset, let toApplyPreset = sourceViewController.applyPreset {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing preset.
                presets[(selectedIndexPath as NSIndexPath).row] = preset
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                // Add a new preset.
                presets.append(preset)
                tableView.reloadData()
            }
            // Save the presets.
            savePresets()
            // Unwind to previous screen and apply preset
            if toApplyPreset {
                selectedPreset = preset
                self.performSegue(withIdentifier: "unwindToStart", sender: self)
            }
        }
    }
    
    // MARK: NSCoding
    func savePresets() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(presets, toFile: Activity.ArchiveURL.path)
        if !isSuccessfulSave {
            print("PresetListViewController: Failed to save presets...")
        }
    }
    
    func loadPresets() -> [Activity]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Activity.ArchiveURL.path) as? [Activity]
    }
    

}
