//
//  WeekdayChartData.swift
//  HealthKitAndCharts
//
//  Created by Florian Geiger on 14.01.25.
//

import Foundation

struct WeekdayChartData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
