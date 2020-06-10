//
//  URLSessionSet.swift
//  UserList202005
//
//  Created by watabe on 2020/06/04.
//  Copyright © 2020 watabe. All rights reserved.
//

import UIKit

class URLSessionSet: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate{
    var semaphore:DispatchSemaphore = DispatchSemaphore(value:0)
    var error:Error!
    var responseData:Data = Data()
    var response:URLResponse!
    static let token = "1076288fad0e115e63baa3ebc7b37969dce03dba"
    
    enum ReturnType:Int{
        case IMAGE, ARRAY, DICT
    }
    
    override init(){
        super.init()
    }
    
    class func getInfo(urlString:String, type:ReturnType) -> Any?{
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("token " + token, forHTTPHeaderField: "Authorization")
        var response:URLResponse!
        var error:Error!
        var json:Any?
        let data = URLSessionSet.sendRequest(request: request as URLRequest, response: &response, error: &error)
        do {
            switch type {
            case .IMAGE:
                if let image = UIImage(data: data){
                    json = image
                }else{
                    let demoImage = UIImage()
                    json = demoImage
                }
            case.ARRAY:
                json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [Any]
            case.DICT:
                json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
            default: break
            }
        }catch{
            print(error)
        }
        return json
    }
    
   class func sendRequest(request:URLRequest, response:inout URLResponse!, error:inout Error!) -> Data {
        let urlSessionSet = URLSessionSet()
        OperationQueue().addOperation {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: urlSessionSet, delegateQueue: OperationQueue.current)
            let task = session.dataTask(with: request)
            task.resume()
        }
        while (urlSessionSet.semaphore.wait(timeout:.now() + 0.1) == .timedOut) {
            RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.01))
        }
    
        if (error != nil && urlSessionSet.error != nil){
            error = urlSessionSet.error
        }
        if(response != nil && urlSessionSet.response != nil){
            response = urlSessionSet.response
        }
        return urlSessionSet.responseData
    }
    

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.response = response
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.responseData.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if(error != nil){
            self.error = error
        }
        session.invalidateAndCancel()
        semaphore.signal()
    }
}
