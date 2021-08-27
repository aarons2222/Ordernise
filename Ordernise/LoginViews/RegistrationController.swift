//
//  RegistrationController.swift
//  Ordernise
//
//  Created by Aaron on 25/07/2021.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

import Firebase
import AuthenticationServices
import CryptoKit

class RegistrationController: UIViewController {

    @IBOutlet weak var registrationEmail: UITextField!
    @IBOutlet weak var registrationPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var registrationView: UIView!
    
    
    @IBOutlet weak var btnLogin: UIButton!
    
    @IBOutlet weak var appleSignUp: UIButton!
    @IBOutlet weak var googleSignUp: UIButton!
    
        
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

       
        
        
        registrationView.setShadow()
        registrationView.layer.cornerRadius = 40.0
        
        
        btnLogin.layer.cornerRadius = btnLogin.frame.height / 2
        appleSignUp.layer.cornerRadius = appleSignUp.frame.height / 2
        googleSignUp.layer.cornerRadius = googleSignUp.frame.height / 2
        
        
        appleSignUp.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)

        
    }

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnRegister(_ sender: Any) {
        

        
        guard let email = registrationEmail.text, !email.isEmpty,
        let password = registrationPassword.text, !password.isEmpty else{
            
            
            
            // error with login
            
            print("loginn failed")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] result, error in
            

        
            print("REGISTRATIOPN in")
            
            
            
            if error != nil {

                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    
                    print("Error \(errCode)")

                             switch errCode {
                             case .emailAlreadyInUse:
                                DispatchQueue.main.async {
                                    print("Email alread exists")
                                    self!.showError(message: "That account already exists, please login", dismiss: true, toLogin: true)
                                }

                             case .invalidEmail:
                                DispatchQueue.main.async {
                                    print("User does not exist")
                                    self!.showError(message: "Please provide a valid email address", dismiss: true, toLogin: false)
                                }
                                
                             case .weakPassword:
                                DispatchQueue.main.async {
                                    print("User does not exist")
                                    self!.showError(message: "Please provide a stronger password", dismiss: true, toLogin: false)
                                }
                               
                                 default:
                                     print("Create User Error: \(error!)")
                             }
                         }

                     } else {
                        
                        // registered successfully
                        
                        Auth.auth().currentUser?.sendEmailVerification { error in
                     
                            if error != nil {
                                
                                // error sengin vrification email
                                print("TAG REGISTRATION \(String(describing: error))")
                            }else{
                                
                                
                                
                                let userID : String = (Auth.auth().currentUser?.uid)!
                                

                                let db = Firestore.firestore()

                                
                                
                                db.collection("Users").document(userID).setData([
                                    "email": email,
                              
                                                      ]) { err in
                                                          if let err = err {
                                                              print("Error writing document: \(err)")
                                                          } else {
                                                              print("Document successfully written!")
                                                            
                                                            
                                                          }
                                                      }

                                
                          //Bool

                                print("TAG REGISTRATION SUCCESS")
                                let alert = UIAlertController(title: "Thank you for registering", message: "A verification email has been to \(email)", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                       
                                    
                                    if action.style == .default{
                                        DispatchQueue.main.async {

                                            
                                            self!.dismiss(animated: true, completion: nil)

                                        }
                                    }
                                    
                                }))
                                self!.present(alert, animated: true, completion: nil)
                                
                            }
                        }
                        
                        

                        
                        
                        
                        


                     }
            
            
        })
        
    }
    func showError(message: String, dismiss: Bool, toLogin: Bool) {
            
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        if dismiss {
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                            
                
                if toLogin{
                    self.dismiss(animated: true, completion: nil)
                }

            }))
        }
        self.dismiss(animated: true, completion: nil)

    }
    

    
    
    
    
    // Unhashed nonce.
      fileprivate var currentNonce: String?
      
       @available(iOS 13, *)
      @objc func startSignInWithAppleFlow() {
          let nonce = randomNonceString()
          currentNonce = nonce
          let appleIDProvider = ASAuthorizationAppleIDProvider()
          let request = appleIDProvider.createRequest()
          request.requestedScopes = [.fullName, .email]
          request.nonce = sha256(nonce)
          
          let authorizationController = ASAuthorizationController(authorizationRequests: [request])
          authorizationController.delegate = self
          authorizationController.presentationContextProvider = self
          authorizationController.performRequests()
      }
      
      @available(iOS 13, *)
      private func sha256(_ input: String) -> String {
          let inputData = Data(input.utf8)
          let hashedData = SHA256.hash(data: inputData)
          let hashString = hashedData.compactMap {
              return String(format: "%02x", $0)
          }.joined()
          
          return hashString
      }
    
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
}




@available(iOS 13.0, *)
extension RegistrationController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if (error != nil) {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error?.localizedDescription ?? "")
                    print("err")
                    return
                }else{
                    
            
                        
                        let userID : String = (Auth.auth().currentUser?.uid)!
                        let userEmail : String = (Auth.auth().currentUser?.email)!
                        

                        let db = Firestore.firestore()

                        
                        
                        db.collection("Users").document(userID).setData([
                            "email": userEmail,
                      
                                              ]) { err in
                                                  if let err = err {
                                                      print("Error writing document: \(err)")
                                                  } else {
                                                      print("Document successfully written!")
                                                    
                                                    
                                                    print("USER ACCOUNT CREATED")
                                                    
                                                  }
                                              }
                        
                        
                        
                    CompleteAccountController.showPopup(parentVC: self)
                        UserDefaults.standard.set("APPLE", forKey: "LoginMethod")

                    }
                    
                
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
    
    
    
    
    static func showPopup(parentVC: UIViewController){
        
        //creating a reference for the dialogView controller
        if let popupViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegistrationController") as? RegistrationController {
            popupViewController.modalPresentationStyle = .custom
            popupViewController.modalTransitionStyle = .crossDissolve
            
            //presenting the pop up viewController from the parent viewController
            parentVC.present(popupViewController, animated: true)
        }
    }
}


extension RegistrationController : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

