//
//  HealthKitManager.swift
//  HealthKitAndCharts
//
//  Created by Florian Geiger on 12.01.25.
//

import Foundation
import HealthKit
import Observation

@Observable class HealthKitManager{
    let store = HKHealthStore()
    
    let types: Set = [
        HKQuantityType(.bodyMass),
        HKQuantityType(.stepCount)
    ]
    
    var stepData: [HealthMetric] = []
    var weightData: [HealthMetric] = []
    var weightDiffData: [HealthMetric] = []
    
    func fetchStepCount() async{
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
        }catch {
            
        }
    }
    
    func fetchWeights() async{
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
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .kilocalorie()) ?? 0)
            }
        } catch{
            
        }
    }
    
    func fetchWeightsForDifferentials() async{
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
                .init(date: $0.startDate, value: $0.mostRecentQuantity()?.doubleValue(for: .kilocalorie()) ?? 0)
            }
        } catch{
            
        }
   
    }
    
    func AddSimulatorData() async{
        var mockSamples : [HKQuantitySample] = []
        
        for i in 0..<28{
            let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 4_000...20_000))
            let weightQuantity = HKQuantity(unit: .pound(), doubleValue: .random(in: (160 + Double(i/3)...165 + Double(i/3))))
            
            let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
            let endDate = Calendar.current.date(byAdding: .second, value: 1, to: startDate)!
            
            let stepSample = HKQuantitySample(type: HKQuantityType(.stepCount), quantity: stepQuantity, start: startDate, end: endDate)
            let weightSample = HKQuantitySample(type: HKQuantityType(.bodyMass), quantity: weightQuantity, start: startDate, end: endDate)
            
            mockSamples.append(stepSample)
            mockSamples.append(weightSample)
        }
        
        try! await store.save(mockSamples)
        print("Dummy Data sent up")
    }
}
