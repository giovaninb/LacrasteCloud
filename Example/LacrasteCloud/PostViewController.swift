//
//  PostViewController.swift
//  LacrasteCloud_Example
//
//  Created by Giovani Nícolas Bettoni on 04/07/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import CloudKit
import LacrasteCloud

class PostViewController: UIViewController {

    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var saveActivityIndicator: UIActivityIndicatorView!
    
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillFieldsIfNeeded()
    }
    
    private func fillFieldsIfNeeded() {
        guard let post = post
        else { return }
        
        txtName.text = post.name
        txtDescription.text = post.simpleDescription
    }
    
    private func createPost(name: String, description: String?) {
        let newPost = Post(name: name, simpleDescription: description)
        
        saveActivityIndicator.isHidden = false
        Storage.create(newPost) { result in
            DispatchQueue.main.async {
                self.saveActivityIndicator.isHidden = true
            }
            
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                self.showErrorAlert(error.localizedDescription)
            }
        }
    }
    
    private func updatePost(_ post: Post, name: String, description: String?) {
        var postToUpdate = post
        postToUpdate.name = name
        postToUpdate.simpleDescription = description
        
        saveActivityIndicator.isHidden = false
        Storage.update(postToUpdate) { result in
            DispatchQueue.main.async {
                self.saveActivityIndicator.isHidden = true
            }
            
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                self.showErrorAlert(error.localizedDescription)
            }
        }
    }
    
    private func savePost() {
        guard let name = txtName.text, name.count > 0
        else {
            showErrorAlert("The Post must have a name")
            return
        }
        
        let description = txtDescription.text
        
        if let post = post {
            updatePost(post, name: name, description: description)
        } else {
            createPost(name: name, description: description)
        }
    }
    
    @IBAction func savePostBtn(_ sender: Any) {
        savePost()
    }

}
