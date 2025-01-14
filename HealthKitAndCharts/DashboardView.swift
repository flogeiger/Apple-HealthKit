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
    @State private var rawSelectedDate: Date?
    
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        return hkManager.stepData.first{
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date)
        }
    }
    
    var avgStepCount: Double {
        guard !hkManager.stepData.isEmpty else { return 0 }
        let totalSteps = hkManager.stepData.reduce(0) { $0 + $1.value }
        return Double(totalSteps) / Double(hkManager.stepData.count)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statPicker
                    
                    stepsSection
                    
                    averagesSection
                }
                .padding()
            }
            .task {
                await hkManager.fetchStepCount()
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
    
    private var stepsSection: some View {
        VStack {
            NavigationLink(value: selectedStat) {
                HStack {
                    VStack(alignment: .leading) {
                        Label("Steps", systemImage: "figure.walk")
                            .font(.title3.bold())
                            .foregroundStyle(.pink)
                        
                        Text("Avg: \(Int(avgStepCount)) Steps")
                            .font(.caption)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding(.bottom, 12)
            }
            .foregroundStyle(.secondary)
            
            stepsChart
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
    
    private var stepsChart: some View {
        Chart {
            if let selectedHealthMetric {
                RuleMark(x: .value("Selected Metric", selectedHealthMetric.date, unit: .day)).foregroundStyle(Color.secondary.opacity(0.3))
                    .offset(y: -10)
                    .annotation(position: .top,
                                spacing: 0,
                                overflowResolution: .init(x:.fit(to:.chart), y: .disabled)){
                        annotationView
                    }
            }
            
            RuleMark(y: .value("Average", avgStepCount))
                .foregroundStyle(Color.secondary)
                .lineStyle(.init(lineWidth: 1, dash: [5]))
            
            ForEach(hkManager.stepData) { steps in
                BarMark(
                    x: .value("Date", steps.date, unit: .day),
                    y: .value("Steps", steps.value)
                )
                .foregroundStyle(Color.pink.gradient)
                .opacity(rawSelectedDate == nil || steps.date == selectedHealthMetric?.date ? 1 : 0.3)
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
    
    var annotationView: some View {
        VStack(alignment:.leading){
            Text(selectedHealthMetric?.date ?? .now, format: .dateTime.weekday(.abbreviated).month(.abbreviated).day())
                .font(.footnote.bold())
                .foregroundStyle(.secondary)
            
            Text(selectedHealthMetric?.value ?? 0, format: .number.precision(.fractionLength(0))).fontWeight(.heavy).foregroundStyle(.pink)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 4).fill(Color(.secondarySystemBackground)).shadow(color: .secondary.opacity(0.3), radius: 2, x: 2, y: 2)
        )
    }
}

#Preview {
    DashboardView().environment(HealthKitManager())
}
