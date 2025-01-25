//
//  Date+Ext.swift
//  HealthKitAndCharts
//
//  Created by Florian Geiger on 14.01.25.
//

import Foundation

extension Date {
    var weekdayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }
    
    var weekdayTitle: String{
        self.formatted(.dateTime.weekday(.wide))
    }
    
    var accesibilityDate: String{
        self.formatted(.dateTime.month(.wide).day())
    }
}
