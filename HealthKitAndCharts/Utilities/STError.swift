//
//  STError.swift
//  HealthKitAndCharts
//
//  Created by Florian Geiger on 25.01.25.
//

import Foundation

enum STError: LocalizedError {
    case authNotDetermined
    case noData
    case unableToCompleteRequest
    case sharingDenied(quantityType: String)
    case invalidValue
    
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
        case .invalidValue:
            "Invalid Value"
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
        case .invalidValue:
            "Must be numeric value with a maximum of one decimal place"
        }
    }
}
