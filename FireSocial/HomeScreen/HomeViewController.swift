//
//  HomeViewController.swift
//  FireSocial
//
//  Created by Manu on 07/02/24.
//

import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let db = Firestore.firestore()
    var lastDocument: DocumentSnapshot?
    var isLoading = false
    var posts: [Post] = []{
        didSet{
            tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadNextPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNextPage()
    }
    
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    
    func loadNextPage() {
        
        guard !isLoading else { return }
        isLoading = true
        var query = db.collection("Post")
            .order(by: "creationDate", descending: true)
            .limit(to: 2)
        
        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }
        
        
        query.getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                self.isLoading = false
                return
            }
            
            guard let snapshot = snapshot else {
                print("Snapshot is nil")
                self.isLoading = false
                return
            }
            
            for document in snapshot.documents {
                // Decode document data to your Post model
                if let post = self.decodePost(from: document) {
                    self.posts.append(post)
                }
            }
            
            // Update last document for pagination
            if let lastSnapshot = snapshot.documents.last{
                self.lastDocument = lastSnapshot
            }
            
            self.isLoading = false
        }
    }
    
    
    func decodePost(from document: DocumentSnapshot) -> Post? {
        guard let data = document.data(),
              let id = data["id"] as? String,
              let imageURLs = data["imageURLs"] as? [String],
              let description = data["description"] as? String,
              let userId = data["userId"] as? String,
              let timestamp = data["creationDate"] as? Timestamp else {
            return nil
        }
        
        let post = Post(id: id,
                        imageURLs: imageURLs,
                        description: description,
                        userId: userId,
                        creationDate: timestamp.dateValue())
        print(post)
        return post
    }
    
    
    
}


extension HomeViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PostTableViewCell
        cell.configureCell(post: posts[indexPath.row])
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        if indexPath.row == lastRowIndex {
            loadNextPage()
        }
    }
}



