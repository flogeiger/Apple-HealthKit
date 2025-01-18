//
//  WeightLineChart.swift
//  HealthKitAndCharts
//
//  Created by Florian Geiger on 18.01.25.
//

import SwiftUI
import Charts

struct WeightLineChart :View {
    
    var selectedState:  HealthMetricContext
    var chartData: [HealthMetric]
    
    var body: some View {
        VStack {
            NavigationLink(value: selectedState) {
                HStack {
                    VStack(alignment: .leading) {
                        Label("Weight", systemImage: "figure")
                            .font(.title3.bold())
                            .foregroundStyle(.indigo)
                        
                        Text("Avg: 180 lbs")
                            .font(.caption)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding(.bottom, 12)
            }
            .foregroundStyle(.secondary)
            
            Chart{
                ForEach(chartData) { weights in
                    
                    AreaMark(
                        x: .value("Day",weights.date,unit: .day),y: .value("Value",weights.value)
                    ).foregroundStyle(Gradient(colors: [.blue.opacity(0.5),.clear]))
                    
                    LineMark(x: .value("Day",weights.date,unit: .day),y: .value("Value",weights.value))
                }
            }.frame(height: 150)
            
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview{
    WeightLineChart(selectedState: .weight ,chartData: MockData.weights )
}
