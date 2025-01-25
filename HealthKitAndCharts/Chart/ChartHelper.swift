//
//  ChartHelper.swift
//  HealthKitAndCharts
//
//  Created by Florian Geiger on 25.01.25.
//
import Foundation

struct ChartHelper{
    static func convert(data: [HealthMetric]) -> [DateValueChartData]{
        data.map {
            DateValueChartData(date: $0.date, value: $0.value)
        }
    }
    
    static func parseSelectedData(from data: [DateValueChartData], in selectedDate: Date?) -> DateValueChartData? {
        guard let selectedDate else { return nil }
        return data.first{
            Calendar.current.isDate(selectedDate, inSameDayAs: $0.date)
        }
    }
}
