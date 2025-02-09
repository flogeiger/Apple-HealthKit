//
//  SleepMetric.swift
//  HealthKitAndCharts
//
//  Created by Florian Geiger on 28.01.25.
//

import Foundation

struct SleepMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

