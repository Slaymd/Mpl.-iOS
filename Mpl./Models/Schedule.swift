//
//  Schedule.swift
//  Mpl.
//
//  Created by Darius Martin on 11/03/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import Foundation

class Schedule {
    
    var waitingTime: Int
    var scheduledTime: DayDate
    var destination: Stop
    var line: Line
    
    init?(waitingTime: Int, scheduledHour: Int, scheduledMinute: Int, destCitywayId: Int, lineTamId: Int, atStopZone: StopZone) {
        let stop = TransportData.getStopByIdAtStopZone(stopZone: atStopZone, stopCitywayId: destCitywayId)
        let line = TransportData.getLine(byTamId: lineTamId)
        
        if (stop == nil || line == nil) { return nil }
        self.waitingTime = waitingTime
        self.scheduledTime = DayDate(scheduledHour, scheduledMinute, 0)
        self.destination = stop!
        self.line = line!
    }
    
    
}
