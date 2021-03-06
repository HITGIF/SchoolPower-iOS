//
//  Copyright 2019 SchoolPower Studio
//

import UIKit
import Material
import MaterialComponents
import SwiftyJSON

// disabled login dialog
// var toPop = true
var toPop = false

class LoginViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    @IBOutlet weak var appIcon: UIImageView?
    @IBOutlet weak var copyright: UILabel?
    
    var usernameField: TextField!
    var passwordField: TextField!
    var button: FABButton!
    
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
            UIAlertView(title: "notification".localize, message: "only_alert".localize,
                        delegate: nil, cancelButtonTitle: "i_understand".localize).show()
            toPop = false
        }
    }
    
    @objc func loginAction() {
        
        let username = usernameField.text
        let password = passwordField.text
        
        let alert: UIAlertView = UIAlertView(title: "authenticating".localize, message: nil, delegate: nil, cancelButtonTitle: nil)
        let loadingIndicator = UIActivityIndicatorView.init(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating()
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        alert.show()
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"]!
        
        //Send Post
        Utils.sendPost(url: GET_DATA_URL,
                       params: "username=\(username!)" +
                               "&password=\(password!)" +
                               "&version=\(version)" +
                               "&os=ios" +
                               "&action=login"){ (value) in
                                
            DispatchQueue.main.async {
                alert.dismiss(withClickedButtonIndex: -1, animated: true)
            }
            let response = value
            
            if response.contains("Something went wrong!") {
                self.showSnackbar(msg: "invalidup".localize)
            }else if response.contains("\"alert\""){
                self.showSnackbar(msg: try! JSON(data: ("{\(response)}".data(using: .utf8, allowLossyConversion: false)!))["alert"].stringValue)
            }
            else if response.contains("{") {
                
                self.userDefaults.set(username, forKey: USERNAME_KEY_NAME)
                self.userDefaults.set(password, forKey: PASSWORD_KEY_NAME)
                self.userDefaults.set(true, forKey: LOGGED_IN_KEY_NAME)
                
                let (studentInfo, _, data, disabled, disabled_title, disabled_message, extraInfo) = Utils.parseJsonResult(jsonStr: response)
                
                self.userDefaults.set(studentInfo.getFullName(), forKey: STUDENT_NAME_KEY_NAME)
                self.userDefaults.set(studentInfo.dob, forKey: STUDENT_DOB_KEY_NAME)
                self.userDefaults.set(extraInfo.avatar, forKey: USER_AVATAR_KEY_NAME)
            
                
                let token = self.userDefaults.string(forKey: TOKEN_KEY_NAME)
                if token != nil && token != "" { Utils.sendNotificationRegistry(token: token!) }

                Utils.saveStringToFile(filename: JSON_FILE_NAME, data: response)
                Utils.saveHistoryGrade(data: data)
                self.startMainViewController()
                
            } else { self.showSnackbar(msg: "cannot_connect".localize) }
        }
    }
    
    func startMainViewController() {
        
        toPop = true
        OperationQueue.main.addOperation {
            self.present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DashboardNav"),
                    animated: true, completion: self.updateRootViewController)
        }
    }
    
    func updateRootViewController() {
        
        let story = UIStoryboard(name: "Main", bundle: nil)
        let mainController = story.instantiateViewController(withIdentifier: "DashboardNav")
        let leftViewController = story.instantiateViewController(withIdentifier: "Drawer")
        UIApplication.shared.delegate?.window??.rootViewController = AppNavigationDrawerController(
                rootViewController: mainController, leftViewController: leftViewController, rightViewController: nil)
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
        usernameField.placeholderActiveColor = Utils.getAccent()
        usernameField.dividerColor = UIColor(rgb: Colors.primary_darker)
        usernameField.dividerActiveColor = Utils.getAccent()
        usernameField.clearIconButton?.tintColor = Utils.getAccent()
        
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
        passwordField.placeholderActiveColor = Utils.getAccent()
        passwordField.dividerColor = UIColor(rgb: Colors.primary_darker)
        passwordField.dividerActiveColor = Utils.getAccent()
        passwordField.visibilityIconButton?.tintColor = Utils.getAccent()
                .withAlphaComponent(passwordField.isSecureTextEntry ? 0.38 : 1.0)
        
        view.layout(passwordField).center(offsetY: +usernameField.bounds.size.height + 20).left(36).right(36)
    }
    
    fileprivate func prepareAppIcon() {
        view.layout(appIcon!).center(offsetY: -usernameField.bounds.size.height - 150).center()
    }
    
    fileprivate func prepareFAB() {
        
        button = FABButton(image: UIImage(named: "ic_keyboard_arrow_right_white_36pt"), tintColor: .white)
        button.pulseColor = .white
        button.backgroundColor = Utils.getAccent()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        view.addSubview(button)
        
        let heightConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 60)
        let widthConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 60)
        let verticalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 150)
        let horizontalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        
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
