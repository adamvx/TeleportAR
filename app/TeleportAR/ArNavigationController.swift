//
//  ArNavigationController.swift
//  TeleportAR
//
//  Created by Adam Vician on 23/05/2021.
//

import UIKit

class ArNavigationController: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setup(viewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(viewController: UIViewController) {
        super.viewDidLoad()
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(onClose))
        navigationBar.isTranslucent = true
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    @objc func onClose() {
        let alert = UIAlertController(title: "Ukončiť konferenciu?", message: "Po ukončení sa možete znova pripojiť.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Áno", style: .default, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Nie", style: .cancel, handler: nil))

        self.present(alert, animated: true)
        
    }

}
