//
//  UserView.swift
//  Mpl.
//
//  Created by Darius Martin on 28/01/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import NotificationBannerSwift

class UserView: UIViewController {
    
    var mainController: MainScrollView? = nil
    
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        nameTextField.text = UserData.displayedName
    }
    
    @IBAction func nameChanged(_ sender: Any) {
        var _tmpName: Array<Character>
        let displayedName: String

        if (mainController == nil) { return }
        if nameTextField.text != nil {
            //Removing last space character
            _tmpName = Array(nameTextField.text!)
            if (_tmpName[_tmpName.count-1] == " ") { _tmpName.removeLast() }
            displayedName = String(_tmpName)
            //Verifying if is alphanumeric
            if displayedName.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && _tmpName.count > 1 {
                //Changing displayed name
                UserData.displayedName = displayedName
                UserData.saveUserData()
                mainController!.updateDisplayedUserName()
                self.view.endEditing(true)
            } else {
                //Warning
                let banner = NotificationBanner(title: "Un problème est survenu.", subtitle: "Veillez à choisir un nom d'affichage correct !", style: .warning)
                banner.show()
            }
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
