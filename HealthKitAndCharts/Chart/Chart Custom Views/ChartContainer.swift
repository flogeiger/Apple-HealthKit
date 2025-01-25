//
//  ChartContainer.swift
//  HealthKitAndCharts
//
//  Created by Florian Geiger on 25.01.25.
//

import SwiftUI

enum ChartType{
    case stepBar(average: Int)
    case stepWeekdayPie
    case weightLine(average: Double)
    case weightDiffBar
}

struct ChartContainer<Content: View>: View{
    
    let chartType: ChartType
    @ViewBuilder var content: () -> Content
    
    var isNav: Bool{
        switch chartType {
        case .stepBar(_),.weightLine(_):
            return true
        case .stepWeekdayPie, .weightDiffBar:
            return false
        }
    }
    
    var context: HealthMetricContext{
        switch chartType {
        case .stepBar(_),.stepWeekdayPie:
            return .steps
        case .weightLine(_), .weightDiffBar:
            return .weight
        }
    }
    
    var title: String{
       switch chartType {
       case .stepBar(_):
            return "Steps"
        case .stepWeekdayPie:
            return "Averages"
        case .weightLine(_):
            return "Weight"
        case .weightDiffBar:
            return "Average Weight Change"
        }
    }
    
    var symbol: String{
        switch chartType {
        case .stepBar(_):
             return "figure.walk"
         case .stepWeekdayPie:
             return "calendar"
         case .weightLine(_):
             return "figure"
         case .weightDiffBar:
             return "figure"
         }
    }
    
    var subTitle: String{
        switch chartType {
        case .stepBar(let average):
            "Avg: \(average.formatted()) steps"
        case .stepWeekdayPie:
            "Last 28 Days"
        case .weightLine(let average):
            "Avg: \(average.formatted(.number.precision(.fractionLength(1)))) lbs"
        case .weightDiffBar:
            "Per Weekday (Last 28 Days)"
        }
    }
    
    var body: some View{
        VStack (alignment: .leading){
            if isNav{
                navigationLinkView
            }else{
                titleView
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 12)
            }
            content()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
    
    var navigationLinkView: some View {
        NavigationLink(value: context) {
            HStack {
                titleView
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 12)
    }
    
    var titleView : some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: symbol)
                .font(.title3.bold())
                .foregroundStyle(context == .steps ? .pink : .indigo)
            
            Text(subTitle)
                .font(.caption)
        }
    }
}

#Preview {
    ChartContainer(chartType: .stepWeekdayPie) {
        Text("Chart Goes Here").frame(minHeight: 150)
    }
}
