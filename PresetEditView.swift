//
//  PresetEditView.swift
//  HIIT Timer
//
//  Created by Luís Machado on 20/10/16.
//  Copyright © 2016 LuisMachado. All rights reserved.
//

import UIKit
@IBDesignable

class PresetEditView: UIView, UITextFieldDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var name: UITextField!
    @IBOutlet var exerciseToggle: UISegmentedControl!
    @IBOutlet var exerciseDistance: UITextField!
    @IBOutlet var exerciseMinutes: UITextField!
    @IBOutlet var exerciseTimeSeparator: UILabel!
    @IBOutlet var exerciseSeconds: UITextField!
    @IBOutlet var restToggle: UISegmentedControl!
    @IBOutlet var restDistance: UITextField!
    @IBOutlet var restMinutes: UITextField!
    @IBOutlet var restTimeSeparator: UILabel!
    @IBOutlet var restSeconds: UITextField!
    @IBOutlet var repeatSlider: UISlider!
    @IBOutlet var sliderLabel: UILabel!
    
    var textFieldsWithTime:[(UITextField)] = []
    
    @IBOutlet var nameLabelHeight: NSLayoutConstraint!
    @IBOutlet var nameTextFieldHeight: NSLayoutConstraint!
    @IBOutlet var exerciseDistanceHeight: NSLayoutConstraint!
    @IBOutlet var exerciseMinutesHeight: NSLayoutConstraint!
    @IBOutlet var exerciseTimeSeparatorHeight: NSLayoutConstraint!
    @IBOutlet var exerciseSecondsHeight: NSLayoutConstraint!
    @IBOutlet var restDistanceHeight: NSLayoutConstraint!
    @IBOutlet var restMinutesHeight: NSLayoutConstraint!
    @IBOutlet var restTimeSeparatorHeight: NSLayoutConstraint!
    @IBOutlet var restSecondsHeight: NSLayoutConstraint!
    
    let textBoxDefaultHeight:CGFloat = CGFloat(30)
    var labelDefaultHeight:CGFloat = CGFloat(21)
    
    var viewController: PresetViewProtocol!
    
    var exerciseModeIsDistance:Bool = true
    var restModeIsDistance:Bool = true
    var numberOfRepeats: Int = 2
    
    var contentView : UIView?
    
    func setView(viewController:PresetViewProtocol) {
        
                
        self.name.delegate = self
        self.exerciseDistance.delegate = self
        self.exerciseMinutes.delegate = self
        self.exerciseSeconds.delegate = self
        self.restDistance.delegate = self
        self.restMinutes.delegate = self
        self.restSeconds.delegate = self
        
        textFieldsWithTime.append(exerciseMinutes)
        textFieldsWithTime.append(exerciseSeconds)
        textFieldsWithTime.append(restMinutes)
        textFieldsWithTime.append(restSeconds)
        
        self.viewController = viewController
        
        updateVisibilities()
        checkValidFields()
        repeatSliderChanged(self)
    }
    
    func hideName() {
        nameLabelHeight.constant = 0
        nameTextFieldHeight.constant = 0
    }
    
    func configurePreset(preset: Activity) {
        
        self.name.text = preset.name
        
        exerciseModeIsDistance = preset.exerciseModeIsDistance
        restModeIsDistance = preset.restModeIsDistance
        
        if exerciseModeIsDistance {
            exerciseToggle.selectedSegmentIndex = 0
            let distance = Int(preset.exerciseDistance)
            if distance > 0 {
                exerciseDistance.text = "\(preset.exerciseDistance)"
            }
        } else {
            exerciseToggle.selectedSegmentIndex = 1
            
            let minutes = Int(preset.exerciseSeconds / 60)
            let seconds = preset.exerciseSeconds % 60
            
            if !(minutes == 0 && seconds == 0) {
                exerciseMinutes.text = "\(minutes)"
                exerciseSeconds.text = "\(seconds)"
            }
        }
        
        if restModeIsDistance {
            restToggle.selectedSegmentIndex = 0
            let distance = Int(preset.restDistance)
            if distance > 0 {
                restDistance.text = "\(preset.restDistance)"
            }
        } else {
            restToggle.selectedSegmentIndex = 1
            
            let minutes = Int(preset.restSeconds / 60)
            let seconds = preset.restSeconds % 60
            
            if !(minutes == 0 && seconds == 0) {
                restMinutes.text = "\(minutes)"
                restSeconds.text = "\(seconds)"
            }
        }
        
        if preset.numOfRepeats == -1 {
            repeatSlider.value = repeatSlider.maximumValue
        } else {
            repeatSlider.value = Float(preset.numOfRepeats)
        }
        
        textFieldTimeFormatter()
        updateVisibilities()
        checkValidFields()
        repeatSliderChanged(self)
    }    
   
    
    // TEXT FIELD CONSTRAINT SECONDS TO < 60 AND MINUTES TO <= 10
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if (textField === exerciseSeconds || textField === restSeconds || textField === exerciseMinutes || textField === restMinutes) {
            if let text = textField.text {
                let changedText = NSString(string: text).replacingCharacters(in: range, with: string)
                if let value = Int(changedText) {
                    if (textField === exerciseSeconds || textField === restSeconds) && value > 59 {
                        return false
                    } else if (textField === exerciseMinutes || textField === restMinutes) && value > 10 {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    func textFieldTimeFormatter() {
        
        for textField in textFieldsWithTime {
            if let value = Int(textField.text!) {
                if value < 10 {
                    textField.text = "0\(value)"
                }
            }
        }
        
        if exerciseMinutes.text != "" && exerciseSeconds.text == "" {
            exerciseSeconds.text = "00"
        }
        
        if restMinutes.text != "" && restSeconds.text == "" {
            restSeconds.text = "00"
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        textFieldTimeFormatter()
        checkValidFields()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        viewController.disableButtons()
    }
    
    func checkValidFields() {
        
        var buttonShouldBeEnabled: Bool = true
        
        if nameTextFieldHeight.constant > 0 {
            buttonShouldBeEnabled = buttonShouldBeEnabled && name.text != ""
        }
        
        if exerciseModeIsDistance {
            let distance = exerciseDistance.text ?? ""
            buttonShouldBeEnabled = buttonShouldBeEnabled && !distance.isEmpty && Int(distance)! > 0
        } else {
            let minutes = exerciseMinutes.text ?? ""
            let seconds = exerciseSeconds.text ?? ""
            buttonShouldBeEnabled = buttonShouldBeEnabled && ((!minutes.isEmpty && Int(minutes)! > 0) || (!seconds.isEmpty && Int(seconds)! > 0))
        }
        
        if restModeIsDistance {
            let distance = restDistance.text ?? ""
            buttonShouldBeEnabled = buttonShouldBeEnabled && !distance.isEmpty && Int(distance)! > 0
        } else {
            let minutes = restMinutes.text ?? ""
            let seconds = restSeconds.text ?? ""
            buttonShouldBeEnabled = buttonShouldBeEnabled && ((!minutes.isEmpty && Int(minutes)! > 0) || (!seconds.isEmpty && Int(seconds)! > 0))
        }
        
        if buttonShouldBeEnabled {
            viewController.enableButtons()
        } else {
            viewController.disableButtons()
        }
    }
    
    func getPreset() -> Activity {
        
        var exerciseDistanceValue = 0
        var exerciseSecondsValue = 0
        var restDistanceValue = 0
        var restSecondsValue = 0
        
        if exerciseModeIsDistance {
            if exerciseDistance.text != "" {
                exerciseDistanceValue = Int(exerciseDistance.text!)!
            }
        } else {
            if exerciseMinutes.text != "" {
                exerciseSecondsValue = 60 * Int(exerciseMinutes.text!)!
            }
            if exerciseSeconds.text != "" {
                exerciseSecondsValue += Int(exerciseSeconds.text!)!
            }
        }
        
        if restModeIsDistance {
            if restDistance.text != "" {
                restDistanceValue = Int(restDistance.text!)!
            }
        } else {
            if restMinutes.text != "" {
                restSecondsValue = 60 * Int(restMinutes.text!)!
            }
            if restSeconds.text != "" {
                restSecondsValue += Int(restSeconds.text!)!
            }
        }
        
        var sliderValue = Int(repeatSlider.value)
        if Float(sliderValue) == repeatSlider.maximumValue {
            sliderValue = -1
        }
        
        return Activity(name: name.text!, exerciseDistance: exerciseDistanceValue, exerciseSeconds: exerciseSecondsValue, restDistance: restDistanceValue, restSeconds: restSecondsValue, exerciseModeIsDistance: exerciseModeIsDistance, restModeIsDistance: restModeIsDistance, numOfRepeats: sliderValue)!
    }
    
    
    
    @IBAction func exerciseToggleChanged(_ sender: AnyObject) {
        exerciseModeIsDistance = !exerciseModeIsDistance
        updateVisibilities()
        checkValidFields()
    }
    
    @IBAction func restToggleChanged(_ sender: AnyObject) {
        restModeIsDistance = !restModeIsDistance
        updateVisibilities()
        checkValidFields()
    }
    
    func updateVisibilities() {
        if exerciseModeIsDistance {
            exerciseMinutesHeight.constant = 0
            exerciseTimeSeparatorHeight.constant = 0
            exerciseSecondsHeight.constant = 0
            exerciseDistanceHeight.constant = textBoxDefaultHeight
        } else {
            exerciseMinutesHeight.constant = textBoxDefaultHeight
            exerciseTimeSeparatorHeight.constant = labelDefaultHeight
            exerciseSecondsHeight.constant = textBoxDefaultHeight
            exerciseDistanceHeight.constant = 0
        }
        
        if restModeIsDistance {
            restMinutesHeight.constant = 0
            restTimeSeparatorHeight.constant = 0
            restSecondsHeight.constant = 0
            restDistanceHeight.constant = textBoxDefaultHeight
        } else {
            restMinutesHeight.constant = textBoxDefaultHeight
            restTimeSeparatorHeight.constant = labelDefaultHeight
            restSecondsHeight.constant = textBoxDefaultHeight
            restDistanceHeight.constant = 0
        }
    }
    
    @IBAction func repeatSliderChanged(_ sender: AnyObject) {
        
        numberOfRepeats = Int(repeatSlider.value)
        if repeatSlider.maximumValue == repeatSlider.value {
            numberOfRepeats = -1
        }
        
        if numberOfRepeats == -1 {
            sliderLabel.text = "Number of Sets: Unlimited"
        } else  {
            sliderLabel.text = "Number of sets: \(numberOfRepeats)"
        }
        
    }
    
    // TEXT FIELD HIDE KEYBOARD
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    // TEXT FIELD HIDE KEYBOARD
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        contentView = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        contentView!.frame = bounds
        
        // Make the view stretch with containing view
        contentView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(contentView!)
    }
    
    func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
}
