//
//  AlertsListTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 23.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

enum Setting: String {
    case none
    case DataSource
    case TimeInterval
    case DeliveryDay
    case TimeZone
    case Condition
    case Threshold
    case DeliveryTime
    case TypeOfNotification
}

enum TimeInterval: String {
    case Daily
    case Weekly
    case Monthly
}

enum DataSource: String {
    case MyShopSupples = "My shop supples"
    case MyShopSales = "My shop sales"
    case Balance
}

enum Condition: String {
    case IsLessThan = "is less than"
    case IncreasedOrDecreased = "increased or decreased"
    case PercentHasIncreasedOrDecreasedByMoreThan = "% has increased or decreased by more than"
}

enum TypeOfNotification: String {
    case none
    case SMS
    case Push = "Push notification"
    case Email
}

class AlertsListTableViewController: UITableViewController {

    var model = ModelCoreKPI(token: "123", profile: Profile(userId: 1, userName: "user@mail.ru", firstName: "user", lastName: "user", position: "CEO", photo: nil, phone: nil, nickname: nil, typeOfAccount: .Admin))//: ModelCoreKPI!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alertOne = Alert(image: "", dataSource: .MyShopSales, timeInterval: .Daily, deliveryDay: nil, timeZone: "+3", condition: nil, threshold: nil, deliveryTime: "18:00", typeOfNotification: [.Push])
        let alertTwo = Alert(image: "", dataSource: .MyShopSupples, timeInterval: .Daily, deliveryDay: nil, timeZone: "+3", condition: nil, threshold: nil, deliveryTime: "18:00", typeOfNotification: [.SMS])
        model.alerts = [alertOne, alertTwo]
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 0/255.0, green: 151.0/255.0, blue: 167.0/255.0, alpha: 1.0)]
        
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK: -  Pull to refresh method
    func refresh(sender:AnyObject)
    {
        //load alerts from server
        print("updating alert list")
        refreshControl?.endRefreshing()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.alerts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertsCell", for: indexPath) as! AlertsListTableViewCell
        cell.alertNameLabel.text = model.alerts[indexPath.row].dataSource.rawValue
        cell.numberOfCell = indexPath.row
        if indexPath.row % 2 == 0 {
            cell.alertImageView.layer.backgroundColor = UIColor(red: 251/255, green: 233/255, blue: 231/255, alpha: 1.0).cgColor
        } else {
            cell.alertImageView.layer.backgroundColor = UIColor(red: 216/255, green: 247/255, blue: 215/255, alpha: 1.0).cgColor
        }
        cell.deleteButton.tag = indexPath.row
        cell.AlertListVC = self
        return cell
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddAlert" {
            let destinationVC = segue.destination as! AllertSettingsTableViewController
            destinationVC.model = ModelCoreKPI(model: self.model)
            destinationVC.AlertListVC = self
        }
        if segue.identifier == "ReminderView" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! ReminderViewTableViewController
                destinationController.alert = self.model.alerts[indexPath.row]
                destinationController.alertList = self.model.alerts
                destinationController.index = indexPath.row
                destinationController.AlertListVC = self
            }
        }
    }
    
}

//MARK: - updateAlertListDelegate method
extension AlertsListTableViewController: updateAlertListDelegate {
    
    func updateAlertList(alertArray: [Alert]) {
        model.alerts = alertArray
        tableView.reloadData()
    }
    
    func addAlert(alert: Alert) {
        model.alerts.append(alert)
        tableView.reloadData()
    }
}

//MARK: - AlertButtonCellDelegate method
extension AlertsListTableViewController: AlertButtonCellDelegate {
    
    func deleteButtonDidTaped(sender: UIButton) {
        var newAlertList: [Alert] = []
        for i in 0..<model.alerts.count {
            if i != sender.tag {
                newAlertList.append(model.alerts[i])
            }
        }
        self.model.alerts = newAlertList
        tableView.reloadData()
    }
}
