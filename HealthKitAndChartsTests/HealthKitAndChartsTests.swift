//
//  HealthKitAndChartsTests.swift
//  HealthKitAndChartsTests
//
//  Created by Florian Geiger on 09.01.25.
//

import Testing
import Foundation
@testable import HealthKitAndCharts

struct HealthKitAndChartsTests {
    @Test func arrayAverage(){
        let array: [Double] = [2.0,3.1,0.45,1.2,4.2]
        #expect(array.average == 2.19)
        
    }
}

@Suite("Chart Helper Tests") struct ChartHelperTests {
    var metrics: [HealthMetric] =
    [
        .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day:14))!, value: 1000),
        .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day:15))!, value: 500),
        .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day:16))!, value: 250),
        .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day:21))!, value: 750),
    ]
    
    @Test func averageWeekdayCount(){
        let averageWeekdayCount = ChartMath.averageWeekdayCount(for: metrics)
        #expect(averageWeekdayCount.count == 3)
        #expect(averageWeekdayCount[0].value == 875)
        #expect(averageWeekdayCount[1].value == 500)
        #expect(averageWeekdayCount[2].date.weekdayTitle == "Wednesday")
    }
}
