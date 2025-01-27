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
    @Environment(HealthKitData.self) private var hkData
    @State private var isShowingAlert = false
    @State private var fetchError: STError = .noData
    @State private var isShowPermissionPrimingSheet = false
    @State private var selectedStat: HealthMetricContext = .steps
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statPicker
                    
                    switch selectedStat {
                    case .steps:
                        StepBarChart(chartData: ChartHelper.convert(data: hkData.stepData))
                        
                        StepPieChart(chartData: ChartMath.averageWeekdayCount(for: hkData.stepData))
                    case .weight:
                        WeightLineChart(chartData: ChartHelper.convert(data: hkData.weightData))
                        
                        WeightDiffBarChart(chartData: ChartMath.averageDailyWeightDiffs(for: hkData.weightDiffData))
                    }
                }
                .padding()
            }
            .task { fetchHealthData() }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in
                HealthDataListView(metric: metric)
            }
            .fullScreenCover(isPresented: $isShowPermissionPrimingSheet,onDismiss: {
                fetchHealthData()
            }, content: {
                HealthKitPermissionPrimingView()
            })
            .alert( isPresented: $isShowingAlert,error: fetchError) {fetchError in
                
            } message: { fetchError in
                Text(fetchError.failureReason)
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
    private func fetchHealthData(){
        Task{
            do{
                async let steps = hkManager.fetchStepCount()
                async let weightsForLineChart = hkManager.fetchWeights(daysBack: 28)
                async let weightsForDifferentials = hkManager.fetchWeights(daysBack: 29)
                
                hkData.stepData = try await steps
                hkData.weightData = try await weightsForLineChart
                hkData.weightDiffData = try await weightsForDifferentials
            } catch STError.authNotDetermined{
                isShowPermissionPrimingSheet = true
            } catch STError.noData{
                fetchError = .noData
                isShowingAlert = true
            } catch {
                fetchError = .unableToCompleteRequest
                isShowingAlert = true
            }
        }
    }
}

#Preview {
    DashboardView().environment(HealthKitManager())
}
