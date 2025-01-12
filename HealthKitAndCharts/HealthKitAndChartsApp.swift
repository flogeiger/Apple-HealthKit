//
//  HealthKitAndChartsApp.swift
//  HealthKitAndCharts
//
//  Created by Florian Geiger on 09.01.25.
//

import SwiftUI

@main
struct HealthKitAndChartsApp: App {
    
    let hkManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            DashboardView().environment(hkManager)
        }
    }
}
