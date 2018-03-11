//
//  Timetable.swift
//  Mpl.
//
//  Created by Darius Martin on 08/01/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import Foundation

class Timetable {
    
    var schedules: [(date: DayDate, lineId: Int, dest: Stop)]
    var state: Int = 1
    
    init(schedules: [(date: DayDate, lineId: Int, dest: Stop)]) {
        self.schedules = schedules
        sortSchedules()
    }
    
    func addSchedule(date: DayDate, lineId: Int, dest: Stop) {
        schedules.append((date: date, lineId: lineId, dest: dest))
    }
    
    func sortSchedules() {
        self.schedules = schedules.sorted(by: {$0.date.getSecondsFromNow() < $1.date.getSecondsFromNow()})
    }
    
    static func == (lhs: Timetable, rhs: Timetable) -> Bool {
        if lhs.schedules.count != rhs.schedules.count {
            return false
        }
        if lhs.schedules.count >= 1 {
            if lhs.schedules[0].date.getMinsFromNow() != rhs.schedules[0].date.getMinsFromNow() {
                return false
            }
        }
        return true
    }
    
}
