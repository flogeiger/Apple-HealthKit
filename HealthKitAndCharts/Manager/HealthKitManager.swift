//
//  HealthKitManager.swift
//  HealthKitAndCharts
//
//  Created by Florian Geiger on 12.01.25.
//

import Foundation
import HealthKit
import Observation

enum STError: LocalizedError {
    case authNotDetermined
    case noData
    case unableToCompleteRequest
    case sharingDenied(quantityType: String)
    
    var errorDescription: String?{
        switch self {
        case .authNotDetermined:
            "Need Acces to Health Data!"
        case .sharingDenied(let quantityType):
            "No Write Access"
        case .noData:
            "No Data"
        case .unableToCompleteRequest:
            "Unable to complete Request"
        }
    }
    
    var failureReason: String {
        switch self {
        case .authNotDetermined:
            "You have not granted access to Health Data! Please go to Settings > Health > HealthKitAndCharts."
        case .sharingDenied(quantityType: let quantityType):
            "You have denied access to upload your \(quantityType) data. \n\nYou can change this in Settings > Health > HealthKitAndCharts."
        case .noData:
            "There is no data for this Health statistic"
        case .unableToCompleteRequest:
            "We are unable to complete your request at this time. \n\nPlease try again later."
        }
    }
}

@Observable class HealthKitManager{
    let store = HKHealthStore()
    
    let types: Set = [
        HKQuantityType(.bodyMass),
        HKQuantityType(.stepCount)
    ]
    
    var stepData: [HealthMetric] = []
    var weightData: [HealthMetric] = []
    var weightDiffData: [HealthMetric] = []
    
    func fetchStepCount() async throws{
        
        guard store.authorizationStatus(for: HKQuantityType(.stepCount)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        
        let calender = Calendar.current
        let today = calender.startOfDay(for: .now)
        let endDate = calender.date(byAdding: .day, value: 1, to: today)!
        let startDate = calender.date(byAdding: .day, value: -28, to: endDate)!
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: queryPredicate)
        let stepsQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate, options: .cumulativeSum, anchorDate: endDate, intervalComponents: .init(day:1))
        do{
            let stepCounts = try! await stepsQuery.result(for: store)
            stepData = stepCounts.statistics().map{
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
        }catch HKError.errorNoData{
            throw STError.noData
        } catch{
            throw STError.unableToCompleteRequest
        }
    }
    
    func fetchWeights() async throws{
        guard store.authorizationStatus(for: HKQuantityType(.bodyMass)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let calender = Calendar.current
        let today = calender.startOfDay(for: .now)
        let endDate = calender.date(byAdding: .day, value: 1, to: today)!
        let startDate = calender.date(byAdding: .day, value: -28, to: endDate)!
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate: queryPredicate)
        let weightQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate, options: .mostRecent, anchorDate: endDate, intervalComponents: .init(day:1))
        do{
            let weights = try! await weightQuery.result(for: store)
            weightData = weights.statistics().map{
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
            }
        } catch HKError.errorNoData{
            throw STError.noData
        } catch{
            throw STError.unableToCompleteRequest
        }
    }
    
    func fetchWeightsForDifferentials() async throws{
        guard store.authorizationStatus(for: HKQuantityType(.bodyMass)) != .notDetermined else {
            throw STError.authNotDetermined
        }

        let calender = Calendar.current
        let today = calender.startOfDay(for: .now)
        let endDate = calender.date(byAdding: .day, value: 1, to: today)!
        let startDate = calender.date(byAdding: .day, value: -29, to: endDate)!
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate: queryPredicate)
        let weightQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate, options: .mostRecent, anchorDate: endDate, intervalComponents: .init(day:1))
        do{
            let weights = try! await weightQuery.result(for: store)
            weightDiffData = weights.statistics().map{
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
            }
        } catch HKError.errorNoData{
            throw STError.noData
        } catch{
            throw STError.unableToCompleteRequest
        }
   
    }
    
    func addStepData(for date: Date, value: Double) async throws{
        
        let status = store.authorizationStatus(for: HKQuantityType(.stepCount))
        
        switch status {
            case .notDetermined:
                throw STError.authNotDetermined
            case .sharingDenied:
                throw STError.sharingDenied(quantityType: "Step count")
            case .sharingAuthorized:
                break
            @unknown default:
                break
        }
        
        let stepQuantity = HKQuantity(unit: .count(), doubleValue: value)
        let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: date,end: date)
        do {
            try await store.save(stepSample)
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    func addWeightData(for date: Date, value: Double) async throws{
        
        let status = store.authorizationStatus(for: HKQuantityType(.bodyMass))
        
        switch status {
            case .notDetermined:
                throw STError.authNotDetermined
            case .sharingDenied:
                throw STError.sharingDenied(quantityType: "weight count")
            case .sharingAuthorized:
                break
            @unknown default:
                break
        }
        
        let weightQuantity = HKQuantity(unit: .pound(), doubleValue: value)
        let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuantity, start: date,end: date)
        
        do {
            try await store.save(weightSample)
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
}
