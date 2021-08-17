//
//  WelcomeController.swift
//  Ordernise
//
//  Created by Aaron on 14/08/2021.
//

import UIKit
import FirebaseAuth
import Firebase
import CryptoKit
import FirebaseCore
import AuthenticationServices


class WelcomeController: UIViewController{
    @IBOutlet weak var welcomeView: UIView!
    



    @IBOutlet weak var googleSignIn: UIButton!


    @IBOutlet weak var appleSignIn: UIButton!
    @IBOutlet weak var emailSignIn: UIButton!
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
        
        
        welcomeView.setShadow()
        welcomeView.layer.cornerRadius = 40.0
        emailSignIn.layer.cornerRadius = emailSignIn.frame.height / 2
        
        googleSignIn.layer.cornerRadius = googleSignIn.frame.height / 2
        appleSignIn.layer.cornerRadius = appleSignIn.frame.height / 2
        
        
        //start apple sign in flow
        appleSignIn.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)

        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        let signin = UserDefaults.standard.string(forKey: "LoginMethod")

        if (signin == "APPLE"){
            
            
            isAcccountComplete()

            
        } else if (signin == "GOOGLE"){
            
            isAcccountComplete()

        } else{
            
       
        
        if Auth.auth().currentUser != nil && Auth.auth().currentUser!.isEmailVerified {
            print("USER LOGGED IN")

            isAcccountComplete()
         }
    }
    }
    
    

    func isAcccountComplete(){
        
        if !UserDefaults.standard.bool(forKey: "isAccountComplete")

        {

            DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toCompleteAccount", sender: nil)
            }

        }else{
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toHome", sender: nil)
        }
        }
    }
    
    
//apple sign in
    
  

    @IBAction func beginGoogleSignIn(_ sender: Any) {
   
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
    
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
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
extension WelcomeController: ASAuthorizationControllerDelegate {
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
                    print("not err")
                }
                guard let user = authResult?.user else { return }
                let email = user.email ?? ""
                let displayName = user.displayName ?? ""
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let db = Firestore.firestore()
                db.collection("User").document(uid).setData([
                    "email": email,
                    "displayName": displayName,
                    "uid": uid
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        
                        // check if user has completed account
                        if !UserDefaults.standard.bool(forKey: "isAccountComplete")

                        {
                            
                            
                            self.performSegue(withIdentifier: "toCompleteAccount", sender: nil)

                            
                        }else{
                            
                      // login success
                                
                                self.performSegue(withIdentifier: "toHome", sender: nil)
                            UserDefaults.standard.set("APPLE", forKey: "LoginMethod")
                            
                        }
                        
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
}


extension WelcomeController : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

