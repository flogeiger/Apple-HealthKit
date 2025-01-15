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
}
