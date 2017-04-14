//
//  SalesForceClasses.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 11.04.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

struct Lead
{
    let name:        String!
    let id:          String!
    var isConverted: Bool! = nil
    var createdDate: Date! = nil
    let status:      String!
    var industry:    String!
    
    init(json: [String: Any]) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
        
        name        = json["Name"]        as? String ?? ""
        id          = json["Id"]          as? String ?? ""
        isConverted = json["IsConverted"] as? Bool   ?? false
        status      = json["Status"]      as? String ?? ""
        industry    = json["Industry"]    as? String ?? ""
        
        if let dateString = json["CreatedDate"] as? String,
            let date = dateFormatter.date(from: dateString)
        {
            createdDate = date
        }
    }
}

struct Revenue
{
    let amount: Float
    let date: Date
}

struct Opportunity
{    
    let name:      String!
    let id:        String!
    let amount:    Float!
    var isWon:     Bool! = nil
    var closeDate: Date! = nil
    let stage:     String!
    let ownerId:   String!
    
    init(json: [String: Any]) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        name    = json["Name"]      as? String ?? ""
        id      = json["Id"]        as? String ?? ""
        amount  = json["Amount"]    as? Float  ?? 0
        isWon   = json["IsWon"]     as? Bool
        stage   = json["StageName"] as? String ?? ""
        ownerId = json["OwnerId"]   as? String ?? ""
        
        if let dateString = json["CloseDate"] as? String,
            let date = dateFormatter.date(from: dateString)
        {
            closeDate = date
        }
    }
}

struct User
{
    let id: String!
    let name: String!
    let email: String!
    
    init(json: [String: Any]) {
        
        id    = json["Id"] as? String
        name  = json["Name"] as? String
        email = json["Email"] as? String
    }
}

struct Campaign
{
    let id:        String!
    let type:      String!
    let status:    String!
    var startDate: Date! = nil
    let ownerId:   String!
    let isActive:  Bool!
    let amountWonOpportunities: Float!
    
    init(json: [String: Any]) {
        
        let df = DateFormatter()
        
        df.dateFormat = "yyyy-MM-dd"
        
        id       = json["Id"]       as? String
        type     = json["Type"]     as? String
        status   = json["Status"]   as? String
        ownerId  = json["OwnerId"]  as? String
        isActive = json["IsActive"] as? Bool
        amountWonOpportunities = json["AmountWonOpportunities"] as? Float
        
        if let dateString = json["StartDate"] as? String, let date = df.date(from: dateString)
        {
            startDate = date
        }
    }
}

struct Case
{
    let id:          String!
    let number:      String!
    var closedDate:  Date! = nil
    var createdDate: Date! = nil
    let isClosed:    Bool!
    
    init(json: [String: Any]) {
        
        let df = DateFormatter()
        
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
        
        id       = json["Id"]         as? String
        number   = json["CaseNumber"] as? String
        isClosed = json["IsClosed"]   as? Bool
        
        if let closedDateString = json["ClosedDate"] as? String,
            let date = df.date(from: closedDateString)
        {
            closedDate = date
        }
        
        if let createdDateString = json["CreatedDate"] as? String,
            let date = df.date(from: createdDateString)
        {
            createdDate = date
        }
    }
}
