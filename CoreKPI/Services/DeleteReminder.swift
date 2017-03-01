//
//  DeleteReport.swift
//  CoreKPI
//
//  Created by Семен on 16.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation

class DeleteReminder: Request {
    
    func deleteReminder(reminderID: Int, success: @escaping () -> (), failure: @escaping failure) {
        
        let data: [String : Any] = ["reminder_id" : reminderID]
        
        self.getJson(category: "/reminders/removeReminder", data: data,
                     success: { json in
                        if self.parsingJson(json: json) {
                            success()
                        } else {
                            failure(self.errorMessage ?? "Wrong data from server")
                        }
        },
                     failure: { (error) in
                        failure(error)
        }
        )
    }
    
    func parsingJson(json: NSDictionary) -> Bool {
        
        if let successKey = json["success"] as? Int {
            if successKey == 1 {
                return true
            } else {
                self.errorMessage = json["message"] as? String
            }
        } else {
            print("Json file is broken!")
        }
        return false
    }
    
}