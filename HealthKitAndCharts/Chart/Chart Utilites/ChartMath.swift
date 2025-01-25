//
//  ChartMath.swift
//  HealthKitAndCharts
//
//  Created by Florian Geiger on 14.01.25.
//

import Foundation
import Algorithms

struct ChartMath {
    /// Calculates the average value for each weekday from a given list of health metrics.
    /// - Parameter metric: An array of `HealthMetric` objects containing date and value pairs.
    /// - Returns: An array of `DateValueChartData` objects, where each object represents the average value for a specific weekday.
    ///
    /// The method groups the input metrics by weekday, calculates the average for each group, and returns the results as chart data.
    static func averageWeekdayCount(for metric: [HealthMetric]) -> [DateValueChartData]{
        let sortedByWeekday = metric.sorted(using: KeyPathComparator(\.date.weekdayInt))
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt ==  $1.date.weekdayInt}
        
        var weekdayChartData: [DateValueChartData] = []
        
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let totoal = array.reduce(0) { $0 + $1.value }
            let average = Double(totoal) / Double(array.count)
            
            weekdayChartData.append(DateValueChartData(date: firstValue.date, value: average))
        }
        
        return weekdayChartData
    }
    
    /// Calculates the average daily weight differences for each weekday.
    /// - Parameter weights: An array of ``HealthMetric`` objects containing daily weight measurements.
    /// - Returns: An array of ``DateValueChartData`` objects, where each object represents the average daily weight difference for a specific weekday.
    /// This method calculates the day-to-day difference in weight, groups the differences by weekday, and computes the average for each group.
    static func averageDailyWeightDiffs(for weights: [HealthMetric]) -> [DateValueChartData]{
        var diffValues: [(date:Date, value: Double)] = []
        
        guard weights.count > 1 else{return []}
        
        for i in 1..<weights.count{
                let date = weights[i].date
                let diff = weights[i].value - weights[i-1].value
                diffValues.append((date: date, value: diff))
        }
        
        let sortedByWeekday = diffValues.sorted(using: KeyPathComparator(\.date.weekdayInt))
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt ==  $1.date.weekdayInt}
        
        var weekdayChartData: [DateValueChartData] = []
        
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let totoal = array.reduce(0) { $0 + $1.value }
            let average = Double(totoal) / Double(array.count)
            
            weekdayChartData.append(.init(date: firstValue.date, value: average))
        }
        
        return weekdayChartData
    }
}
