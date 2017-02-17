//
//  PinCodeViewController.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 15.02.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

enum PinMode: String
{
    case createNewPin
    case logIn
}

class PinCodeViewController: UIViewController
{
    struct TextForLabels
    {
        static let cancel = "Cancel"
        static let delete = "Delete"
        static let confirm = "Confirm Passcode"
        static let newPin = "Enter New Passcode"
        static let enter = "Enter Passcode"
        static let tryAgain = "Try Again"
    }
    
    var pinToConfirm = [String]()
    
    fileprivate let pincodeLock = PinCodeLock()
    private var isAnimationCompleted = true
    
    weak var presenter: PinCodeVCPresenter?
    
    var dismissCompletion: (() -> Void)?
    var successCompletion: (() -> Void)?
    var logOutCompletion:  (() -> Void)?
    
    var mode: PinMode?
    var confirmed = false
    
    lazy var model: ModelCoreKPI? = {
        if let data = UserDefaults.standard.data(forKey: "token"),
            let myTokenArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [ModelCoreKPI] {
            let model = ModelCoreKPI(model: myTokenArray[0])
            return model
        }
        
        return nil
    }()
    
    @IBOutlet weak private var infoLabel: UILabel!
    @IBOutlet weak fileprivate var deleteButton: UIButton!
    @IBOutlet weak private var placeholdersConstrainX: NSLayoutConstraint!
    @IBOutlet fileprivate  var pinCodePlaceholderViews: [PinCodePlaceholderView]!
    
    @IBAction private func pinCodeButtonTapped(_ sender: PinCodeButton) {
        guard isAnimationCompleted == true else { return }
        
        pincodeLock.add(value: sender.actualNumber)
        toggleDeleteButton()
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        if sender.titleLabel?.text == TextForLabels.cancel {
            
            if let presenter = presenter {
                if presenter.presentedFromBG {
                    logOutCompletion!()
                }
                else {
                    dismissCompletion!()
                }
            }
            else {
                dismiss(animated: true, completion: nil)
            }
        }
        else {
            pincodeLock.removeLast()
        }
        toggleDeleteButton()
    }
    
    deinit {
        print("DEBUG: Deinitialized")
    }
    
    convenience init(mode: PinMode) {
        self.init(nibName: "PinCodeView", bundle: nil)
        self.mode = mode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var textForLabel = ""
        
        if let mode = mode
        {
            switch mode
            {
            case .createNewPin:
                textForLabel = TextForLabels.newPin
                
            case PinMode.logIn:
                textForLabel = TextForLabels.enter
            }
        }
        
        infoLabel.text = textForLabel
        
        pincodeLock.delegate = self
        infoLabel.textColor  = OurColors.violet
        toggleDeleteButton()
        deleteButton.setTitleColor(OurColors.violet, for: .normal)
        deleteButton.setTitleColor(.lightGray, for: .disabled)
    }
    
    func createNew(pinCode: [String]) {
        
        if pinToConfirm == pinCode {
            model?.profile?.pinCode = pinCode
            dismiss(animated: true, completion: nil)
        }
        else if pincodeLock.attempts != 0 {
            infoLabel.text = TextForLabels.tryAgain
        }
        else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func checkOut(pinCode: [String]) {
        
        //let pinCode = model!.profile!.pinCode
        let testCode = ["1","2","3","4"]
        
        if pincodeLock.attempts > 1 {
            
            isAnimationCompleted  = false
            pincodeLock.attempts -= 1
            
            if pinCode == testCode {
                
                if presentingViewController?.presentedViewController == self {
                    
                    dismiss(animated: true, completion: { [weak self] _ in
                        self?.isAnimationCompleted = true
                        self?.successCompletion?()
                    })
                } else if navigationController != nil {
                    
                  _ = navigationController?.popViewController(animated: true)
                }
                isAnimationCompleted = true
                successCompletion?()
            }
            else {
                animateFailedLoginAttempt()
            }
            
            toggleDeleteButton()
            _ = pinCodePlaceholderViews.map { $0.animate(state: .empty) }
        }
        else {
            if let navController = presentingViewController as? UINavigationController,
                let presenter = navController.topViewController as? SignInViewController {
                
                presenter.toggleEnterByKeyButton(isEnabled: false)
                
                dismiss(animated: true, completion: nil)
            }
            else {
                if presenter!.presentedFromBG {
                    logOutCompletion!()
                }
                else {
                    dismissCompletion!()
                }
            }
        }
    }
    
    fileprivate func toggleDeleteButton() {
        
       // if dismissCompletion != nil { dismissCompletion!(); return }
        
        let isPassCodeEmpty = pincodeLock.passcode.count == 0
        let title = isPassCodeEmpty ? TextForLabels.cancel : TextForLabels.delete
        
        deleteButton.setTitle(title, for: .normal)
    }
    
    func animateFailedLoginAttempt() {
        
        placeholdersConstrainX.constant -= 40
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: [],
                       animations: {
                        self.placeholdersConstrainX.constant = 0
                        self.view.layoutIfNeeded()
        }, completion: nil)
        isAnimationCompleted = true
    }
}

extension PinCodeViewController: PinCodeLockDelegate
{
    func addedValue(at index: Int) {
        
        pinCodePlaceholderViews[index].animate(state: .filled)
    }
    
    func removedValue(at index: Int) {
        
        pinCodePlaceholderViews[index].animate(state: .empty)
    }
    
    func handleAuthorizationBy(pinCode: [String]) {
        
         checkOut(pinCode: pinCode)
    }
}