//
//  FeedViewController.swift
//  Instagram
//
//  Created by Aryan Khadiri on 3/19/20.
//  Copyright © 2020 AryanKhadiri@gmail.com. All rights reserved.
//

import UIKit
import Parse
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var posts = [PFObject]()
    
    func takingQuery(){
        let query = PFQuery(className: "Post")
        query.includeKeys(["author","comments","comments.author"])
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
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    override var canBecomeFirstResponder: Bool{
        return true
    }

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        //whatever is on the left of ?? is going to be whatever is on the right which is in this
        //case an empty array.
        
        return comments.count + 2 //gives us rows for the post itself or for the
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count //create a section for each post
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"]) as? [PFObject] ?? []
        if indexPath.row == 0 {
            //if it is the first row of the section, we return the cell for the actual post
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! postCell
            let user = post["author"] as! PFUser
            
            cell.usernameLabel.text = user.username as? String
            cell.captionLabel.text = post["caption"] as! String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!

            let data = try?Data(contentsOf: url)
            cell.postView?.image = UIImage(data: data!)
            //cell.postView?.af.setImage(withURL: url)
            
            return cell
        }
        else if indexPath.row <= comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentTableViewCell
            let comment = comments[indexPath.row - 1]
            let user = comment["author"] as! PFUser
            cell.commentLabel.text = comment["text"] as? String
            cell.userLabel.text = user.username
            
            return cell
        }
        else{
            
        }
        
    }
    
    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        let sDelegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        sDelegate.window?.rootViewController = loginViewController
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        
        let comment = PFObject(className: "comment")
        comment["text"] = "This is a random Comment"
        comment["post"] = post
        comment["author"] = PFUser.current()
        
        post.add(comment, forKey: "comments") //every row of post has a column comments which points to the comment table
        post.saveInBackground { (success, error) in
            if success{
                print("Comment Saved!")
            
            
            }
            else{
                print("There was an error saving the comment: \(error)")
                
            }
        }
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
