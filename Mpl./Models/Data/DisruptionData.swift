//
//  DisruptionData.swift
//  Mpl.
//
//  Created by Darius Martin on 21/03/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import Foundation
import Alamofire
import os.log
import SwiftyJSON

class DisruptionData {
    
    static var disruptions: [Disruption] = []
    
    static var lastupdate: Double = 0.0
    
    static func getDisruptions(completion: @escaping (_ result: Bool) -> Void) {
        //Request min every 2 minutes
        if self.lastupdate == 0 || Date.timeIntervalSinceReferenceDate-lastupdate > 120.0 {
            self.lastupdate = Date.timeIntervalSinceReferenceDate
            os_log("TaM API : Getting lastest disruptions...", type: .info)
            
            //GET request to API
            Alamofire.request("https://apimobile.tam-voyages.com/api/v1/disruption/lines").responseJSON { response in
                if response.data != nil {
                    self.disruptions.removeAll()
                    let json = JSON(response.data!)
                    
                    //Getting json data
                    for (lineCitywayId,jsonDisruptions):(String, JSON) in json {
                        let line = TransportData.getLine(byCitywayId: Int(lineCitywayId)!)
                        
                        if line == nil { continue }
                        for (_,jsonDisruption):(String, JSON) in jsonDisruptions {
                            let startDate: String = jsonDisruption["start_date"].stringValue
                            let endDate: String = jsonDisruption["end_date"].stringValue
                            let title: String = String.init(htmlEncodedString: jsonDisruption["title"].stringValue)!
                            let description: String = String.init(htmlEncodedString: jsonDisruption["description"].stringValue)!
                            
                            self.disruptions.append(Disruption.init(line: line!, startDate: startDate, endDate: endDate, title: title, description: description))
                        }
                    }
                } else {
                    completion(false)
                }
            }
        } else {
            completion(true)
        }
    }
    
    static func isLineDisrupted(line: Line, completion: @escaping (_ result: Bool) -> Void) {
        getDisruptions(completion: { (response: Bool) in
            if response == true {
                let disruptLines = self.disruptions.filter({$0.line == line})
                
                if disruptLines.count > 0 {
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        })
    }
    
    static func getLineDisruption(line: Line, completion: @escaping (_ result: Disruption?) -> Void) {
        var disruption: Disruption? = nil
        
        getDisruptions(completion: { (response: Bool) in
            if response == true {
                let disruptLines = self.disruptions.filter({$0.line == line})
                
                if (disruptLines.count > 0) {
                    disruption = disruptLines[0]
                }
            }
            completion(disruption)
        })
    }
    
    static func getStationDisruptions(station: StopZone, completion: @escaping (_ result: [(disruption: Disruption, lines: [Line])]) -> Void) {
        var stationDisruptions: [(disruption: Disruption, lines: [Line])] = []
        let stationLines = station.getLines()
        
        //Getting actual disturbances...
        getDisruptions(completion: { (response: Bool) in
            if response == true {
                //For each disturbance checking if she's linked to one station line.
                for disruption in self.disruptions {
                    if stationLines.contains(disruption.line) {
                        //Checking if they're multiple lines for one perturbation
                        var selected = stationDisruptions.filter({$0.disruption.title == disruption.title && $0.disruption.description == disruption.description})
                        
                        if selected.count > 0 {
                            //More than one line to a perturbation
                            let index = stationDisruptions.index(where: {$0.disruption.title == disruption.title && $0.disruption.description == disruption.description})
                            stationDisruptions.remove(at: index!)
                            selected[0].lines.append(disruption.line)
                            stationDisruptions.insert(selected[0], at: index!)
                        } else {
                            //New disturbance
                            stationDisruptions.append((disruption: disruption, lines: [disruption.line]))
                        }
                    }
                }
            }
            completion(stationDisruptions)
        })
    }
    
}
