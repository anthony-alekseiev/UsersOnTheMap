//
//  AuthorizationViewController.swift
//  UsersOnTheMap
//
//  Created by Anton Aleksieiev on 11/24/16.
//  Copyright © 2016 fynjy. All rights reserved.
//

import UIKit

class AuthorizationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.placeholder = "email"
        passwordTextField.placeholder = "password"
        emailTextField.delegate = self
        passwordTextField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.placeholder != nil {
            textField.placeholder = nil
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.textColor = UIColor.black
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        guard let text : String = textField.text, !text.isEmpty else {
            if textField.placeholder == nil {
                if textField == emailTextField{
                    emailTextField.placeholder = "email"
                } else {
                    passwordTextField.placeholder = "password"
                }
            }
            return true
        }
        if textField == emailTextField{
            let chars : Set<Character> = ["@","."]
            if chars.isSubset(of: text.characters) {
                textField.textColor = UIColor.black
            } else{
                self.presentAlertWith(String: "email")
                textField.textColor = UIColor.red
            }
        }
        return true
    }
    
    //MARK: - Methods
    private func presentAlertWith(String string: String){
        let alert = UIAlertController(title: "Wrong \(string)", message: "Please, enter correct \(string)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func didTouchSignInButton(_ sender: Any) {
        performSegue(withIdentifier: "goToMapView", sender: nil)
    }
    
    @IBAction func didTouchCreateAccountButton(_ sender: Any) {
        guard let emailText = emailTextField.text, !emailText.isEmpty else {
            self.presentAlertWith(String: "email")
            return
        }
        guard let text = passwordTextField.text, !text.isEmpty else {
            self.presentAlertWith(String: "password")
            return
        }
        
    }
    
    @IBAction func didTouchSignOutActionButton(segue: UIStoryboardSegue) {
        
    }

}

