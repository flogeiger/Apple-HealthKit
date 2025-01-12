//
//  ContentView.swift
//  HealthKitAndCharts
//
//  Created by Florian Geiger on 09.01.25.
//

import SwiftUI

enum HealthMetricContext: CaseIterable,Identifiable {
    case steps, weight
    var id: Self { self }
    
    var title: String {
        switch self {
        case .steps: return "Steps"
        case .weight: return "Weight"
        }
    }
}

struct DashboardView: View {
    @Environment(HealthKitManager.self) private var hkManager
    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming = false
    @State private var isshowPermissionPrimingSheet = false
    @State private var selectedStat:HealthMetricContext = .steps
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack (spacing: 20){
                    Picker("Selected Stat", selection: $selectedStat){
                        ForEach(HealthMetricContext.allCases){
                            metric in
                            Text(metric.title)
                        }
                    }.pickerStyle(.segmented)
                    
                    VStack{
                        NavigationLink(value: selectedStat) {
                            HStack{
                                VStack(alignment: .leading){
                                    Label("Steps",systemImage: "figure.walk")
                                        .font(.title3.bold())
                                        .foregroundStyle(.pink)
                                    
                                    Text("Avg: 10K Steps")
                                        .font(.caption)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding(.bottom,12)
                        }.foregroundStyle(.secondary)
                        
                        RoundedRectangle(cornerRadius: 12).foregroundStyle(.secondary)
                            .frame(height: 150)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                }
                
                VStack(alignment:.leading){
                    VStack(alignment: .leading){
                        Label("Averages",systemImage: "calendar")
                            .font(.title3.bold())
                            .foregroundStyle(.pink)
                        
                        Text("Last 28 Days")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    RoundedRectangle(cornerRadius: 12).foregroundStyle(.secondary)
                        .frame(height: 240)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
            }
            .padding()
            .task {
                //await hkManager.AddSimulatorData()
                isshowPermissionPrimingSheet = !hasSeenPermissionPriming
            }
            .navigationTitle(Text("Dashboard"))
            .navigationDestination(for: HealthMetricContext.self) {
                metric in
                HealthDataListView(metric: metric)
            }.sheet(isPresented: $isshowPermissionPrimingSheet,onDismiss:{
                //fetch health data
            }, content: {
                HealthKitPermissionPrimingView(hasSeen: $isshowPermissionPrimingSheet)
            })
        }.tint(selectedStat == .steps ? .pink : .indigo)
    }
}

#Preview {
    DashboardView().environment(HealthKitManager())
}
