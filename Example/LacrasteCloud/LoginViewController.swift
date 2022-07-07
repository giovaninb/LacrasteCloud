//
//  LoginViewController.swift
//  LacrasteCloud_Example
//
//  Created by Giovani Nícolas Bettoni on 07/07/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import CloudKit
import LacrasteCloud
import AuthenticationServices

class LoginViewController: UIViewController {

    var isSignedInToiCloud: Bool = false
    var error: String = ""
    
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblError: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserStatus()
    }
    
    func loadData() {
        lblStatus.text = "IS SIGNED IN: \(isSignedInToiCloud)"
        lblError.text = error
        if isSignedInToiCloud != false {
            lblError.isHidden = true
        }
    }
    
    private func fetchUserStatus() {
        CKContainer.default().accountStatus { [weak self] returnedStatus, returnedError in
            DispatchQueue.main.async {
                switch returnedStatus {
                case .available:
                    self?.isSignedInToiCloud = true
                case .couldNotDetermine:
                    self?.error = CloudKitError.iCloudAccountNotDetermined.rawValue
                case .restricted:
                    self?.error = CloudKitError.iCloudAccountRestricted.rawValue
                case .noAccount:
                    self?.error = CloudKitError.iCloudAccountNotFound.rawValue
                case .temporarilyUnavailable:
                    self?.error = CloudKitError.iCloudAccountTemporarilyUnavailable.rawValue
                default:
                    self?.error = CloudKitError.iCloudAccountUnknown.rawValue
                }
                self?.loadData()
            }
        }
    }
    
    enum CloudKitError: String, LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountTemporarilyUnavailable
        case iCloudAccountUnknown
    }
    
    @IBAction func handleAuthorizationAppleIDButtonPress(_ sender: Any) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.performRequests()
    }
    
    @IBAction func guestUser(_ sender: Any) {
        guard let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController
        else { return }
        self.navigationController?.pushViewController(mainVC, animated: true)
    }
    
}
