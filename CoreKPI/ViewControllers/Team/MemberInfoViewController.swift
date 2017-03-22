//
//  MemberInfoViewController.swift
//  CoreKPI
//
//  Created by Семен on 19.12.16.
//  Copyright © 2016 SmiChrisSoft. All rights reserved.
//

import UIKit
import MessageUI
import PhoneNumberKit

class MemberInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var memberProfilePhotoImage = UIImageView()
    var memberProfileNameLabel = UILabel()
    var memberProfilePositionLabel = UILabel()
    var notificationCenter = NotificationCenter.default
    
    
    @IBOutlet weak var responsibleForButton: UIButton!
    @IBOutlet weak var myKPIsButton: UIButton!
    @IBOutlet weak var securityButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var model: ModelCoreKPI!
    var index: Int!
    var securityCellIndexPath = IndexPath()
    var usersPin: [String]? {
        return UserDefaults.standard.value(forKey: "PinCode") as? [String]
    }
    
    weak var memberListVC: MemberListTableViewController!
    
    var updateModelDelegate: updateModelDelegate!
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subscribeNotifications()
        
        let nib = UINib(nibName: "UserInfoTableViewCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "UserInfoCell")
        tableView.allowsSelection = false
        securityButton.isHidden = true
        myKPIsButton.isHidden = true
        responsibleForButton.isHidden = true
        
        //Check admin permission!!
        if model.profile?.typeOfAccount == TypeOfAccount.Admin && !thisIsMyAccount()
        {
            responsibleForButton.isHidden = false
        }
        
        //Check is it my account
        if thisIsMyAccount()
        {
            myKPIsButton.isHidden = false
        }
        
        updateMemberInfo()
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        //Set Navigation Bar transparent
        self.navigationController?.presentTransparentNavigationBar()
        
    }
    
    private func thisIsMyAccount() -> Bool {
        
        return Int(model.team[index].userID) == model.profile?.userId
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let cell = tableView.visibleCells[0] as! UserViewTableViewCell
                
        makeRoundCorners(for: cell.memberProfilePhotoImage)
        _ = cell.buttons.map { makeRoundCorners(for: $0) }
    }
    
    private func makeRoundCorners(for view: UIView) {
        
        let cornerRadius = view.frame.height / 2
        
        view.layer.cornerRadius = cornerRadius
    }
    
    func tapPhoneButton() {
        if model.team[index].phoneNumber == nil {
            let alertController = UIAlertController(title: "Can not call!", message: "Member has not a phone number", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                present(alertController, animated: true, completion: nil)
        } else {
            var url: URL!
            let phoneNumberKit = PhoneNumberKit()
            do {
                let phoneNumber = try phoneNumberKit.parse(model.team[index].phoneNumber!)
                url = URL(string: "tel://+\(phoneNumber.countryCode)\(phoneNumber.nationalNumber)")
            }
            catch {
                print("Generic parser error")
                return
            }
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            } else {
                let alertController = UIAlertController(title: "Sorry", message: "Can not call!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
            }
        }        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if model.profile?.typeOfAccount == TypeOfAccount.Admin && thisIsMyAccount()
        {
            return 5
            
        }
        else { return 4 }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0
        {
            return 250
        }
        else { return 62 }
    }    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell") as! UserViewTableViewCell
            
            cell.delegate = self
            cell.memberProfileNameLabel.text = memberProfileNameLabel.text
            cell.memberProfilePhotoImage.image = memberProfilePhotoImage.image
            cell.memberProfilePositionLabel.text = memberProfilePositionLabel.text
                        
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberInfoCell", for: indexPath) as! MemberInfoTableViewCell
        
        if model.profile?.typeOfAccount == .Admin
        {
            switch indexPath.row
            {
            case 1:
                cell.headerCellLabel.text = "Type of account"
                cell.dataCellLabel.text = model.team[index].isAdmin ? "Admin" : "Manager"
                
            case 2:
                cell.headerCellLabel.text = "Phone"
                if model.team[index].phoneNumber == nil {
                    cell.dataCellLabel.text = "No Phone Number"
                    cell.dataCellLabel.textColor = UIColor(red: 143/255, green: 142/255, blue: 148/255, alpha: 1.0)
                } else {
                    cell.dataCellLabel.text = model.team[index].phoneNumber
                    cell.dataCellLabel.textColor = UIColor.black
                }
                
            case 3:
                
                cell.headerCellLabel.text = "E-mail"
                cell.dataCellLabel.text = model.team[index].username ?? ""
                
            case 4:
                cell.headerCellLabel.text = "Security"
                cell.securitySwitch.isHidden = false
                cell.dataCellLabel.text = "Pin code lock"
                cell.securitySwitch.isOn = usersPin == nil ? false : true
                securityCellIndexPath = indexPath
                
            default:
                cell.headerCellLabel.text = ""
                cell.dataCellLabel.text = ""
                print("Cell create by default case")
            }
        } else {
            switch indexPath.row {
            case 0:
                cell.headerCellLabel.text = "Phone"
                if model.team[index].phoneNumber == nil {
                    cell.dataCellLabel.text = "No Phone Number"
                    cell.dataCellLabel.textColor = UIColor(red: 143/255, green: 142/255, blue: 148/255, alpha: 1.0)
                } else {
                    cell.dataCellLabel.text = model.team[index].phoneNumber
                    cell.dataCellLabel.textColor = UIColor.black
                }
            case 1:
                cell.headerCellLabel.text = "E-mail"
                cell.dataCellLabel.text = model.team[index].username!
                
            case 3:
                cell.headerCellLabel.text = "Security"
                cell.securitySwitch.isHidden = false
                cell.securitySwitch.isOn = usersPin == nil ? false : true
                securityCellIndexPath = indexPath
                
            default:
                cell.headerCellLabel.text = ""
                cell.dataCellLabel.text = ""
                print("Cell create by default case")
            }
        }
        return cell
    }
    
    @IBAction func securityButtonTapped(_ sender: UIButton) {
//        let pinViewController = PinCodeViewController(mode: .createNewPin)
//        present(pinViewController, animated: true, completion: nil)
    }
    
    @IBAction func tapEditBautton(_ sender: UIBarButtonItem) {
        if model.profile?.typeOfAccount != TypeOfAccount.Admin {
            if model.profile?.userId != Int(model.team[index].userID) {
                let vc = storyboard?.instantiateViewController(withIdentifier: "ChangeName") as! ChageNameTableViewController
                
                vc.index = index
                vc.memberInfoVC = self
                self.navigationController?.show(vc, sender: nil)
            } else {
                updateEditMemberVC()
            }
        } else {
            updateEditMemberVC()
        }
    }
    
    func updateEditMemberVC() {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "EditMember") as! MemberEditViewController
        
        vc.index = index
        vc.memberInfoVC = self
        
        self.navigationController?.show(vc, sender: nil)
    }
    
    @IBAction func tapResponsibleForButton(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "KPIListVC") as! KPIsListTableViewController
        vc.model = model
        vc.loadUsersKPI(userID: Int(model.team[index].userID))
        vc.navigationItem.rightBarButtonItem = nil
        vc.refreshControl = nil
        self.navigationController?.show(vc, sender: nil)
    }
    
    @IBAction func tapSecurityButton(_ sender: UIButton) {
        print("Bogdan don't say what this button do ;(")
    }

    //MARK: - navigation
    override func willMove(toParentViewController parent: UIViewController?) {
       
        self.navigationController?.hideTransparentNavigationBar()
    }
    
    func updateProfilePhoto() {
        if (model.team[index].photo != nil) {
            memberProfilePhotoImage.downloadedFrom(link: model.team[index].photoLink!)
        } else {
            memberProfilePhotoImage.image = #imageLiteral(resourceName: "defaultProfile")
        }
    }
    
    func changeSecuritySettings() {        
        
        if usersPin == nil
        {
            let pinViewController = PinCodeViewController(mode: .createNewPin)
            pinViewController.delegate = self
            present(pinViewController, animated: true, completion: nil)
        }
        else {            
            UserDefaults.standard.set(nil, forKey: "PinCode")
            NotificationCenter.default.post(name: .userRemovedPincode, object: nil)
        }
    }
    
    @objc private func reloadTableView() {
        
        tableView?.reloadData()
        updateMemberInfo()
    }
    
    private func subscribeNotifications() {
        
        notificationCenter.addObserver(self,
                                               selector: #selector(MemberInfoViewController.reloadTableView),
                                               name: .modelDidChanged,
                                               object: nil)
        
        //Subscribed for security switcher
        notificationCenter.addObserver(self,
                                               selector: #selector(MemberInfoViewController.changeSecuritySettings),
                                               name:  .userTappedSecuritySwitch,
                                               object: nil)

    }
    
    private func updateMemberInfo() {
        
        if let memberNickname = model.team[index].nickname
        {
            memberProfileNameLabel.text = memberNickname
        }
        else
        {
            if let name = model.team[index].firstName, let lastName = model.team[index].lastName
            {
                memberProfileNameLabel.text = "\(name) \(lastName)"
            }
        }
        
        memberProfilePositionLabel.text = model.team[index].position
        
        if model.team[index].photo != nil {
            memberProfilePhotoImage.image = UIImage(data: model.team[index].photo as! Data)
        } else {
            updateProfilePhoto()
        }
    }
}

//MARK: - MFMailComposeViewControllerDelegate methods
extension MemberInfoViewController: MFMailComposeViewControllerDelegate {
    
    func tapMailButton() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([model.team[index].username!])
            mail.setMessageBody("<p>Hello, \(model.team[index].firstName!) \(model.team[index].lastName!)</p>", isHTML: true)
            present(mail, animated: true)
        } else {
            print("Email error")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

////MARK: - updateModelDelegate method
//extension MemberInfoViewController: updateModelDelegate {
//    func updateModel(model: ModelCoreKPI) {
//        self.model = ModelCoreKPI(model: model)
//        if let nickname = model.team[index].nickname {
//            memberProfileNameLabel.text = nickname
//        } else {
//            memberProfileNameLabel.text = model.team[index].firstName! + " " + model.team[index].lastName!
//        }
//        memberProfilePositionLabel.text = model.team[index].position
//        if model.team[index].photo != nil {
//            memberProfilePhotoImage.image = UIImage(data: model.team[index].photo as! Data)
//        }
//        tableView.reloadData()
//        self.navigationController?.presentTransparentNavigationBar()
//    }
//}

