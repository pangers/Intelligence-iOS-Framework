//
//  IdentityModuleViewController.swift
//  IntelligenceDemo-Swift
//
//  Created by Chris Nevin on 05/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit
import IntelligenceSDK

let IntelligenceDemoStoredDeviceTokenKey = "IntelligenceDemoStoredDeviceTokenKey"

class IdentityModuleViewController: UITableViewController {

    private let ManageUserSegue = "ManageUser"
    private let ViewUserSegue = "ViewUser"

    private var user: Intelligence.User?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ManageUserSegue {
            if let manageUser = segue.destination as? ManageUserViewController {
                manageUser.user = user
            }
        } else if segue.identifier == ViewUserSegue {
            if let viewUser = segue.destination as? ViewUserViewController {

                viewUser.user = user
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }

        if indexPath.row == 0 {
            login()
        } else if indexPath.row == 1 {
            getUser()
        } else {
            let application = UIApplication.shared
            let delegate = application.delegate as! AppDelegate

            delegate.alert(withMessage: "Unexpected Row")
        }
    }

    func login() {
        let alert = UIAlertController(title: "Enter Details", message: nil, preferredStyle: UIAlertControllerStyle.alert)

        alert.addTextField { (textField) -> Void in
            textField.placeholder = "Username"
        }

        alert.addTextField { (textField) -> Void in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }

        alert.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.default, handler: { [weak self] (_) -> Void in
            guard let username = alert.textFields?.first?.text, let password = alert.textFields?.last?.text else {
                return
            }

            // logout before we login to clear the previous token (which means we check the login credentials, not just the token)
            IntelligenceManager.intelligence?.identity.logout()

            IntelligenceManager.intelligence?.identity.login(with: username, password: password, callback: { [weak self] (user, error) -> Void in
                guard let strongSelf = self else {
                    return
                }

                DispatchQueue.main.async {

                    guard error == nil else {
                        let application = UIApplication.shared

                        let delegate = application.delegate as! AppDelegate

                        delegate.alert(withMessage: "Login Failed")

                        return
                    }

                    strongSelf.user = user
                    strongSelf.performSegue(withIdentifier: strongSelf.ManageUserSegue, sender: strongSelf)
                }
            })
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) -> Void in
        })
        present(alert, animated: true) { }
    }

    func getUser() {
//        let alertController = UIAlertController(title: "Enter Details", message: nil, preferredStyle: .alert)
//        
//        alertController.addTextField { (textField) -> Void in
//            textField.placeholder = "UserId"
//        }
//        
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
//        })
//        
//        alertController.addAction(UIAlertAction(title: "Get User", style: .default) { [weak self] (action) -> Void in
//            
//            guard let strongSelf = self,
//                let userString = alertController.textFields?.first?.text,
//                let
//                
//                userId = Int(userString) else {
//                    return
//            }
//            
//            IntelligenceManager.intelligence?.identity.getUser(with: userId, callback: { [weak strongSelf] (user, error) -> () in
//                guard let strongSelf = strongSelf else {
//                    return
//                }
//                
//                DispatchQueue.main.async{
//                    strongSelf.user = user
//                    strongSelf.performSegue(withIdentifier: strongSelf.ViewUserSegue, sender: strongSelf)
//                }
//            })
//        })
//        
//        present(alertController, animated: true) { }
    }

    @IBAction func unwindOnLogout(segue: UIStoryboardSegue) {

    }

    func loginUser(with username: String, password: String, callback: @escaping (Intelligence.User?, NSError?) -> Void) {

        IntelligenceManager.intelligence?.identity.logout()

        IntelligenceManager.intelligence?.identity.login(with: username, password: password, callback: { [weak self] (user, error) -> Void in
            guard let strongSelf = self else {
                return
            }

            DispatchQueue.main.async {

                guard error == nil else {
                    let application = UIApplication.shared

                    let delegate = application.delegate as! AppDelegate

                    delegate.alert(withMessage: "Login Failed")

                    callback(nil, error)
                    return
                }

                strongSelf.user = user
                callback(user, error)
            }
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        self.startProcessing { (error) in
//            if (nil == error){
//                print("SUCESS");
//            }
//            else{
//                print("FAILED");
//            }
//        }
    }

    /* Testing */
    func startProcessing(handler:@escaping(NSError?) -> Void) {

        self.startupIdentitModule { (status) in

            if !status {
                print("Error - Intellignce Module : Failed to Startup Module")
                assert(true, "Error - Intellignce Module : Failed to get current info")
                let error = NSError(domain: "Intelligence.Startup.failed", code: 101, userInfo: nil)
                handler(error)
                return
            }

            self.getMe(complition: { (user, error) in

                if let err = error {
                    print(error ?? "Error - Intellignce Module : Failed to get current info")
                    assert(true, "Error - Intellignce Module : Failed to get current info")
                    handler(err)
                    return
                }

                self.logout(complition: { (error) in

                    if (nil != error) {
                        assert(true, "Error - Intellignce Module : Failed to logout")
                        assert(true, "Error - Intellignce Module : Failed to logout")
                        handler(error)
                        return
                    }

                    let userName = user?.username
                    let password = UserDefaults.standard.string(forKey: "Test_Password")

                    self.loginUser(with: userName!, password: password!, callback: { (user, error) in

                        if (nil != error) {
                            print(error ?? "Error - Intellignce Module : Failed to login")
                            assert(true, "Error - Intellignce Module : Failed to login")
                            handler(error)
                            return
                        }

                        self.updateUser(user: user!, complition: { (user, error) in

                            if (nil != error) {
                                print(error ?? "Error - Intellignce Module : Failed to update user info")
                                assert(true, "Error - Intellignce Module : Failed to update user info")
                                handler(error)
                                return
                            }
                            //
                            self.assisgn(role: 3492, user: user!, complition: { (user, error) in

                                if (nil != error) {
                                    print(error ?? "Error - Intellignce Module : Failed to assign role")
                                    assert(true, "Error - Intellignce Module : Failed to assign role")
                                    handler(error)
                                    return
                                }

                                self.revoke(role: 3492, user: user!, complition: { (user, error) in

                                    if (nil != error) {
                                        print(error ?? "Error - Intellignce Module : Failed to revoke role")
                                        assert(true, "Error - Intellignce Module : Failed to revoke role")
                                        handler(error)
                                        return
                                    }

                                    self.assisgn(role: 3491, user: user!, complition: { (user, error) in

                                        if (nil != error) {
                                            print(error ?? "Error - Intellignce Module : Failed to assign role")
                                            assert(true, "Error - Intellignce Module : Failed to assign role")
                                            handler(error)
                                            return
                                        }

                                        self.getUser(userId: user!.userId, complition: { (user, error) in

                                            if (nil != error) {
                                                print(error ?? "Error - Intellignce Module : Failed to get User")
                                                assert(true, "Error - Intellignce Module : Failed to get User")
                                                handler(error)
                                                return
                                            }

                                            self.logout(complition: { (error) in
                                                if (nil != error) {
                                                    print(error ?? "Error - Intellignce Module : Failed to logout")
                                                    assert(true, "Error - Intellignce Module : Failed to logout")
                                                    handler(error)
                                                    return
                                                }

                                                self.shutDownIdentitModule(complition: { (error) in

                                                    if (nil == error) {

                                                        self.getUser(userId: user!.userId, complition: { (user, error) in

                                                            if (nil != error) {
                                                                print(error ?? "Error - Intellignce Module : Failed to logout")
                                                                assert(true, "Error - Intellignce Module : Failed to get user info")
                                                                handler(nil)
                                                                return
                                                            }

                                                            self.assisgn(role: 3492, user: user!, complition: { (_, error) in

                                                                if (nil != error) {
                                                                    handler(nil)
                                                                    return
                                                                } else {
                                                                    print(error ?? "Error - Intellignce Module : Shoudn't  assign role")
                                                                    assert(true, "Error - Intellignce Module : Shoudn't  assign role")
                                                                    let error = NSError(domain: "Intelligence.Shutdown.failed", code: 101, userInfo: nil)

                                                                    handler(error)
                                                                    return
                                                                }
                                                            })
                                                        })
                                                    } else {
                                                        print(error ?? "Error - Intellignce Module : Failed to shutdown")
                                                        assert(true, "Error - Intellignce Module : Failed to shutdown")
                                                        handler(error)
                                                        return
                                                    }
                                                })
                                            })
                                        })

                                    })
                                })

                            })

                        })
                    })
                })

            })
        }
    }

    /* functionality*/

    func startupIdentitModule(complition:@escaping(Bool)->Void) {

        IntelligenceManager.intelligence?.identity.startup(completion: { (status) in
            complition(status)
        })
    }

    func shutDownIdentitModule(complition:@escaping(NSError?)->Void) {

        IntelligenceManager.intelligence?.identity.shutdown()
        complition(nil)
    }

    func loginUser(complition: @escaping(Intelligence.User?, NSError?) -> Void) {

        IntelligenceManager.intelligence?.identity.getMe(callback: { (user, error) in

            let userName = user?.username
            let password = UserDefaults.standard.string(forKey: "Test_Password")

            self.loginUser(with: userName!, password: password!, callback: { (_, error) in

                guard let _ = error else {
                    print("Error")
                    return
                }
            })
        })
    }

    func getMe(complition: @escaping(Intelligence.User?, NSError?) -> Void) {
        IntelligenceManager.intelligence?.identity.getMe(callback: { (user, error) in
            complition(user, error)
        })
//        IntelligenceManager.intelligence?.identity.getCurrentSDKUser(callback: { (user, error) in
//            complition(user,error)
//        })
    }

    func getUser(userId: Int, complition: @escaping(Intelligence.User?, NSError?) -> Void) {

//        IntelligenceManager.intelligence?.identity.getUser(with: userId, callback: { (user, error) in
//            complition(user,error)
//        })
    }

    func updateUser(user: Intelligence.User, complition: @escaping(Intelligence.User?, NSError?) -> Void) {

//        user.firstName = "Test-FirstName"
//        user.lastName = "Test-lastName"
//        user.avatarURL = "http://google.com"
//        
//        IntelligenceManager.intelligence?.identity.update(user: user, callback: { (user, error) in
//            complition(user,error)
//        })
    }

    func assisgn(role: Int, user: Intelligence.User, complition:@escaping(Intelligence.User?, NSError?) -> Void) {

//        IntelligenceManager.intelligence?.identity.assignRole(to: role, user: user, callback: { (user, error) in
//            complition(user,error)
//        })
    }

    func revoke(role: Int, user: Intelligence.User, complition:@escaping(Intelligence.User?, NSError?) -> Void) {

//        IntelligenceManager.intelligence?.identity.revokeRole(with: role, user: user, callback: { (user, error) in
//            complition(user,error)
//        })
    }

    func logout(complition:@escaping(NSError?) -> Void) {
        IntelligenceManager.intelligence?.identity.logout()
        complition(nil)
    }

    func registerDevice(token: Data, complition:@escaping(Int, NSError?) -> Void) {
        IntelligenceManager.intelligence?.identity.registerDeviceToken(with: token, callback: { (connectionID, error) in
            complition(connectionID, error)
        })
    }

    func unRegisterDevice(tokenID: Int, complition:@escaping(NSError?) -> Void) {

        IntelligenceManager.intelligence?.identity.unregisterDeviceToken(with: tokenID, callback: { (_) in
            complition(nil)
        })
    }

}
