//
//  ViewController.swift
//  LacrasteCloud
//
//  Created by Giovani Bettoni on 06/21/2022.
//  Copyright (c) 2022 Giovani Bettoni. All rights reserved.
//

import UIKit
import CloudKit
import LacrasteCloud

@available(iOS 11.0, *)
class MainViewController: UITableViewController {

    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPosts()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        refreshTable()
        //fetchPosts()
    }
    
    func refreshTable() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    @objc func refreshList() {
        fetchPosts()
    }
    
    private func fetchPosts() {
        Storage.getAll(storageType: .privateStorage(customContainer: "iCloud.org.cocoapods.demo.LacrasteCloud-Example"), { (result: Result<[Post], Error>) in
            switch result {
            case .success(let posts):
                self.posts = posts
                
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    /// Case updated by pull-refresh
                    self.tableView.reloadData()
                }
            case .failure(let failure):
                self.showErrorAlert(failure.localizedDescription)
            }
        })
    }
    
    private func completePost(withId id: String) {
        Storage.remove(id) { result in
            
            switch result {
            case .success(_):
                break
            case.failure(let error):
                self.showErrorAlert(error.localizedDescription)
                self.fetchPosts()
            }
        }
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let postViewController = segue.destination as? PostViewController
        else { return }
        
        if segue.identifier == "editPost" {
            guard let post = sender as? Post
            else { return }
            postViewController.post = post
        }
    }
    
    
    // MARK: - TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = post.name
        cell.detailTextLabel?.text = post.simpleDescription
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let complete = UIContextualAction(style: .normal, title: "Complete", handler: { (action, view, completionHandler) in
            
            guard let id = self.posts[indexPath.row].recordName
            else { return }
            
            self.posts = self.posts.filter({ $0.recordName != id })
            
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.completePost(withId: id)
            
            completionHandler(true)
        })
        complete.backgroundColor = UIColor.systemGreen
        
        let edit = UIContextualAction(style: .normal, title: "Edit", handler: {
            (action, view, completionHandler) in
            
            self.performSegue(withIdentifier: "editPost", sender: self.posts[indexPath.row])
            
            completionHandler(true)
        })
        edit.backgroundColor = UIColor.systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [complete, edit])
        return configuration
    }

}

