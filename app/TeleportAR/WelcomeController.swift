//
//  WelcomeController.swift
//  TeleportAR
//
//  Created by Adam Vician on 21/05/2021.
//

import UIKit
import Alamofire
import MaterialComponents
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming

public let semanticColorScheme: MDCSemanticColorScheme = {
    let colorScheme = MDCSemanticColorScheme()
    colorScheme.primaryColor = UIColor(rgb: 0x5b5bff)
    colorScheme.secondaryColor = UIColor(rgb: 0x5b5bff)
    colorScheme.backgroundColor = UIColor(rgb: 0xccccc)
    return colorScheme
}()

public let colorScheme: MDCContainerScheme = {
    let scheme = MDCContainerScheme()
    scheme.colorScheme = semanticColorScheme
    return scheme
}()

class WelcomeController: UIViewController {

    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Zadajte IP adresu servera na pripojenie sa do virtuálnej 3D konferencie."
        label.font = label.font.withSize(14)
        label.textColor = UIColor.lightText
        label.numberOfLines = 0
        return label
    }()
    
    let field: MDCOutlinedTextField = {
        let field = MDCOutlinedTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.label.text = "IP adresa servera"
        field.placeholder = "192.168.1.1"
        field.text = "192.168.1.116"
        field.sizeToFit()
        return field
    }()
    
    let button: MDCButton = {
        let label = MDCButton()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityLabel = "Pripojiť sa"
        label.setTitle("Pripojiť sa", for: .normal)
        label.addTarget(self, action: #selector(onButtonPress(_:)), for: .touchUpInside)
        label.applyContainedTheme(withScheme: colorScheme)
        return label
    }()
    
    func buildSnack(text: String) -> MDCSnackbarMessage{
        let message = MDCSnackbarMessage()
        message.text = text
        let action = MDCSnackbarMessageAction()
        action.title = "OK"
        message.action = action
        return message
    }
    
    @objc func onButtonPress(_ sender: UIButton) {
        guard let text = field.text, validateIpAddress(ipToValidate: text) else{
            MDCSnackbarManager.default.show(buildSnack(text: "Zadali ste zlú IP adresu"))
            return
        }
        
        checkServerStatus(ip: text) { [weak self] online in
            if online {
                let target = ArViewController()
                target.url = URL(string: "http://\(text):3000/app")!
                
                let navigation = ArNavigationController(rootViewController: target)
                navigation.modalPresentationStyle = .fullScreen
                self?.present(navigation, animated: true)
            } else {
                MDCSnackbarManager.default.show(self?.buildSnack(text: "Server je offline"))
            }
        }
        
        
        
    }
    
    func checkServerStatus(ip: String, callback: @escaping (_ res: Bool) -> Void){
        AF.request("http://\(ip):3000/check").response { response in
            if let _ = response.error {
                callback(false)
                return
            }
            if let _ = response.data {
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "TeleportAR"
        setupViews()
    }
    
    func setupViews(){
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        view.addSubview(label)
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).activate()
        label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).activate()
        label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).activate()
        
        view.addSubview(field)
        field.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16).activate()
        field.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).activate()
        field.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).activate()

        view.addSubview(button)
        button.topAnchor.constraint(equalTo: field.bottomAnchor, constant: 16).activate()
        button.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8).activate()
        button.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8).activate()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        field.becomeFirstResponder()
    }
    
    func validateIpAddress(ipToValidate: String) -> Bool {
        var sin = sockaddr_in()
        if ipToValidate.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            return true
        }
        return false;
    }
    
}

extension NSLayoutConstraint {
    func activate(){
        self.isActive = true
    }
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
