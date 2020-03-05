//
//  HomeModel.swift
//  MySQL Demo App
//
//  Created by Jang Han on 2019/10/29.
//  Copyright © 2019 Jang Han. All rights reserved.
//

import UIKit
import MapKit

protocol HomeModelDelegate {
    
    func itemsDownloaded(locations:[Location])
    
}

class HomeModel: NSObject, CLLocationManagerDelegate {
    
    var delegate:HomeModelDelegate?
    let locationManager = CLLocationManager()

    func getItems() {
        
        let serviceUrl = "http://jhancode.com/service.php"
        
        let url = URL(string: serviceUrl)
        
        if let url = url {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url, completionHandler: {
                (data, response, error) in
                
                if error == nil {
                    self.parseJson(data!)
                }
                else {
                    print("There was an nil")
                }
            })
            
           
            task.resume()
        }
    }
    
    func dbUpdate(latitude:CLLocationDegrees?, longitude: CLLocationDegrees?) {
        
        
      let serviceUrl = "http://jhancode.com/update.php"
        
        let url = URL(string: serviceUrl)
        
        if let url = url {
            
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            if let lat = latitude, let long = longitude{
                let postString = "lat=\(lat)&long=\(long)"
                request.httpBody = postString.data(using: String.Encoding.utf8)
                
                let task = URLSession.shared.dataTask(with: request as URLRequest){
                    data, response, error in
                    
                    if error != nil {
                       // print("error=\(error)")
                        return
                    }
                   // print("response = \(response)")
                    let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                   // print("responseString = \(responseString)")
                    
                }
          
            task.resume()
            }
            
        }
        
       }
    func parseJson(_ data:Data) {
        
        var locArray = [Location]()
        
        do{
            let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as! [Any]
            
            for jsonResult in jsonArray {
                let jsonDict = jsonResult as! [String:String]

                let loc = Location(number: jsonDict["number"]!, time: jsonDict["time"]!, latitude: jsonDict["latitude"]!, longitude: jsonDict["longitude"]!)

                locArray.append(loc)
            }
            DispatchQueue.main.async {
                self.delegate?.itemsDownloaded(locations: locArray)
            }
          
            
        }catch{
            print("there was an error")
        }
    }
    
}
