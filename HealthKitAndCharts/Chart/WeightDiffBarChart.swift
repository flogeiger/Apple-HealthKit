//
//  WeightDiffBarChart.swift
//  HealthKitAndCharts
//
//  Created by Florian Geiger on 20.01.25.
//

import SwiftUI
import Charts

struct WeightDiffBarChart: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDate: Date?
    
    var chartData : [DateValueChartData]
    
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData,in: rawSelectedDate)
    }
    
    var body: some View{
        ChartContainer(title: "Average Weight Change", symbol: "figure", subtitle: "Per Weekday (Last 28 Days)", context: .weight, isNav: false) {
            if chartData.isEmpty{
                ChartEmptyView(systemImageName: "chart.bar", title: "No Data", description: "There is no weight data from the Health App.")
            } else{
            Chart {
                if let selectedData {
                    RuleMark(x: .value("Selected Metric", selectedData.date, unit: .day)).foregroundStyle(Color.secondary.opacity(0.3))
                        .offset(y: -10)
                        .annotation(position: .top,
                                    spacing: 0,
                                    overflowResolution: .init(x:.fit(to:.chart), y: .disabled)){
                            ChartAnnotationView(data: selectedData, context: .weight)
                        }
                }
                
                ForEach(chartData) { weight in
                    BarMark(
                        x: .value("Date", weight.date, unit: .day),
                        y: .value("weight", weight.value)
                    )
                    .foregroundStyle(weight.value  >= 0 ? Color.indigo.gradient : Color.mint.gradient)
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .chartXAxis{
                AxisMarks(
                    values: .stride(by: .day)){
                        AxisValueLabel(format: .dateTime.weekday(),centered: true)
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

#Preview {
    WeightDiffBarChart(chartData: MockData.weightDiff)
}
