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
    
    static func averageDailyWeightDiffs(for weights: [HealthMetric]) -> [WeekdayChartData]{
        var diffValues: [(date:Date, value: Double)] = []
        
        guard weights.count > 1 else{return []}
        
        for i in 1..<weights.count{
                let date = weights[i].date
                let diff = weights[i].value - weights[i-1].value
                diffValues.append((date: date, value: diff))
        }
        
        let sortedByWeekday = diffValues.sorted { $0.date.weekdayInt < $1.date.weekdayInt }
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt ==  $1.date.weekdayInt}
        
        var weekdayChartData: [WeekdayChartData] = []
        
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let totoal = array.reduce(0) { $0 + $1.value }
            let average = Double(totoal) / Double(array.count)
            
            weekdayChartData.append(.init(date: firstValue.date, value: average))
        }
        
        return weekdayChartData
    }
}
