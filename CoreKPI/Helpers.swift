//
//  Helpers.swift
//  CoreKPI
//
//  Created by Мануэль on 27.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit

func removeAllAlamofireNetworking() {
    
    Request.sessionManager.session.getAllTasks { tasks in
        tasks.forEach { $0.cancel() }
    }
}

extension Notification.Name
{    
    static let userTappedSecuritySwitch      = Notification.Name("UserTappedSecuritySwitch")
    static let qbManagerRecievedData         = Notification.Name("qbManagerRecievedData")
    static let paypalManagerRecievedData     = Notification.Name("paypalManagerRecievedData")
    static let newExternalKPIadded           = Notification.Name("NewExternalKPIAdded")
    static let modelDidChanged               = Notification.Name("modelDidChange")
    static let userLoggedIn                  = Notification.Name("UserLoggedIn")
    static let userLoggedOut                 = Notification.Name("UserLoggedOut")
    static let userAddedPincode              = Notification.Name("UserAddedPincode")
    static let userRemovedPincode            = Notification.Name("UserRemovedPincode")
    static let userFailedToLogin             = Notification.Name("LoginAttemptFailed")
    static let appDidEnteredBackground       = Notification.Name("AppDidEnteredBackground")
    static let errorDownloadingFile          = Notification.Name("errorDownloadingFile")
    static let googleManagerRecievedData     = Notification.Name("googleManagerRecievedData")
    static let hubspotManagerRecievedData    = Notification.Name("hubspotManagerRecievedData")
    static let salesForceManagerRecievedData = Notification.Name("salesForceManagerRecievedData") 
    static let hubspotCodeRecieved           = Notification.Name("HubspotCodeRecieved")
    static let hubspotTokenRecieved          = Notification.Name("HubspotTokenRecieved")
    static let reportDataForKpiRecieved      = Notification.Name("ReportDataForKpiRecieved")
    static let addedNewExtKpiOnServer        = Notification.Name("addedNewExternalKpiOnServer")
    static let internetConnectionLost        = Notification.Name("internetConnectionLost")
    static let integratedServicesListLoaded  = Notification.Name("integratedServicesListLoaded")
}

struct AnimationConstants
{
    struct Keys
    {
        static let trainingAnimation = "TrainingAnimation"
    }
    
    struct KeyPath
    {
        static let layer = "LayerToRemove"
    }
}

struct UserDefaultsKeys
{
    static let userId = "userId"
    static let pinCode = "PinCode"
    static let token = "token"
    static let pinCodeAttempts = "PinCodeAttempts"
}

struct OurColors
{
    static let violet = UIColor(red: 124.0/255.0, green: 77.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let cyan = UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0)
    static let gray = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
    static let blue = UIColor(red: 0/255, green: 185/255, blue: 230/255, alpha: 1.0)
    static let lightBlue = UIColor(red: 178/255, green: 234/255, blue: 242/255, alpha: 1.0)
}

public func validate(email: String? = nil, password: String? = nil) -> Bool {
    
    if let email = email
    {
        if email == "" { return false }
        else if email.range(of: "@") == nil ||
            (email.components(separatedBy: "@")[0].isEmpty) ||
            (email.components(separatedBy: "@")[1].isEmpty) { return false }
    }
    
    if let password = password
    {
        if password == "" { return false }
    }
    
    return true
}

public func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
    var i = 0
    return AnyIterator {
        let next = withUnsafePointer(to: &i) {
            $0.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
        }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}

public enum Timezones: String
{
    case hawaii   = "Hawaii Time (HST)" //-10
    case alaska   = "Alaska Time (AKST)" //-8
    case pacific  = "Pacific Time (PST)" //-7
    case mountain = "Mountain Time (MST)" //-6
    case central  = "Central Time (CST)" //-5
    case eastern  = "Eastern Time (EST)" //-4
    case error    = "Error"
}

public func timezoneTitleFrom(hoursFromGMT: String) -> Timezones
{
    switch hoursFromGMT
    {
    case "-10": return .hawaii
    case "-8":  return .alaska
    case "-7":  return .pacific
    case "-6":  return .mountain
    case "-5":  return .central
    case "-4":  return .eastern
    default:    return .error
    }
}

public func getKpiNameFrom(id: Int) -> String {
    
    let services = ModelCoreKPI.modelShared.integratedServices
    var title: String?
    
    services.forEach { service in
        service.kpis.forEach { kpi in
            if kpi.id == id { title = kpi.title }
        }
    }
    
    guard let titleToReturn = title else {
        fatalError("Cannot find title for kpiId")
    }
    
    return titleToReturn
}
