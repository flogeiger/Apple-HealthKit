//
//  ChartMath.swift
//  HealthKitAndCharts
//
//  Created by Florian Geiger on 14.01.25.
//

import Foundation
import Algorithms

struct ChartMath {
    static func averageWeekdayCount(for metric: [HealthMetric]) -> [WeekdayChartData]{
        let sortedByWeekday = metric.sorted { $0.date.weekdayInt < $1.date.weekdayInt }
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt ==  $1.date.weekdayInt}
        
        var weekdayChartData: [WeekdayChartData] = []
        
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let totoal = array.reduce(0) { $0 + $1.value }
            let average = Double(totoal) / Double(array.count)
            
            weekdayChartData.append(WeekdayChartData(date: firstValue.date, value: average))
        }
        
        return weekdayChartData
    }
}
