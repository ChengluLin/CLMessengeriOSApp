//
//  LoginViewController.swift
//  CLMessenger
//
//  Created by ChengLu on 2024/6/24.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "CLMessengerIcon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField = {
       let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "輸入Email..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
       let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "輸入密碼..."
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("登入", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private var loginObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/5
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 30,
                                 width: size,
                                 height: size)
        emailField.frame = CGRect(x: 30,
                                 y: imageView.bottom+50,
                                  width: scrollView.width - 60,
                                 height: 52)
        passwordField.frame = CGRect(x: 30,
                                 y: emailField.bottom+10,
                                  width: scrollView.width - 60,
                                 height: 52)
        loginButton.frame = CGRect(x: 30,
                                 y: passwordField.bottom+10,
                                  width: scrollView.width - 60,
                                 height: 52)
    }
    
    @objc private func loginButtonTapped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        // Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                /// 登入出現錯誤，密碼不正確或信箱不存在
                print("Failed to log in user with email: \(email)")
                return
            }
            
            let user = result.user
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.getDataFor(path: safeEmail, completiom: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                          let firstName = userData["first_name"] as? String,
                          let lastName = userData["last_name"] as? String else {
                        return
                    }
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                    
                    
                case .failure(let error):
                    print("取得data失敗：", error)
                }
            })
            
            UserDefaults.standard.set(email, forKey: "email")
            
            print("Logged In User: \(user)")
            self.navigationController?.dismiss(animated: true)
        }

    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: "提醒", message: "請將資料填寫完整", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確認", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }

}


extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginButtonTapped()
        }
        
        
        return true
    }
}
