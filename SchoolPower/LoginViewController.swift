//
//  LoginViewController.swift
//  SchoolPower
//
//  Created by carbonyl on 2417-06-29.
//  Copyright © 2417 carbonylgroup.studio. All rights reserved.
//

import UIKit
import Material

class LoginViewController: UIViewController {
    
    @IBOutlet weak var appIcon: UIImageView?
    @IBOutlet weak var copyright: UILabel?
    
    fileprivate var usernameField: TextField!
    fileprivate var passwordField: TextField!
    fileprivate var button: FABButton!
    
    let userDefaults = UserDefaults.standard
    let JSON_FILE_NAME = "dataMap.json"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        prepareUI()
    }
    
    func loginAction(sender: UIButton) {
        
        let username = usernameField.text
        let password = passwordField.text
        Utils().sendPost(url: "https://schoolpower.studio:8443/api/ps.php", params: "username=" + username! + "&password=" + password!){ (value) in
            
            let response = value
            let messages = response.components(separatedBy: "\n")
            
            if response.contains("{\"error\":1,\"") {
                //TODO SNACKBAR
            } else if response.contains("[{\"") {
                
                self.userDefaults.set(username, forKey: "username")
                self.userDefaults.set(password, forKey: "password")
                self.userDefaults.set(true, forKey: "loggedin")
                self.userDefaults.set(messages[0], forKey: "studentName")
                self.userDefaults.synchronize()
                Utils().saveStringToFile(filename: self.JSON_FILE_NAME, data: messages[1])
                self.startMainViewController()
                
            } else {
                //TODO SNACKBAR
            }
        }
    }
    
    func startMainViewController() {
        
        OperationQueue.main.addOperation {
            UIApplication.shared.delegate?.window??.rootViewController!.present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DashboardNav"), animated: true, completion: self.updateRootViewController)
        }
    }
    
    func updateRootViewController() {
        
        let story = UIStoryboard(name: "Main", bundle: nil)
        let mainController = story.instantiateViewController(withIdentifier: "DashboardNav")
        let leftViewController = story.instantiateViewController(withIdentifier: "Drawer")
        UIApplication.shared.delegate?.window??.rootViewController = AppNavigationDrawerController(rootViewController: mainController, leftViewController: leftViewController, rightViewController: nil)
    }
}

//MARK: UI
extension LoginViewController {
    
    func prepareUI() {
        
        prepareUsernameField()
        preparePasswordField()
        prepareAppIcon()
        prepareFAB()
        copyright?.text = "copyright".localize
    }
    
    fileprivate func prepareUsernameField() {
        
        usernameField = TextField()
        usernameField.placeholder = "username".localize
        usernameField.isClearIconButtonEnabled = true
        usernameField.minimumFontSize = 18
        _ = usernameField.becomeFirstResponder()
        
        usernameField.textColor = Utils().hexStringToUIColor(hex: Colors().white)
        usernameField.placeholderNormalColor = Utils().hexStringToUIColor(hex: Colors().primary_darker)
        usernameField.placeholderActiveColor = Utils().hexStringToUIColor(hex: Colors().accent)
        usernameField.dividerColor = Utils().hexStringToUIColor(hex: Colors().primary_darker)
        usernameField.dividerActiveColor = Utils().hexStringToUIColor(hex: Colors().accent)
        usernameField.clearIconButton?.tintColor = Utils().hexStringToUIColor(hex: Colors().accent)
        
        view.layout(usernameField).center(offsetY: -20).left(36).right(36)
    }
    
    fileprivate func preparePasswordField() {
        
        passwordField = TextField()
        passwordField.placeholder = "password".localize
        passwordField.isVisibilityIconButtonEnabled = true
        passwordField.minimumFontSize = 18
        
        passwordField.textColor = Utils().hexStringToUIColor(hex: Colors().white)
        passwordField.placeholderNormalColor = Utils().hexStringToUIColor(hex: Colors().primary_darker)
        passwordField.placeholderActiveColor = Utils().hexStringToUIColor(hex: Colors().accent)
        passwordField.dividerColor = Utils().hexStringToUIColor(hex: Colors().primary_darker)
        passwordField.dividerActiveColor = Utils().hexStringToUIColor(hex: Colors().accent)
        passwordField.visibilityIconButton?.tintColor = Utils().hexStringToUIColor(hex: Colors().accent).withAlphaComponent(passwordField.isSecureTextEntry ? 0.38 : 1.0)
        
        view.layout(passwordField).center(offsetY: +usernameField.height + 20).left(36).right(36)
    }
    
    fileprivate func prepareAppIcon() {
        
        view.layout(appIcon!).center(offsetY: -usernameField.height - 150).center()
    }
    
    fileprivate func prepareFAB() {
        
        button = FABButton(image: UIImage(named: "ic_keyboard_arrow_right_white_36pt"), tintColor: UIColor.white)
        button.pulseColor = UIColor.white
        button.backgroundColor = Utils().hexStringToUIColor(hex: Colors().accent)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        view.addSubview(button)
        
        let heightConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 60)
        let widthConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 60)
        let verticalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 150)
        let horizontalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        
        view.addConstraints([heightConstraint, widthConstraint, verticalConstraint, horizontalConstraint])
    }
}
