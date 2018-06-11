//
//  StationData.swift
//  Mpl.
//
//  Created by Darius Martin on 08/06/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import Foundation
import Alamofire
import os.log
import SwiftyJSON

enum StationDataType {
    case PUBLIC_TRANSPORT
    case SNCF
    case SERVICES
}

class StationData {
    
    //MARK: - VARIABLES
    
    static private let specialStations: [(stopZoneId: Int, dataTypes: [(type: StationDataType, info: Any?)])] = [
        (stopZoneId: 308, dataTypes: [(type: .PUBLIC_TRANSPORT, info: nil), (type: .SNCF, info: "stop_area:OCE:SA:87773002")]),
        (stopZoneId: 651, dataTypes: [(type: .PUBLIC_TRANSPORT, info: nil), (type: .SNCF, info: "stop_area:OCE:SA:87773002")])]
    
    static private var sncfSchedules: [(stopArea: String, requestTime: Double, schedules: [SNCFSchedule])] = []
    
    //MARK: - GET DATA TYPE
    
    static public func getDataTypes(stopZone: StopZone) -> [(type: StationDataType, info: Any?)] {
        var services: (type: StationDataType, info: Any?) = (type: .SERVICES, info: nil)
        var dataTypes: [(type: StationDataType, info: Any?)] = [(type: .PUBLIC_TRANSPORT, info: nil)]
        let filteredSpecialCases = self.specialStations.filter({$0.stopZoneId == stopZone.id})
        
        if (filteredSpecialCases.count > 0) {
            dataTypes = filteredSpecialCases[0].dataTypes
        }
        //Services
        if let serviceBundle = ServicesData.getServices(at: stopZone) {
            services.info = serviceBundle
            dataTypes.append(services)
        }
        return dataTypes
    }
    
    //MARK: - SNCF API REQUEST
    
    static public func getSNCFSchedules(stopArea: String, completion: @escaping ([SNCFSchedule]?) -> Void) {
        var schedules: [SNCFSchedule] = []
        var filtered = self.sncfSchedules.filter({$0.stopArea == stopArea})

        if filtered.count > 0 {
            if Date.timeIntervalSinceReferenceDate-filtered[0].requestTime > 120 {
                self.sncfSchedules.remove(at: self.sncfSchedules.index(where: {$0.stopArea == filtered[0].stopArea})!)
            } else {
                completion(filtered[0].schedules)
                return
            }
        }
        Alamofire.request("https://api.sncf.com/v1/coverage/sncf/stop_areas/\(stopArea)/departures?").authenticate(user: "002479d0-9fe0-4b4b-8915-ff7e761196c1", password: "").responseJSON { response in
            if response.data != nil {
                let jsonData = JSON(response.data!)
                
                //Getting departures
                for (_,jsonDeparture):(String, JSON) in jsonData["departures"] {
                    schedules.append(self.getSNCFSchedule(fromJson: jsonDeparture))
                }
                self.sncfSchedules.append((stopArea: stopArea, requestTime: Date.timeIntervalSinceReferenceDate, schedules: schedules))
                completion(schedules)
            } else {
                completion(nil)
            }
        }
    }
    
    static private func getSNCFSchedule(fromJson json: JSON) -> SNCFSchedule {
        let schedule = SNCFSchedule()
        
        schedule.departure = schedule.convertSNCFTime(sncfTime: json["stop_date_time"]["departure_date_time"].stringValue)
        schedule.baseDeparture = schedule.convertSNCFTime(sncfTime: json["stop_date_time"]["base_departure_date_time"].stringValue)
        schedule.setDestination(sncfDest: json["display_informations"]["direction"].stringValue)
        if schedule.baseDeparture.hours != schedule.departure.hours || schedule.baseDeparture.mins != schedule.departure.mins {
            schedule.status = .DELAYED
        } else {
            schedule.status = .ON_TIME
        }
        schedule.trainNumber = json["display_informations"]["headsign"].stringValue
        schedule.trainType = json["display_informations"]["commercial_mode"].stringValue
        return schedule
    }
    
}
