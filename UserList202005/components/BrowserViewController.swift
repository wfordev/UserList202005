//
//  BrowserViewController.swift
//  UserList202005
//
//  Created by watabe on 2020/06/10.
//  Copyright © 2020 watabe. All rights reserved.
//

import UIKit
import WebKit
class BrowserViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var urlString = ""
//    init(requsetSting:String){
//        //selfを呼ぶには、その前にsuper.init()を呼ぶ必要がある
//        //が、super.init()を呼ぶなら、それ以前にpropertyを初期化する必要がある
//        //なので変数宣言のところで既に初期化している
//        super.init()
//
//
//    }
    init(withURLString urlStr: String?, Name nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        if let urlStr = urlStr {
            self.urlString = urlStr
        }
        
//        if let url = url {
//
//
//            //webView.load(URLRequest(url: url))
//            webView.load(urlreq)
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlreq = URLRequest(url: URL(string:urlString)!)
        self.webView.load(urlreq)
        // Do any additional setup after loading the view.
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
