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
                    
                    StepBarChart(selectedState: selectedStat, chartData: hkManager.stepData)
                    
                    averagesSection
                }
                .padding()
            }
            .task {
               // await hkManager.AddSimulatorData()
                await hkManager.fetchStepCount()
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

    
    private var averagesSection: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Label("Averages", systemImage: "calendar")
                    .font(.title3.bold())
                    .foregroundStyle(.pink)
                
                Text("Last 28 Days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.secondary)
                .frame(height: 240)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    DashboardView().environment(HealthKitManager())
}
