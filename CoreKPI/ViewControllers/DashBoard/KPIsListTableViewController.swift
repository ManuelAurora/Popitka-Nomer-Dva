//
//  KPIsListTableViewController.swift
//  CoreKPI
//
//  Created by Семен on 23.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit

//MARK: - Enums for setting
enum Source: String {
    case none = ""
    case User
    case Integrated
}

class KPIsListTableViewController: UITableViewController {
    
    var model: ModelCoreKPI!
    var arrayOfKPI: [KPI] = []
    
    let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if model.profile?.typeOfAccount != TypeOfAccount.Admin {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        let nc = NotificationCenter.default
        nc.addObserver(forName: .modelDidChanged, object:nil, queue:nil, using:catchNotification)
        nc.addObserver(forName: .newExternalKPIadded, object: nil, queue: nil, using: catchNotification)
        
        //test ->
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(_:)))
        longPressGesture.minimumPressDuration = 1 // 1 second press
        self.tableView.addGestureRecognizer(longPressGesture)
        //<- test
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        refreshControl?.backgroundColor = UIColor.clear
        tableView.addSubview(refreshControl!)
        
        self.navigationController?.hideTransparentNavigationBar()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : OurColors.cyan]
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = OurColors.gray
    }
    
    //Called, when long press occurred
    func longPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let cell = tableView.cellForRow(at: indexPath) as! KPIListTableViewCell
                cell.deleteButton.isHidden = false
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let firstLoad = UserDefaults.standard.data(forKey: "firstLoad"),
            let _ = NSKeyedUnarchiver.unarchiveObject(with: firstLoad) as? Bool {
        } else {
            let onboardingVC = storyboard?.instantiateViewController(withIdentifier: .onboardPageVC) as! OnboardingPageViewController
            present(onboardingVC, animated: true, completion: nil)
            saveData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.hideTransparentNavigationBar()
    }
    
    //MARK: - Save mark about first loading
    func saveData() {
        let data: Bool = true
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: data)
        UserDefaults.standard.set(encodedData, forKey: "firstLoad")
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfKPI.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KPIListCell", for: indexPath) as! KPIListTableViewCell
        cell.KPIListVC  = self
        cell.editButton.tag = indexPath.row
        cell.reportButton.tag = indexPath.row
        cell.memberNameButton.tag = indexPath.row
        cell.deleteButton.tag = indexPath.row
        
        if let imageString = arrayOfKPI[indexPath.row].image {
            cell.KPIListCellImageView.isHidden = false
            cell.KPIListCellImageView.image = UIImage(named: imageString.rawValue)
        } else {
            cell.KPIListCellImageView.isHidden = true
        }
        
        cell.KPIListCellImageBacgroundView.backgroundColor = arrayOfKPI[indexPath.row].imageBacgroundColour
        
        hideButtonsOnKPICard(cell: cell, kpi: arrayOfKPI[indexPath.row])
        
        switch arrayOfKPI[indexPath.row].typeOfKPI {
        case .IntegratedKPI:
            
            cell.KPIListNumber.isHidden = false
            cell.reportButton.isHidden = true
            cell.ManagedByStack.isHidden = true
            let integratedKPI = arrayOfKPI[indexPath.row].integratedKPI
            cell.KPIListHeaderLabel.text = integratedKPI?.kpiName
            
        case .createdKPI:
            let createdKPI = arrayOfKPI[indexPath.row].createdKPI
            cell.KPIListHeaderLabel.text = createdKPI?.KPI
            
            if (createdKPI?.number.count)! > 0 {
                if let number = createdKPI?.number[(createdKPI?.number.count)! - 1] {
                    let formatter: NumberFormatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    formatter.maximumFractionDigits = 10
                    let formatedStr: String = formatter.string(from: NSNumber(value: number.number))!
                    cell.KPIListNumber.text = formatedStr
                }
            } else {
                cell.KPIListNumber.text = ""
            }
            
            if createdKPI?.executant == model.profile?.userId {
                cell.memberNameButton.setTitle( "Me" , for: .normal )
            } else {
                for profile in model.team {
                    if Int(profile.userID) == createdKPI?.executant {
                        let title = (profile.firstName)! + " " + (profile.lastName)!
                        cell.memberNameButton.setTitle(title, for: .normal)
                        return cell
                    }
                }
                cell.memberNameButton.setTitle("error member", for: .normal)
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let destinationVC = storyboard?.instantiateViewController(withIdentifier: .chartsViewController) as! ChartsPageViewController
        
        destinationVC.kpi = arrayOfKPI[indexPath.row]
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        let selectCell = tableView.cellForRow(at: indexPath) as! KPIListTableViewCell
        if !selectCell.deleteButton.isHidden {
            return indexPath
        }
        
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction =  UITableViewRowAction(style: .default, title: "Delete", handler: {
            (action, indexPath) -> Void in
            
            if self.arrayOfKPI[indexPath.row].typeOfKPI == .IntegratedKPI {
                self.context.delete(self.arrayOfKPI[indexPath.row].integratedKPI)
                (UIApplication.shared .delegate as! AppDelegate).saveContext()
            } else {
                self.deleteKPI(kpiID: self.model.kpis[indexPath.row].id)
                self.model.kpis.remove(at: indexPath.row)
            }
            
            self.arrayOfKPI.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        )
        if model.profile?.typeOfAccount == TypeOfAccount.Admin {
            return [deleteAction]
        } else {
            return []
        }
    }
    
    //MARK: show/hide buttons on KPI cards
    private func hideButtonsOnKPICard(cell: KPIListTableViewCell, kpi: KPI) {
        
        switch kpi.typeOfKPI {
        case .createdKPI:
            cell.reportButton.isHidden = false
            cell.editButton.isHidden = false
            
            if model.profile?.typeOfAccount == TypeOfAccount.Admin && model.profile?.userId != kpi.createdKPI?.executant {
                cell.reportButton.isHidden = true
                cell.editButton.isHidden = false
            }
            
            cell.KPIListNumber.isHidden = false
            cell.ManagedByStack.isHidden = false
        case .IntegratedKPI:
            cell.reportButton.isHidden = true
            cell.editButton.isHidden = true
            cell.KPIListNumber.isHidden = true
            cell.ManagedByStack.isHidden = true
        }
    }
    
    //MARK: - Delete KPI
    func deleteKPI(kpiID: Int) {
        let request = DeleteKPI(model: model)
        request.deleteKPI(kpiID: kpiID, success: {
            print("KPI with id \(kpiID) was deleted")
        }, failure: { error in
            print(error)
            self.showAlert(title: "Sorry", errorMessage: error)
            self.loadKPIsFromServer()
        })
    }
    
    //MARK: -  Pull to refresh method
    func refresh(sender:AnyObject)
    {
        loadKPIsFromServer()
    }
    
    //MARK: - Load KPIs from server methods
    //MARK: Load all KPIs
    func loadKPIsFromServer(){
        let request = GetKPIs(model: model)
        request.getKPIsFromServer(success: { kpi in
            self.model.kpis = kpi
            self.arrayOfKPI = kpi
            self.loadExternal()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            self.loadReports()
        }, failure: { error in
            print(error)
            self.refreshControl?.endRefreshing()
            self.showAlert(title: "Sorry!", errorMessage: error)
            self.tableView.reloadData()
        })
    }
    
    func loadExternal() {
        let context = (UIApplication.shared .delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let external = try context.fetch(ExternalKPI.fetchRequest())
            for kpi in external {
                let kpi = KPI(kpiID: 0, typeOfKPI: .IntegratedKPI, integratedKPI: (kpi as! ExternalKPI), createdKPI: nil, imageBacgroundColour: UIColor(hex: "D8F7D7".hex!))
                arrayOfKPI.append(kpi)
            }
        } catch {
            print("Fetching failed")
        }
    }
    
    //MARK: Load reports
    func loadReports() {
        let getReportRequest = GetReports(model: model)
        for kpi in arrayOfKPI {
            getReportRequest.getReportForKPI(withID: kpi.id, success: { reports in
                kpi.createdKPI?.number = getReportRequest.filterReports(kpi: kpi, reports: reports)
                self.tableView.reloadData()
                let nc = NotificationCenter.default
                nc.post(name: .modelDidChanged,
                        object: nil,
                        userInfo: nil)
            }, failure: { error in })
        }
    }
    
    //MARK: Load User's KPI
    func loadUsersKPI(userID: Int) {
        
        let request = GetKPIs(model: model)
        request.getUserKPI(userID: userID, success: { kpi in
            self.arrayOfKPI = kpi
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            if self.arrayOfKPI.isEmpty {
                self.showAlert(title: "Sorry", errorMessage: "No KPI!")
            }
        }, failure: { error in
            print(error)
            self.refreshControl?.endRefreshing()
            self.showAlert(title: "Sorry!", errorMessage: error)
            self.tableView.reloadData()
        })
    }
    
    //MARK: - CatchNotification
    func catchNotification(notification:Notification) -> Void {
        
        if notification.name == .modelDidChanged { tableView.reloadData() }
        else if notification.name == .newExternalKPIadded
        {
            refresh(sender: self)
            tableView.reloadData()
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddKPI" {
            let destinationVC = segue.destination as! ChooseSuggestedKPITableViewController
            destinationVC.model = model
            destinationVC.KPIListVC = self
        }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if(!(parent?.isEqual(self.parent) ?? false)) {
            self.navigationController?.presentTransparentNavigationBar()
        }
    }
    
}

//MARK: - updateKPIListDelegate method
extension KPIsListTableViewController: updateKPIListDelegate {
    
    func addNewKPI(kpi: KPI) {
        
        self.model.kpis.append(kpi)
        self.arrayOfKPI.append(kpi)
        self.tableView.reloadData()
    }
    
    func updateKPIList(kpiArray: [KPI]) {
        
        self.model.kpis = kpiArray
        self.arrayOfKPI = kpiArray
        self.tableView.reloadData()
    }
}

//MARK: - KPIListButtonCellDelegate methods
extension KPIsListTableViewController: KPIListButtonCellDelegate {
    
    func userTapped(button: UIButton, edit: Bool) {
        
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: .reportViewController) as! ReportAndViewKPITableViewController
        destinatioVC.model = model
        destinatioVC.kpiIndex = button.tag
        destinatioVC.buttonDidTaped = edit ? ButtonDidTaped.Edit : ButtonDidTaped.Report
        destinatioVC.KPIListVC = self
        navigationController?.pushViewController(destinatioVC, animated: true)        
    }
    
    func memberNameDidTaped(sender: UIButton) {
        
        let stack = self.navigationController?.viewControllers
        
        if (stack?.count)! > 1, stack?[(stack?.count)! - 2] is MemberInfoViewController {
            _ = self.navigationController?.popViewController(animated: true)
            return
        }
        
        let destinatioVC = storyboard?.instantiateViewController(withIdentifier: .memberViewController) as! MemberInfoViewController
        destinatioVC.model = model
        destinatioVC.navigationItem.rightBarButtonItem = nil
        let createdKPI = arrayOfKPI[sender.tag].createdKPI
        let executantId = createdKPI?.executant
        for i in 0..<model.team.count {
            if Int(model.team[i].userID) == executantId {
                destinatioVC.index = i
                navigationController?.pushViewController(destinatioVC, animated: true)
                return
            }
        }
        showAlert(title: "Error", errorMessage: "Unknown member!")
        return
    }
    
    func deleteDidTaped(sender: UIButton) {
        let indexPath = IndexPath(item: sender.tag, section: 1)
        
        deleteKPI(kpiID: model.kpis[indexPath.row].id)
        model.kpis.remove(at: indexPath.row)
        arrayOfKPI.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}
