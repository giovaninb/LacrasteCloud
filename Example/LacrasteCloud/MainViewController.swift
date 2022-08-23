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

    var postsList: [Post] = []
    var pageFetcher: PageFetcher<Post>?
    let numberOfRecords: Int = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        self.resetTableView()
        self.getPosts()
    }

    override func viewWillAppear(_ animated: Bool) {
        refreshTable()
    }
    
    func refreshTable() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        self.refreshControl = refreshControl
    }

    func reloadTableView() {
        self.tableView.reloadData()
    }

    func resetNumberOfPosts() {
        self.pageFetcher = nil
        self.postsList = []
    }

    func fetchPostsList() {
        print(">>> before: \(self.numberOfRecords)")
        if pageFetcher != nil || postsList.isEmpty {
            fetchPosts(numberOfRecords: self.numberOfRecords)
            print(">> after: \(self.numberOfRecords)")
        }
    }

    @objc func refreshList() {
        self.resetTableView()
        self.getPosts()
    }

    private func getPosts() {
        self.resetNumberOfPosts()
        self.reloadTableView()
        self.fetchPostsList()
    }
    
    private func fetchPosts(numberOfRecords: Int) {
        if let pageFetcher = pageFetcher {
            pageFetcher.fetchPage(onPageFetched(result:))
        } else {
            Lacraste.getAllPaginatedAndSorted(storageType: .publicStorage(customContainer: "iCloud.org.cocoapods.demo.LacrasteCloud-Example"), type: Post.self, numberOfRecords: numberOfRecords, onPageFetched(result:))
        }
    }

    private func onPageFetched(result: Result<(elements: [Post], moreRecords: PageFetcher<Post>?), Error>) {
        switch result {
        case .success((let posts, let nextPageFetcher)):
            //self.postsList = posts
            self.pageFetcher = nextPageFetcher
            self.postsList.append(contentsOf: posts)

            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                /// Case updated by pull-refresh
                self.reloadTableView()
            }
        case .failure(let failure):
            self.showErrorAlert(failure.localizedDescription)
        }
    }
    
    private func deletePost(withId id: String) {
        Lacraste.remove(storageType: .publicStorage(customContainer: "iCloud.org.cocoapods.demo.LacrasteCloud-Example"), id) { result in
            switch result {
            case .success(_):
                break
            case.failure(let error):
                self.showErrorAlert(error.localizedDescription)
                self.fetchPosts(numberOfRecords: self.numberOfRecords)
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
        return postsList.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = postsList[indexPath.row]
        
        let identifier = "MainTableViewCell"
        guard let customCell = self.tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? MainTableViewCell
        else {
            fatalError("There should be a cell with \(identifier) identifier.")
        }
        customCell.post = post
        customCell.setupData()
        return customCell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "Delete", handler: { (action, view, completionHandler) in
            
            guard let id = self.postsList[indexPath.row].recordName
            else { return }
            
            self.postsList = self.postsList.filter({ $0.recordName != id })
            
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.deletePost(withId: id)
            
            completionHandler(true)
        })
        delete.backgroundColor = UIColor.systemRed
        
        let edit = UIContextualAction(style: .normal, title: "Edit", handler: {
            (action, view, completionHandler) in
            
            self.performSegue(withIdentifier: "editPost", sender: self.postsList[indexPath.row])
            
            completionHandler(true)
        })
        edit.backgroundColor = UIColor.systemGreen
        
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit", handler: {
            (action, view, completionHandler) in
            
            self.performSegue(withIdentifier: "editPost", sender: self.postsList[indexPath.row])
            
            completionHandler(true)
        })
        edit.backgroundColor = UIColor.systemGreen
        
        let configuration = UISwipeActionsConfiguration(actions: [edit])
        return configuration
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        let lastElement = postsList.count
        print(">>>>>>> le \(lastElement)")

        if indexPath.row == lastElement - 3 {
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50)
            self.tableView.tableFooterView = spinner
            self.tableView.tableFooterView?.isHidden = false
            self.fetchPostsList()
        }

        if self.pageFetcher == nil {
            self.tableView.tableFooterView = nil
        }
    }

    func resetTableView() {
        self.tableView.tableFooterView = nil
    }
    

}

