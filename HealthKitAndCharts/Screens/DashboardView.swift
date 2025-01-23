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
                        
                        WeightDiffBarChart(chartData: ChartMath.averageDailyWeightDiffs(for: hkManager.weightDiffData))
                    }
                }
                .padding()
            }
            .task {
                do{
                    try await hkManager.fetchStepCount()
                    try await hkManager.fetchWeights()
                    try await hkManager.fetchWeightsForDifferentials()
                } catch STError.authNotDetermined{
                    isShowPermissionPrimingSheet = true
                } catch STError.noData{
                    print("No data available")
                } catch STError.sharingDenied(let quantityType){
                    print("TesttesttestError")
                } catch {
                    print("Unable to fetch!")
                }
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowPermissionPrimingSheet,onDismiss: {
                
            }, content: {
                HealthKitPermissionPrimingView()
            })
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
