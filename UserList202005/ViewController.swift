//
//  ViewController.swift
//  UserList202005
//
//  Created by watabe on 2020/05/29.
//  Copyright © 2020 watabe. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var testImage: UIImageView!
    let refreshControl:UIRefreshControl = UIRefreshControl()
    
    var since = 0;
    var userArray:[Any] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44;
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "userCell")
        
        refreshControl.addTarget(self, action: #selector(onRefresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        coverView.isHidden = false
        getUsersArray(isAdd: false)
//        getUsers(){result in
//            if let result = result{
//                self.getIconsProcess(array: result)
//            }
////            DispatchQueue.main.sync {
////
////            }
//        }
    }
    @objc func onRefresh(_ sender:UIRefreshControl){
        refreshControl.beginRefreshing()
        getUsersArray(isAdd: true)
        refreshControl.endRefreshing()
    }
    
    func getUsersArray(isAdd:Bool){
        let beforeArray = userArray
        let urlString = "https://api.github.com/users?since=\(since)&per_page=10"
        if let usersA = URLSessionSet.getInfo(urlString: urlString, type: URLSessionSet.ReturnType.ARRAY){
            let preUsers = usersA as! [Any]
                if preUsers.count>0 {
                    if isAdd {
                        userArray = beforeArray + preUsers
                    }else{
                        userArray = preUsers
                    }
                    let dict = userArray.last as! [String: Any]
                    self.since = dict["id"] as! Int
                }
                getIcons()
            }
    }
    
    func getIcons(){
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        var resultArray:Array<Any> = []
        
        for info in userArray{
            dispatchGroup.enter()
            dispatchQueue.async(group: dispatchGroup) {
                var minfo = info as! [String: Any]
                if (minfo["iconimage"] as? UIImage) == nil{
                    if let userID = minfo["login"] as? String{
                        let urlString = "https://github.com/\(userID).png"
                        if let preImage = URLSessionSet.getInfo(urlString: urlString, type: URLSessionSet.ReturnType.IMAGE){
                            let image = preImage as! UIImage
                            minfo["iconimage"] = image
                        }
                    }
                }else{
                    print("already")
                }
                resultArray.append(minfo)
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            print("All Process Done!")
            self.userArray = resultArray
            self.tableView.reloadData()
            self.coverView.isHidden = true
        }
    }
    
    //MARK:- TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userInfo = userArray[indexPath.row] as! [String: Any]
        let userCell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserTableViewCell
        if let userID = userInfo["login"] as? String{
            userCell.userNameLabel.text = userID
        }
        if let iconImege = userInfo["iconimage"] as? UIImage{
            userCell.userIcon.image = iconImege
        }
        return userCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetail", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if ( segue.identifier == "toDetail" ) {
            let row = tableView.indexPathForSelectedRow?.row
            let userInfo = userArray[row!]
            let detailView = segue.destination as! DetailViewController
            detailView.userInfo = userInfo as! [String:Any]
        }
    }
}

//    func getUsers(completion: ((Array<Any>?) -> Void)?) {
//        var resultArray:Array<Any> = []
//        let urlString = "https://api.github.com/users?since=\(since)&per_page=3"
//        //urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)!
//        let request = NSMutableURLRequest(url: URL(string: urlString)!)
//        request.httpMethod = "GET"
//        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
//        let task = URLSession.shared.dataTask(with: request as URLRequest) {
//            data, response, error in
//            if error != nil {
//                print("error=\(String(describing: error))")
//                return
//            }
//            do {
//                let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [Any]
//                if json.count>0 {
//                    resultArray = json
//                    let dict = json.last as! [String: Any]
//                    self.since = dict["id"] as! Int
//                    completion?(resultArray)
//                }
//            }catch{
//                print(error)
//            }
//        }
//        task.resume()
//    }
        
//    func getIconsProcess(array:Array<Any>) {
//        let dispatchGroup = DispatchGroup()
//        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
//        var resultArray:Array<Any> = []
//
//        for info in array{
//            var minfo = info as! [String: Any]
//            if let userID = minfo["login"] as? String{
//                dispatchGroup.enter()
//                dispatchQueue.async(group: dispatchGroup) {
//                    [weak self] in
//                    self?.getIcon(userID: userID){img in
//                        minfo["iconimage"] = img
//                        print("#\(userID) End")
//                        resultArray.append(minfo)
//                        dispatchGroup.leave()
//                    }
//                }
//            }
//        }
//        dispatchGroup.notify(queue: .main) {
//            print("All Process Done!")
//            self.userArray = resultArray
//            self.tableView.reloadData()
//            self.coverView.isHidden = true
//        }
//    }

    // 非同期処理
//    func getIcon(userID: String, completion: ((UIImage?) -> Void)?) {
//        print("#\(userID) Start")
//        sleep((arc4random() % 100 + 1) / 100)
//        let urlString = "https://github.com/\(userID).png"
//        let request = NSMutableURLRequest(url: URL(string: urlString)!)
//        request.httpMethod = "GET"
//        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
//        let task = URLSession.shared.dataTask(with: request as URLRequest) {
//            data, response, error in
//            if error != nil {
//                print("error=\(String(describing: error))")
//                return
//            }
//            if let image = UIImage(data: data!){
//                print("geticon...image is")
//                completion?(image)
//            }else{
//                print("geticon...image isn't")
//                let demoImage = UIImage()
//                completion?(demoImage)
//            }
//        }
//        task.resume()
//    }
