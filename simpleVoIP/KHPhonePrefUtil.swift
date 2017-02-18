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
    class func save(sipPort:Int = 5011){
        let defaults = UserDefaults.standard
        defaults.set(sipPort, forKey: sipPortKey)
    }
    class func save(sipAddress:String){
        let defaults = UserDefaults.standard
        defaults.set(sipAddress, forKey: sipAddressKey)
    }
    class func save(userPhoneNumber:String){
        let defaults = UserDefaults.standard
        defaults.set(userPhoneNumber, forKey: userPhoneNumberKey)
    }
    class func save(congregationName:String = "Onbekende gemeente"){
        let defaults = UserDefaults.standard
        defaults.set(congregationName, forKey: congregationNameKey)
    }
    
    // reading
    class func returnSipURL() -> String?{
        let defaults = UserDefaults.standard
        let name = defaults.string(forKey: sipAddressKey)
        return name
    }
    class func returnSipPort() -> Int{
        let defaults = UserDefaults.standard
        return defaults.integer(forKey: sipPortKey)
    }
    class func returnUserPhoneNumber() -> String?{
        let defaults = UserDefaults.standard
        let name = defaults.string(forKey: userPhoneNumberKey)
        return name
    }
    class func returnCongregationName() -> String?{
        let defaults = UserDefaults.standard
        let name = defaults.string(forKey: congregationNameKey)
        return name
    }
    
    class func isPreferencesSet() -> Bool {
        
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
