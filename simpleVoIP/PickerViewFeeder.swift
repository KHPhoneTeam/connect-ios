//
//  PickerViewFeeder.swift
//  KHPhoneConnect
//
//  Created by armand on 25/12/2018.
//  Copyright © 2018 KHPhone. All rights reserved.
//

import UIKit

/*
 {
 "id": 0,
 "name": "Amsterdam Tuindorp-Oostzaan",
 "port": 5060,
 "sip": "sip:31207165913@sip1.budgetphone.nl"
 }
 */

struct Endpoints: Decodable {
  var endpoints: [Endpoint]
}

struct Endpoint: Codable {
  var id: Int
  var name: String
  var port: Int
  var sip: String
}

class PickerViewFeeder: NSObject {
  var endpoints: [Endpoint]?
  override init() {
    super.init()
    loadDefaultEndpoints()
  }
  
  private func endpoint(at row:Int) -> Endpoint? {
    guard let endpoints = endpoints else { return nil }
    if row > 0 && row < endpoints.count {
      return endpoints[row - 1]
    }
    return nil
  }
  
  func loadDefaultEndpoints() {
    if let endpointsInJSON = loadJSON(filename: "endpoints") {
      endpoints = endpointsInJSON
      print("Endpoints:\(endpointsInJSON)")
    }
  }
  
  func loadJSON(filename: String) -> [Endpoint]? {
    if let path = Bundle.main.path(forResource: filename, ofType: "json") {
      do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        let decoder = JSONDecoder()
        let jsonData = try decoder.decode(Endpoints.self, from: data)
        return jsonData.endpoints
      } catch {
        // could not load data!
      }
    }
    return nil
  }
  
  func didSelect(row: Int) {
    // we can save it to the prefs
    if let endpoint = endpoint(at: row) {
      KHPhonePrefUtil.update(with: endpoint)
    }
  }
}

extension PickerViewFeeder: UIPickerViewDataSource {
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if let endpoints = endpoints {
      return endpoints.count + 1
    }
    return 0
  }
}

extension PickerViewFeeder: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if row == 0 {
      return "- Kies een gemeente -"
    }
    
    if let endpoint = self.endpoints?[row - 1] {
      return endpoint.name
    }
    return ""
  }
  
  
}
