//
//  AuthorizationViewController.swift
//  UsersOnTheMap
//
//  Created by Anton Aleksieiev on 11/24/16.
//  Copyright © 2016 fynjy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class AuthorizationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var emailFieldConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.placeholder = "email"
        passwordTextField.placeholder = "password"
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        if let user = FIRAuth.auth()?.currentUser {
            self.signedIn(user: user)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.updateConstraintWith(number: 0)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.placeholder != nil {
            textField.placeholder = nil
        }
        if textField == emailTextField {
            self.updateConstraintWith(number: -70)
        } else {
            self.updateConstraintWith(number: -110)
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
    
    func updateConstraintWith(number: Float) {
        self.emailFieldConstraint.constant = CGFloat(number)
        UIView.animate(withDuration: 0.3, animations:{[unowned self] in
            self.view.layoutIfNeeded()
        })
    }
    private func presentAlertWith(String string: String){
        let alert = UIAlertController(title: "Wrong \(string)", message: "Please, enter correct \(string)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func signedIn(user:FIRUser?) {
        
        CurrentUser.sharedUser.id = user?.uid
        CurrentUser.sharedUser.name = user?.email!.components(separatedBy: "@")[0]
        CurrentUser.sharedUser.signedIn = true
        let notificationName = Notification.Name("kCurrentUserSignedIn")
        NotificationCenter.default.post(name: notificationName, object: nil, userInfo: nil)
        performSegue(withIdentifier: "goToMapView", sender: nil)
    }
    
    //MARK: - IBAction
    
    @IBAction func didTouchSignInButton(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                self.presentAlertWith(String: "data")
                print(error.localizedDescription)
                return
            }
            self.signedIn(user: user)
        }
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
        FIRAuth.auth()?.createUser(withEmail: emailText, password: text, completion: { [unowned self] (user, error) in
            if let error = error {
                let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                print(error.localizedDescription)
                return
            }
            self.signedIn(user: user!)
        })
    }
    
    @IBAction func didTouchSignOutActionButton(segue: UIStoryboardSegue) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            CurrentUser.sharedUser.signedIn = false
            dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
    }

}

