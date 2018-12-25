//
//  KHPhonePreferencesUtil.swift
//  KHPhone Connect
//
//  Created by armand on 01-01-17.
//  Copyright © 2017 KHPhone. All rights reserved.
//

import Foundation

let sipPortKey          = "sipPort"
let sipAddressKey       = "sipAddress"
let userPhoneNumberKey  = "userPhoneNumber"
let congregationNameKey = "congregationName"

@objc class KHPhonePrefUtil : NSObject {
  
  // writing
  @objc class func save(sipPort:Int = 5011){
    UserDefaults.standard.set(sipPort, forKey: sipPortKey)
  }
  
  @objc class func save(sipAddress:String){
    UserDefaults.standard.set(sipAddress, forKey: sipAddressKey)
  }
  
  @objc class func save(userPhoneNumber:String){
    UserDefaults.standard.set(userPhoneNumber, forKey: userPhoneNumberKey)
  }
  
  @objc class func save(congregationName:String = "Onbekende gemeente"){
    UserDefaults.standard.set(congregationName, forKey: congregationNameKey)
  }
  
  class func update(with endpoint: Endpoint) {
    KHPhonePrefUtil.save(sipPort: endpoint.port)
    KHPhonePrefUtil.save(sipAddress: endpoint.sip)
    KHPhonePrefUtil.save(congregationName: endpoint.name)
  }
  
  // reading
  @objc class func returnSipURL() -> String?{
    let defaults = UserDefaults.standard
    let name = defaults.string(forKey: sipAddressKey)
    return name
  }
  
  @objc class func returnSipPort() -> Int{
    let defaults = UserDefaults.standard
    return defaults.integer(forKey: sipPortKey)
  }
  
  @objc class func returnUserPhoneNumber() -> String?{
    let defaults = UserDefaults.standard
    let name = defaults.string(forKey: userPhoneNumberKey)
    return name
  }
  
  @objc class func returnCongregationName() -> String?{
    let defaults = UserDefaults.standard
    let name = defaults.string(forKey: congregationNameKey)
    return name
  }
  
  @objc class func isPreferencesSet() -> Bool {
    
    if self.returnSipURL() == nil{
      return false
    }
    if self.returnUserPhoneNumber() == nil{
      return false
    }
    if self.returnCongregationName() == nil {
      return false
    }
    
    return true
  }
}
