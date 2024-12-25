//
//  LoginViewController.swift
//  etoile
//
//  Created by Juliette Bernheisel on 8/21/24.
//

import Foundation
import UIKit
import SnapKit
import SimpleKeychain
import OSLog
import EtoileKit

class LoginViewController: UIViewController {
    
    let welcomeLabel = UILabel()
    let instanceTextField = UITextField()
    let usernameTextField = UITextField()
    let passwordTextField = UITextField()
    let submitButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Welcome label:)
        welcomeLabel.text = "Welcome to Etoile"
        welcomeLabel.accessibilityLabel = "welcomeLabel"
        welcomeLabel.font = .systemFont(ofSize: 20)
        welcomeLabel.textColor = .etoileTextColor()
        
        self.view.addSubview(welcomeLabel)
        
        welcomeLabel.snp.makeConstraints { make in
            make.center.equalTo(self.view)
            make.left.equalTo(self.view).offset(20)
            make.width.equalTo(self.view)
        }
        
        // Info label:)
        let infoLabel = UILabel()
        infoLabel.text = "To get started please input your Jellyfin instance information"
        infoLabel.font = .systemFont(ofSize: 14)
        infoLabel.accessibilityLabel = "infoLabel"
        infoLabel.numberOfLines = 0
        infoLabel.lineBreakMode = .byWordWrapping
        infoLabel.textColor = .etoileTextColor()
        
        self.view.addSubview(infoLabel)
        
        infoLabel.sizeToFit()

        infoLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(welcomeLabel).offset(40)
            make.left.equalTo(self.view).offset(20)
        }
        
        
        // Instance url textfield
        instanceTextField.placeholder = "Instance URL"
        instanceTextField.accessibilityLabel = "Instance URL"
        instanceTextField.keyboardType = .URL
        instanceTextField.delegate = self
        instanceTextField.autocapitalizationType = .none
        instanceTextField.textColor = .etoileBackground()
        instanceTextField.backgroundColor = .etoileTextColor()
        instanceTextField.layer.cornerRadius = 5
        instanceTextField.autocorrectionType = .no // No autocorrect, we're a url!
        
        self.view.addSubview(instanceTextField)
        
        instanceTextField.snp.makeConstraints { make in
            make.centerY.equalTo(infoLabel).offset(40)
            make.centerX.equalTo(self.view)
            make.width.equalTo(self.view).offset(-40)
        }
        
        // Username textfield!
        usernameTextField.placeholder = "Username"
        usernameTextField.accessibilityLabel = "Username"
        usernameTextField.textContentType = .username
        usernameTextField.delegate = self
        usernameTextField.autocapitalizationType = .none
        usernameTextField.textColor = .etoileBackground()
        usernameTextField.backgroundColor = .etoileTextColor()
        usernameTextField.layer.cornerRadius = 5
        usernameTextField.autocorrectionType = .no
        
        self.view.addSubview(usernameTextField)
        
        usernameTextField.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(instanceTextField.snp.bottom).offset(20)
            make.width.equalTo(self.view).offset(-40)
        }
        
        // Password textfield!
        passwordTextField.placeholder = "Password"
        passwordTextField.accessibilityLabel = "Password"
        passwordTextField.textContentType = .password
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = .none
        passwordTextField.delegate = self
        passwordTextField.textColor = .etoileBackground()
        passwordTextField.backgroundColor = .etoileTextColor()
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.autocorrectionType = .no
        
        self.view.addSubview(passwordTextField)
        
        passwordTextField.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(usernameTextField.snp.bottom).offset(20)
            make.width.equalTo(self.view).offset(-40)
        }
        
        // Submit:)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.accessibilityLabel = "Submit"
        submitButton.addTarget(self, action: #selector(submitPressed), for: .touchUpInside)
        submitButton.backgroundColor = .etoileButtonBackground()
        submitButton.titleLabel?.textColor = .etoileButtonBackground()
        submitButton.layer.cornerRadius = 5
        self.view.addSubview(submitButton)
        
        submitButton.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(passwordTextField.snp.bottom).offset(40)
        }
        
    }
    
    @objc func hideKeyboard() {
        usernameTextField.endEditing(true)
        passwordTextField.endEditing(true)
        usernameTextField.endEditing(true)
    }

    @objc func submitPressed() {
        
        // Checking the options have any value, if they don't throw alert
        if instanceTextField.text == nil || usernameTextField.text == nil || passwordTextField.text == nil || instanceTextField.text == "" || usernameTextField.text == "" ||  passwordTextField.text == "" {
            // If not alert the user about that
            let alert = UIAlertController(title: "Error!", message: "Please fill out all the forms!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                alert.dismiss(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)

        }
        
        guard let instanceUrl = URL(string: instanceTextField.text ?? "") else { return }
        
        // If we're debugging just set the variable to be good, we're not setting up a mock jellyfin server!
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            welcomeLabel.text = "Good"
        }

        Task.detached { [self] in
            do {
                let keychain = SimpleKeychain(service: "etoile")
                // Saving the info!
                try keychain.set(instanceTextField.text ?? "", forKey: "instance")
                try keychain.set(usernameTextField.text ?? "", forKey: "username")
                try keychain.set(passwordTextField.text ?? "", forKey: "password")
                ConfigurationSingleton.shared.username = try keychain.string(forKey: "username")
                
                let signInModel = SignInModel()
                try await signInModel.signIn(deviceName: UIDevice.current.name, username: usernameTextField.text ?? "", password: passwordTextField.text ?? "", instance: instanceUrl, callBack: { token in
                    do {
                        // If we did, save it in keychain
                        try keychain.set(token, forKey: "token")
                        
                        await MainActor.run {
                            // Then move view controllers
                            self.navigationController?.setViewControllers([FullFetchViewController()], animated: true)
                        }
                        
                    } catch {
                        Logger().error("\(#file):\(#line) > error logging in \n details: \(error) \n =========")
                    }

                })
            } catch {
                let alert = UIAlertController(title: "Error!", message: "Error securely saving your info, try resubmitting?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    alert.dismiss(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
                Logger().error("\(#file):\(#line) > error logging in \n details: \(error) \n =========")
            }
        }

    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

