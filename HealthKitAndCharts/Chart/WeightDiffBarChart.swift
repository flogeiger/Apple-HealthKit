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
    
    var chartData : [WeekdayChartData]
    
    
    var selectedData: WeekdayChartData? {
        guard let rawSelectedDate else { return nil }
        return chartData.first{
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
    var body: some View{
        VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Label("Average Weight Change", systemImage: "figure")
                            .font(.title3.bold())
                            .foregroundStyle(.indigo)
                        
                        Text("Per Weekday (Last 28 Days)")
                            .font(.caption)
                    }
                    Spacer()
                }
                .padding(.bottom, 12)
            .foregroundStyle(.secondary)
            
            Chart {
                if let selectedData {
                    RuleMark(x: .value("Selected Metric", selectedData.date, unit: .day)).foregroundStyle(Color.secondary.opacity(0.3))
                        .offset(y: -10)
                        .annotation(position: .top,
                                    spacing: 0,
                                    overflowResolution: .init(x:.fit(to:.chart), y: .disabled)){
                            annotationView
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
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        .sensoryFeedback(.selection, trigger: selectedDate)
        .onChange(of: rawSelectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDate = newValue
            }
        }
    }
    
    var annotationView: some View {
        VStack(alignment:.leading){
            Text(selectedData?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            
            Text(selectedData?.value ?? 0, format: .number.precision(.fractionLength(2))).fontWeight(.heavy).foregroundStyle((selectedData?.value ?? 0) >= 0 ? .indigo : .mint)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4).fill(Color(.secondarySystemBackground)).shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )
    }
}

#Preview {
    WeightDiffBarChart(chartData: MockData.weightDiff)
}
