//
//  FeedViewController.swift
//  Instagram
//
//  Created by Aryan Khadiri on 3/19/20.
//  Copyright © 2020 AryanKhadiri@gmail.com. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var posts = [PFObject]()
    
    func takingQuery(){
        let query = PFQuery(className: "Post")
        query.includeKey("author")
        query.limit = 20
        query.findObjectsInBackground { ( posts, error) in
            if posts != nil{
                print("successfully loaded")
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        takingQuery()
    }
    

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! postCell
        let user = post["author"] as! PFUser
        
        cell.usernameLabel.text = user.username as? String
        cell.captionLabel.text = post["caption"] as! String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.postView?.af.setImage(withURL: url)
        
        return cell
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
