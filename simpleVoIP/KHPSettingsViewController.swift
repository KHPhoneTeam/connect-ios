//
//  KHPSettingsViewController.swift
//  KHPhoneConnect
//
//  Created by armand on 07-01-17.
//  Copyright © 2017 KHPhone. All rights reserved.
//

import UIKit

@objc class KHPSettingsViewController: UIViewController {
  @IBOutlet var chooseEndpointButton: UIButton!
  @IBOutlet weak var qrButton: UIButton!
  @IBOutlet weak var sipAdressTextField: UITextField!
  @IBOutlet weak var portNumberTextField: UITextField!
  @IBOutlet weak var userPhoneNumberTextField: UITextField!
  @IBOutlet var chooseEndpointTextField: UITextField!
  
  let reachability = Reachability()
  let pickerFeeder = PickerViewFeeder()
  
  @objc var focusOnUserPhoneNeeded : Bool = false
  var cameFromQR : Bool = false
  fileprivate let pickerView = ToolbarPickerView()
  var endpoints: [Endpoint]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    sipAdressTextField.text = ""
    chooseEndpointTextField.inputView = pickerView
    chooseEndpointTextField.inputAccessoryView = pickerView.toolbar
    pickerView.delegate = pickerFeeder
    pickerView.toolbarDelegate = self
    
    sipAdressTextField.delegate = self
    portNumberTextField.delegate = self
    userPhoneNumberTextField.delegate = self
    
    let toolBar = UIToolbar()
    toolBar.barStyle = .default
    toolBar.isTranslucent = true
    toolBar.tintColor = UIColor(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1)
    let doneButton = UIBarButtonItem(title: "Sluit", style: .done, target: self, action: #selector(donePressedOnKeyboard))
    let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    toolBar.setItems([spaceButton, doneButton], animated: false)
    
    toolBar.isUserInteractionEnabled = true
    toolBar.sizeToFit()
    
    userPhoneNumberTextField.inputAccessoryView = toolBar
    
    if focusOnUserPhoneNeeded { // this is used when the user has tapped on a setup link
      focusOnUserPhoneNumber()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    updateTextFields()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if cameFromQR {
      focusOnUserPhoneNumber()
      cameFromQR = false
    }
  }
  
  @IBAction func closeButtonPressed(sender: UIButton){
    self.dismiss(animated: true) {
    }
  }
  
  @IBAction func doneButtonPressed(sender: UIButton){
    view.endEditing(true)
  }
  
  @objc func donePressedOnKeyboard(){
    view.endEditing(true)
  }
  
  func focusOnUserPhoneNumber (){
    userPhoneNumberTextField?.becomeFirstResponder()
  }
  
  func updateTextFields(){
    if let congregationName = KHPhonePrefUtil.returnCongregationName() {
      chooseEndpointTextField.text = congregationName
    }
    
    let sipPort = KHPhonePrefUtil.returnSipPort()
    if (sipPort != 0) {
      portNumberTextField.text = String(sipPort);
    } else {
      portNumberTextField.text = "5011"; // default
    }
    
    if let sipAddress = KHPhonePrefUtil.returnSipURL() {
      sipAdressTextField.text = sipAddress;
    } else {
      sipAdressTextField.text = ""; // default
    }
    
    if let userPhoneNumber = KHPhonePrefUtil.returnUserPhoneNumber() {
      userPhoneNumberTextField.text = userPhoneNumber;
    } else {
      userPhoneNumberTextField.text = ""; // default
    }
  }
  
  func updatePreferences(){
    let sipPort = Int(portNumberTextField.text!)
    let sipAddress = sipAdressTextField.text!
    let userPhoneNumber = userPhoneNumberTextField.text!
    KHPhonePrefUtil.save(sipPort: sipPort!)
    KHPhonePrefUtil.save(sipAddress: sipAddress)
    KHPhonePrefUtil.save(userPhoneNumber: userPhoneNumber)
    // register account!
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if segue.identifier == "GQSegue" {
      cameFromQR = true
    }
  }
}

extension KHPSettingsViewController: UITextFieldDelegate {
  func textFieldDidEndEditing(_ textField: UITextField) {
    updatePreferences()
  }
}

extension KHPSettingsViewController: ToolbarPickerViewDelegate {
  func didTapDone() {
    let selectedRow = pickerView.selectedRow(inComponent: 0)
    print("Selected row: \(selectedRow)")
    pickerFeeder.didSelect(row: selectedRow)
    chooseEndpointTextField.resignFirstResponder()
    // updateUI
    updateTextFields()
  }
  
  func didTapCancel() {
    chooseEndpointTextField.resignFirstResponder()
  }
}
