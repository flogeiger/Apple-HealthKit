//
//  StepBarChart.swift
//  HealthKitAndCharts
//
//  Created by Florian Geiger on 14.01.25.
//

import SwiftUI
import Charts

struct StepBarChart: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDate: Date?
    
    var chartData : [DateValueChartData]
    
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData,in: rawSelectedDate)
    }
    
    var averageSteps: Int{
        Int(chartData.map{ $0.value}.average)
    }
    
    var body: some View{
        let config = ChartContainerConfiguartion(title: "Steps", symbol: "figure.walk", subtitle: "Avg: \(averageSteps.formatted()) steps", context: .steps, isNav: true)
        
        ChartContainer(config: config) {
                Chart {
                    if let selectedData {
                        ChartAnnotationView(data: selectedData, context: .steps)
                    }
                    if !chartData.isEmpty {
                        RuleMark(y: .value("Average", averageSteps))
                            .foregroundStyle(Color.secondary)
                            .lineStyle(.init(lineWidth: 1, dash: [5]))
                    }
                    
                    ForEach(chartData) { steps in
                        BarMark(
                            x: .value("Date", steps.date, unit: .day),
                            y: .value("Steps", steps.value)
                        )
                        .foregroundStyle(Color.pink.gradient)
                        .opacity(rawSelectedDate == nil || steps.date == selectedData?.date ? 1 : 0.3)
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
                .chartXAxis{
                    AxisMarks{ value in
                        AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                    }
                }
                .chartYAxis{
                    AxisMarks{ value in
                        AxisGridLine().foregroundStyle(Color.secondary.opacity(0.3))
                        
                        AxisValueLabel((value.as(Double.self) ?? 0).formatted( .number.notation(.compactName)))
                    }
                }
                .overlay{
                    if chartData.isEmpty {
                        ChartEmptyView(systemImageName: "chart.bar", title: "No Data", description: "There is no step count data from the Health App.")
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
    StepBarChart(chartData: [])
}
