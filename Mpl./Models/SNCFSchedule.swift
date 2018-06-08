//
//  SNCFSchedule.swift
//  Mpl.
//
//  Created by Darius Martin on 08/06/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import Foundation

enum ScheduleStatus {
    case ON_TIME
    case DELAYED
    case CANCELED
}

class SNCFSchedule {
    
    var status: ScheduleStatus
    var baseDeparture: DayDate
    var departure: DayDate
    var trainNumber: String
    var trainType: String
    var destination: String
    
    init() {
        self.status = .ON_TIME
        self.baseDeparture = DayDate(0, 0, 0)
        self.departure = DayDate(0, 0, 0)
        self.trainNumber = ""
        self.trainType = ""
        self.destination = ""
    }
    
    func convertSNCFTime(sncfTime: String) -> DayDate {
        let endMins = sncfTime.index(sncfTime.endIndex, offsetBy: -2)
        let startMins = sncfTime.index(sncfTime.endIndex, offsetBy: -4)
        let startHours = sncfTime.index(sncfTime.endIndex, offsetBy: -6)
        let mins = String(sncfTime[startMins..<endMins])
        let hours = String(sncfTime[startHours..<startMins])
        let min = Int(mins)
        let hour = Int(hours)
        
        return DayDate(min != nil ? min! : 0, hour != nil ? hour! : 0, 0)
    }
    
}
