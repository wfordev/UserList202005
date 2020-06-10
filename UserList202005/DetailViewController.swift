//
//  DetailViewController.swift
//  UserList202005
//
//  Created by watabe on 2020/05/29.
//  Copyright © 2020 watabe. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, WKNavigationDelegate {

    @IBOutlet weak var followeeLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var userInfo:[String: Any] = [:]
    var moreUserInfo:[String: Any] = [:]
    var repos:[Any] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44;
        tableView.register(UINib(nibName: "DetailTableViewCell", bundle: nil), forCellReuseIdentifier: "repoCell")
        
        if let userID = userInfo["login"] as? String{
            userNameLabel.text = userID
        }
        if let iconImege = userInfo["iconimage"] as? UIImage{
            userIcon.image = iconImege
        }
        getMoreInfo()
    }
    
    func getMoreInfo(){
        if let userID = userInfo["login"] as? String{
            let userURL = "https://api.github.com/users/\(userID)"
            if let userInfo = URLSessionSet.getInfo(urlString: userURL, type: URLSessionSet.ReturnType.DICT){
                moreUserInfo = userInfo as!  [String: Any]
                setObjects()
                getRepoInfo()
            }
        }
    }
    
    func setObjects(){
        if let name = moreUserInfo["name"] as? String{
            fullnameLabel.text = name
        }
        if let followers_url = moreUserInfo["followers_url"] as? String{
            if let followers = URLSessionSet.getInfo(urlString: followers_url, type: URLSessionSet.ReturnType.ARRAY){
                let followersA = followers as! [Any]
                followerLabel.text = "\(followersA.count)"
            }
        }
        if var following_url = moreUserInfo["following_url"] as? String{
            if let range = following_url.range(of: "{/other_user}") {
                following_url.replaceSubrange(range, with: "")
                if let followees = URLSessionSet.getInfo(urlString: following_url, type: URLSessionSet.ReturnType.ARRAY){
                    let followeesA = followees as! [Any]
                    followeeLabel.text = "\(followeesA.count)"
                }
            }
        }
    }
    
    func getRepoInfo(){
        if let repos_url = moreUserInfo["repos_url"] as? String{
            if let reposA = URLSessionSet.getInfo(urlString: repos_url, type: URLSessionSet.ReturnType.ARRAY){
                let preRepos = reposA as! [Any]
                for preRepo in preRepos {
                    let repo = preRepo as! [String:Any]
                    if let fork = repo["fork"]{
                        if fork as! Bool == false {
                            repos.append(repo)
                        }
                    }
                }
                tableView.reloadData()
            }
        }
    }
    
    //MARK:- TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repos.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repoInfo = repos[indexPath.row] as! [String: Any]
        let repoCell = tableView.dequeueReusableCell(withIdentifier: "repoCell", for: indexPath) as! DetailTableViewCell
    
        if let name = repoInfo["name"] as? String{
            repoCell.titleLabel.text = name
        }
        if let description = repoInfo["description"] as? String{
            repoCell.descLabel.text = description
        }
        if let stargazers_count = repoInfo["stargazers_count"] as? Int{
            repoCell.starNoLabel.text = "\(stargazers_count)"
        }
        if let language = repoInfo["language"] as? String{
            repoCell.langLabel.text = language
        }
        return repoCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let repoInfo = repos[indexPath.row] as! [String: Any]
        if let html_url = repoInfo["html_url"] as? String{
            showWebView(urlString: html_url)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func showWebView(urlString:String){
        let browserVc = BrowserViewController.init(withURLString: urlString, Name: "BrowserViewController", bundle: nil)
        let pc = browserVc.popoverPresentationController
        pc?.delegate = self;
        pc?.sourceView = self.view
        pc?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        present(browserVc, animated: true, completion: nil)

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

  
