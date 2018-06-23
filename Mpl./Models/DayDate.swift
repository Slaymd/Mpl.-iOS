//
//  DayDate.swift
//  Mpl.
//
//  Created by Darius Martin on 08/01/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import Foundation

class DayDate : CustomStringConvertible {
    
    var hours: Int
    var mins: Int
    var seconds: Int
    
    var description: String {
        return "\(hours) \(mins) \(seconds)"
    }
    
    var formatted: String {
        return "\(hours < 10 ? "0\(hours)" : "\(hours)"):\(mins < 10 ? "0\(mins)" : "\(mins)")"
    }
    
    init(minsFromNow waitMinutes: Int) {
        //Now
        let date = Date()
        let calendar = Calendar.current
        let hours = calendar.component(.hour, from: date)
        let mins = calendar.component(.minute, from: date)
        var secs = calendar.component(.second, from: date) + waitMinutes == 0 ? 15 : 0
        //Calculations from now
        let waitHours = Int(waitMinutes / 60)
        var passingHour = hours + waitHours
        var passingMins = mins + (waitMinutes-waitHours*60)
        
        //When mins > 60 or hours > 24 with last calculis
        if secs >= 60 {
            secs -= 60
            passingMins += 1
        }
        if passingMins >= 60 {
            passingMins -= 60
            passingHour += 1
        }
        if passingHour >= 24 {
            passingHour -= 24
        }
        self.hours = passingHour
        self.mins = passingMins
        self.seconds = secs
    }
    
    init(_ hours: Int, _ mins: Int, _ seconds: Int) {
        self.hours = hours
        self.mins = mins
        self.seconds = seconds
    }
    
    init(tamTime: String) {
        if tamTime.count < 8 {
            self.hours = 0
            self.mins = 0
            self.seconds = 0
        }
        let endMins = tamTime.index(tamTime.endIndex, offsetBy: -3)
        let startMins = tamTime.index(tamTime.endIndex, offsetBy: -5)
        let startHours = tamTime.index(tamTime.endIndex, offsetBy: -8)
        let endHours = tamTime.index(tamTime.endIndex, offsetBy: -6)
        let mins = String(tamTime[startMins..<endMins])
        let hours = String(tamTime[startHours..<endHours])
        let min = Int(mins)
        let hour = Int(hours)
        
        self.hours = hour == nil ? 0 : hour!
        self.mins = min == nil ? 0 : min!
        self.seconds = 0
    }
    
    func getMinsFromNow() -> Int {
        //Now
        let date = Date()
        let calendar = Calendar.current
        let hours = calendar.component(.hour, from: date)
        let mins = calendar.component(.minute, from: date)
        //Diff
        let diff = ((hours-self.hours)*60)+(mins-self.mins)
        
        return diff < 0 ? -diff : 1440-diff
    }
    
    func getSecondsFromNow() -> Int {
        //Now
        let date = Date()
        let calendar = Calendar.current
        let hours = calendar.component(.hour, from: date)
        let mins = calendar.component(.minute, from: date)
        let secs = calendar.component(.second, from: date)
        //Diff
        let diff = ((hours-self.hours)*60*60)+((mins-self.mins)*60)+(secs-self.seconds)
        
        return diff < 0 ? -diff : 1440*60-diff
    }
    
    static func == (lhs: DayDate, rhs: DayDate) -> Bool {
        return lhs.hours == rhs.hours && lhs.mins == rhs.mins && lhs.seconds == rhs.seconds
    }
    
}
