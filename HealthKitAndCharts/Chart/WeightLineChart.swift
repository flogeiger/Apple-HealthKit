//
//  WeightLineChart.swift
//  HealthKitAndCharts
//
//  Created by Florian Geiger on 18.01.25.
//

import SwiftUI
import Charts

struct WeightLineChart :View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDate: Date?
    
    var chartData: [DateValueChartData]
    
    var minValue : Double {
        chartData.map { $0.value }.min() ?? 0
    }
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData,in: rawSelectedDate)
    }
    
    var body: some View {
        let config = ChartContainerConfiguartion(title: "Weight", symbol: "figure", subtitle: "Avg: 180 lbs", context: .weight, isNav: true)
        
        ChartContainer(config: config) {
            if chartData.isEmpty{
                ChartEmptyView(systemImageName: "chart.line.downtrend.xyaxis", title: "No Data", description: "There is no weight data from the Health App.")
            } else{
                Chart{
                    if let selectedData{
                        ChartAnnotationView(data: selectedData, context: .steps)
                    }
                    RuleMark(y: .value("Goal", 155)).foregroundStyle(.mint).lineStyle(.init(lineWidth: 1, dash: [5]))
                    
                    ForEach(chartData) { weight in
                        AreaMark(x: .value("Day", weight.date, unit: .day),
                                 yStart: .value("Value", weight.value),
                                 yEnd: .value("Min Value", minValue)
                        ).foregroundStyle(Gradient(colors: [.indigo.opacity(0.5),.clear]))
                            .interpolationMethod(.catmullRom)
                        
                        LineMark(x: .value("Day",weight.date,unit: .day),y: .value("Value",weight.value))
                            .foregroundStyle(.indigo)
                            .interpolationMethod(.catmullRom)
                            .symbol(.circle)
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $rawSelectedDate)
                .chartYScale(domain: .automatic(includesZero: false ))
                .chartXAxis{
                    AxisMarks{ value in
                        AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                    }
                }
                .chartYAxis{
                    AxisMarks{ value in
                        AxisGridLine().foregroundStyle(Color.secondary.opacity(0.3))
                        
                        AxisValueLabel()
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDate)
        .onChange(of: rawSelectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDate = newValue
            }
        }
    }
}

#Preview{
    WeightLineChart(chartData: ChartHelper.convert(data: MockData.weights) )
}
