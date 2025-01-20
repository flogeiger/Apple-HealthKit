import SwiftUI
import Charts

enum HealthMetricContext: CaseIterable, Identifiable {
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
    @State private var isShowPermissionPrimingSheet = false
    @State private var selectedStat: HealthMetricContext = .steps
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statPicker
                    
                    switch selectedStat {
                    case .steps:
                        StepBarChart(selectedState: selectedStat, chartData: hkManager.stepData)
                        
                        StepPieChart(chartData: ChartMath.averageWeekdayCount(for: hkManager.stepData))
                    case .weight:
                        WeightLineChart( selectedState: selectedStat, chartData: hkManager.weightData)
                    }
                }
                .padding()
            }
            .task {
               // await hkManager.AddSimulatorData()
                await hkManager.fetchStepCount()
                await hkManager.fetchWeights()
                ChartMath.averageWeekdayCount(for: hkManager.stepData)
                isShowPermissionPrimingSheet = !hasSeenPermissionPriming
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowPermissionPrimingSheet) {
                HealthKitPermissionPrimingView(hasSeen: $isShowPermissionPrimingSheet)
            }
        }
        .tint(selectedStat == .steps ? .pink : .indigo)
    }
    
    private var statPicker: some View {
        Picker("Selected Stat", selection: $selectedStat) {
            ForEach(HealthMetricContext.allCases) { metric in
                Text(metric.title)
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    DashboardView().environment(HealthKitManager())
}
