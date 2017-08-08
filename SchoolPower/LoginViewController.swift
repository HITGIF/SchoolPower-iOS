//
//  Copyright 2017 SchoolPower Studio

//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at

//  http://www.apache.org/licenses/LICENSE-2.0

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.


import UIKit
import Material
import MaterialComponents

var toPop = true

class LoginViewController: UIViewController {
    
    @IBOutlet weak var appIcon: UIImageView?
    @IBOutlet weak var copyright: UILabel?
    
    var usernameField: TextField!
    var passwordField: TextField!
    var button: FABButton!
    
    let userDefaults = UserDefaults.standard
    let JSON_FILE_NAME = "dataMap.json"
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        popUp()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        prepareUI()
    }
    
    func popUp() {
        
        if toPop {
            UIAlertView(title: "notification".localize, message: "only_alert".localize, delegate: nil, cancelButtonTitle: "i_understand".localize).show()
            toPop = false
        }
    }
    
    func loginAction() {
        
        let username = usernameField.text
        let password = passwordField.text
        
        let alert: UIAlertView = UIAlertView(title: "authenticating".localize, message: nil, delegate: nil, cancelButtonTitle: nil)
        let loadingIndicator = UIActivityIndicatorView.init(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating()
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        alert.show()
        
        Utils.sendPost(url: "https://api.schoolpower.studio:8443/api/ps.php", params: "username=" + username! + "&password=" + password!){ (value) in
            
            alert.dismiss(withClickedButtonIndex: -1, animated: true)
            let response = value
            let messages = response.components(separatedBy: "\n")
            
            if response.contains("error") {self.showSnackbar(msg: "invalidup".localize)}
            else if response.contains("[{\"") || messages[1] == "[]" {
                
                self.userDefaults.set(username, forKey: "username")
                self.userDefaults.set(password, forKey: "password")
                self.userDefaults.set(true, forKey: "loggedin")
                self.userDefaults.set(messages[0], forKey: "studentname")
                self.userDefaults.synchronize()
                
                Utils.saveStringToFile(filename: self.JSON_FILE_NAME, data: messages[1])
                if messages[1] != "[]" { Utils.saveHistoryGrade(data: Utils.parseJsonResult(jsonStr: messages[1]))}
                self.startMainViewController()
                
            } else { self.showSnackbar(msg: "cannot_connect".localize) }
        }
    }
    
    func startMainViewController() {
        
        toPop = true
        OperationQueue.main.addOperation {
            
            self.present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DashboardNav"), animated: true, completion: self.updateRootViewController)
        }
    }
    
    func updateRootViewController() {
        
        let story = UIStoryboard(name: "Main", bundle: nil)
        let mainController = story.instantiateViewController(withIdentifier: "DashboardNav")
        let leftViewController = story.instantiateViewController(withIdentifier: "Drawer")
        UIApplication.shared.delegate?.window??.rootViewController = AppNavigationDrawerController(rootViewController: mainController, leftViewController: leftViewController, rightViewController: nil)
    }
    
    func showSnackbar(msg: String) {
        
        let message = MDCSnackbarMessage()
        message.text = msg
        message.duration = 2
        MDCSnackbarManager.show(message)
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
        usernameField.tag = 1
        usernameField.returnKeyType = .next
        usernameField.delegate = self
        _ = usernameField.becomeFirstResponder()
        
        usernameField.textColor = UIColor(rgb: Colors.white)
        usernameField.placeholderNormalColor = UIColor(rgb: Colors.primary_darker)
        usernameField.placeholderActiveColor = UIColor(rgb: Colors.accent)
        usernameField.dividerColor = UIColor(rgb: Colors.primary_darker)
        usernameField.dividerActiveColor = UIColor(rgb: Colors.accent)
        usernameField.clearIconButton?.tintColor = UIColor(rgb: Colors.accent)
        
        view.layout(usernameField).center(offsetY: -20).left(36).right(36)
    }
    
    fileprivate func preparePasswordField() {
        
        passwordField = TextField()
        passwordField.placeholder = "password".localize
        passwordField.isVisibilityIconButtonEnabled = true
        passwordField.minimumFontSize = 18
        passwordField.tag = 2
        passwordField.returnKeyType = .done
        passwordField.delegate = self
        
        passwordField.textColor = UIColor(rgb: Colors.white)
        passwordField.placeholderNormalColor = UIColor(rgb: Colors.primary_darker)
        passwordField.placeholderActiveColor = UIColor(rgb: Colors.accent)
        passwordField.dividerColor = UIColor(rgb: Colors.primary_darker)
        passwordField.dividerActiveColor = UIColor(rgb: Colors.accent)
        passwordField.visibilityIconButton?.tintColor = UIColor(rgb: Colors.accent).withAlphaComponent(passwordField.isSecureTextEntry ? 0.38 : 1.0)
        
        view.layout(passwordField).center(offsetY: +usernameField.height + 20).left(36).right(36)
    }
    
    fileprivate func prepareAppIcon() {
        view.layout(appIcon!).center(offsetY: -usernameField.height - 150).center()
    }
    
    fileprivate func prepareFAB() {
        
        button = FABButton(image: UIImage(named: "ic_keyboard_arrow_right_white_36pt"), tintColor: .white)
        button.pulseColor = .white
        button.backgroundColor = UIColor(rgb: Colors.accent)
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

extension LoginViewController: TextFieldDelegate {
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        (textField as? ErrorTextField)?.isErrorRevealed = false
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField.tag {
        case 1:
            _ = passwordField.becomeFirstResponder()
        case 2:
            loginAction()
        default:
            break
        }
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        (textField as? ErrorTextField)?.isErrorRevealed = false
        return true
    }
}
