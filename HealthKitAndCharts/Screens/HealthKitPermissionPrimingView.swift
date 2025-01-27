//
//  HealthKitPermissionPrimingView.swift
//  HealthKitAndCharts
//
//  Created by Florian Geiger on 12.01.25.
//

import SwiftUI
import HealthKitUI

struct HealthKitPermissionPrimingView : View{
    
    @Environment(HealthKitManager.self) private var hkManager
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingHealthKitPermissions = false
    
    var description = """
    This app displays your step and weight data in interactive charts.

    You can also add new step or weight data to Apple health from this app. Your data is private and secured.
    """
    
    var body: some View {
        VStack(spacing: 130){
            VStack(alignment:.leading, spacing: 10){
                Image(.appleHealth)
                    .resizable()
                    .frame(width: 90,height: 90)
                    .shadow(color: .gray.opacity(0.3),radius: 16)
                    .padding(.bottom,12)
                
                Text("Apple HealthKit Permission")
                    .font(.title2).bold()
                
                Text(description)
                    .foregroundStyle(.secondary)
            }
            
            Button("Connect Apple Health"){
                isShowingHealthKitPermissions = true
            }.buttonStyle(.borderedProminent)
                .tint(.pink)
        }
        .padding(30)
        .healthDataAccessRequest(store: hkManager.store, shareTypes: hkManager.types,readTypes: hkManager.types, trigger: isShowingHealthKitPermissions) { results in
            switch results {
            case .success:
                Task{@MainActor in dismiss()}
            case .failure:
                Task{@MainActor in dismiss()}
            }
        }
    }
}

#Preview {
    HealthKitPermissionPrimingView()
}
