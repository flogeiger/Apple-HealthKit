//
//  HealthKitManager.swift
//  HealthKitAndCharts
//
//  Created by Florian Geiger on 12.01.25.
//

import Foundation
import HealthKit
import Observation

@Observable
@MainActor
final class HealthKitData: Sendable{
    var stepData: [HealthMetric] = []
    var weightData: [HealthMetric] = []
    var weightDiffData: [HealthMetric] = []
}

@Observable
final class HealthKitManager: Sendable{
    let store = HKHealthStore()
    
    let types: Set = [
        HKQuantityType(.bodyMass),
        HKQuantityType(.stepCount),
        HKCategoryType(.sleepAnalysis)
    ]
    
    ///Fetch last 28 days of step count from HealthKit
    /// - Returns: Array of ``HealthMetric``
    func fetchStepCount() async throws -> [HealthMetric]{
        
        guard store.authorizationStatus(for: HKQuantityType(.stepCount)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, daysBack: 28)
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.stepCount), predicate: queryPredicate)
        let stepsQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate, options: .cumulativeSum, anchorDate: interval.end, intervalComponents: .init(day:1))
        do{
            let stepCounts = try! await stepsQuery.result(for: store)
            return stepCounts.statistics().map{
                .init(date: $0.startDate, value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            }
        }catch HKError.errorNoData{
            throw STError.noData
        } catch{
            throw STError.unableToCompleteRequest
        }
    }
    
    ///Fetch most recent weight sample on each day for a specified number of days back from today
    ///- Parameter daysBack: Days back from today. Ex - 28 will return the last 28 days
    ///- Returns: Array of ``HealthMetric``
    func fetchWeights(daysBack: Int) async throws -> [HealthMetric]{
        guard store.authorizationStatus(for: HKQuantityType(.bodyMass)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, daysBack: daysBack)
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.quantitySample(type: HKQuantityType(.bodyMass), predicate: queryPredicate)
        let weightQuery = HKStatisticsCollectionQueryDescriptor(predicate: samplePredicate, options: .mostRecent, anchorDate: interval.end, intervalComponents: .init(day:1))
        do{
            let weights = try! await weightQuery.result(for: store)
            return weights.statistics().map{
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
            }
        } catch HKError.errorNoData{
            throw STError.noData
        } catch{
            throw STError.unableToCompleteRequest
        }
    }
    
    func fetchDeepSleepData(daysBack: Int) async throws -> [HKCategorySample] {
        
        guard store.authorizationStatus(for: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let interval = createDateInterval(from: .now, daysBack: daysBack)
        let queryPredicate = HKQuery.predicateForSamples(withStart: interval.start, end: interval.end)
        let samplePredicate = HKSamplePredicate.categorySample(type: HKCategoryType(.sleepAnalysis), predicate: queryPredicate)
        let sleepQuery = HKSampleQuery(sampleType: <#T##HKSampleType#>,
                                       predicate: queryPredicate,
                                       limit: <#T##Int#>,
                                       sortDescriptors: <#T##[NSSortDescriptor]?#>,
                                       resultsHandler: <#T##(HKSampleQuery, [HKSample]?, (any Error)?) -> Void#>)
        }
    
    ///Write step count data to HealthKit. Requires HealthKit write permission.
    ///- Parameters:
    ///  - date: Date for step count value
    ///  - value: Step count value
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
    
    ///Write weight data to HealthKit. Requires HealthKit write permission.
    ///- Parameters:
    ///  - date: Date for weight value
    ///  - value: Weight value in pounds. Uses pounds as a Double for .bodyMass conversions
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
    
    ///Creates a DateInterval between two dates
    ///- Parameters:
    ///  - date: End of date interval. Ex - today
    ///  - daysBack: Start of date interval. Ex - 28 dys ago
    ///- Returns: Date range between two dates as a DateInterval
    private func createDateInterval(from date: Date, daysBack: Int)-> DateInterval
    {
        let calender = Calendar.current
        let startOfEndDate = calender.startOfDay(for: date)
        let endDate = calender.date(byAdding: .day, value: 1, to: startOfEndDate)!
        let startDate = calender.date(byAdding: .day, value: -daysBack, to: endDate)!
        return .init(start: startDate, end: endDate)
    }
}
