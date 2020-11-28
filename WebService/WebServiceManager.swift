//
//  WebServiceClass.swift
//  Link
//
//  Created by MINDIII on 10/3/17.
//  Copyright © 2017 MINDIII. All rights reserved.

// MARK: - Required things
//  install Alamofire with cocoapods * pod 'Alamofire'
//  install SwiftyJSON with cocoapods * pod 'SwiftyJSON'


import UIKit
import Alamofire
import SwiftyJSON
import KRProgressHUD
import KRActivityIndicatorView
import SVProgressHUD

var  strAuthToken : String = ""

class WebServiceManager: NSObject {
    
    //MARK: - Shared object
    
    private static var sharedNetworkManager: WebServiceManager = {
       
        let networkManager = WebServiceManager()
        return networkManager
    }()
    // MARK: - Accessors
    class func sharedObject() -> WebServiceManager {
        return sharedNetworkManager
    }
    
    func showAlert(message: String = "", title: String , controller: UIWindow) {
        DispatchQueue.main.async(execute: {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let subView = alertController.view.subviews.first!
            let alertContentView = subView.subviews.first!
            alertContentView.backgroundColor = UIColor.gray
            alertContentView.layer.cornerRadius = 20
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(OKAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        })
    }
    
    /*public func requestFor(strURL:String, methodType: HTTPMethod, params : [String:Any]?, success:@escaping(JSON) ->Void, failure:@escaping (Error) ->Void ) {*/
    
    public func requestPost(strURL:String, params : [String:Any]?, success:@escaping(Dictionary<String,Any>) ->Void, failure:@escaping (Error) ->Void ) {
        
        if !NetworkReachabilityManager()!.isReachable{
            let app = UIApplication.shared.delegate as? AppDelegate
            let window = app?.window
            showAlert(message: "", title: NoNetwork ,controller: window!)
            DispatchQueue.main.async {
                self.StopIndicator()
            }
            return
        }
        if UserDefaults.standard.string(forKey:kAuthToken)==nil {
            strAuthToken=""
        }else{
            strAuthToken=UserDefaults.standard.string(forKey:kAuthToken)!
        }
        //let url = BaseURL + strURL
        //let headers = ["authToken":strAuthToken,"Content-Type":"application/json","Accept":"application/json"]
        let headers = ["authToken":strAuthToken]
       
        //Alamofire.request(strURL, method: .post, parameters: params, headers: headers).responseJSON { responseObject in
        Alamofire.request(strURL, method: .post, parameters: params, headers: headers).responseJSON { responseObject in
            if             !objAppShareData.isNormalRegistration {
                self.StopIndicator()
                objAppShareData.isNormalRegistration = false
            }
            if responseObject.result.isSuccess {

                do {
                    // Sometimes crash
                                let dictionary = try JSONSerialization.jsonObject(with: responseObject.data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                                success(dictionary as! Dictionary<String, Any>)
                                print(dictionary)
                            }catch{
                            
                                let error : Error = responseObject.result.error!
                                failure(error)
                                let str = String(decoding:  responseObject.data!, as: UTF8.self)
                                print("PHP ERROR : \(str)")
                }
                        }
                        if responseObject.result.isFailure {
                            self.StopIndicator()
                            let error : Error = responseObject.result.error!
                            failure(error)
                            
                            let str = String(decoding:  responseObject.data!, as: UTF8.self)
                            print("PHP ERROR : \(str)")
                        }
                }
    }
    
    public func requestGet(strURL:String, params : [String : AnyObject]?, success:@escaping(Dictionary<String,Any>) ->Void, failure:@escaping (Error) ->Void ) {
        if !NetworkReachabilityManager()!.isReachable{
            let app = UIApplication.shared.delegate as? AppDelegate
            let window = app?.window
            showAlert(message: "", title: NoNetwork , controller: window!)
            DispatchQueue.main.async {
                self.StopIndicator()
            }
            return
        }
        
        if UserDefaults.standard.string(forKey:kAuthToken)==nil {
            strAuthToken=""
        }else{
            strAuthToken=UserDefaults.standard.string(forKey:kAuthToken)!
        }
        
        //let url = BaseURL + strURL
        //let headers = ["authToken" : strAuthToken]
        //                      "Content-Type":"Application/json"]
        Alamofire.request(strURL, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { responseObject in
           
            self.StopIndicator()

            if responseObject.result.isSuccess {
//                let resJson = JSON(responseObject.result.value!)
//                success(resJson)
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: responseObject.data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    success(dictionary as! Dictionary<String, Any>)
                    print(dictionary)
                }catch{
                    
                    let error : Error = responseObject.result.error!
                    failure(error)
                    let str = String(decoding:  responseObject.data!, as: UTF8.self)
                    print("PHP ERROR : \(str)")
                }
            }
            if responseObject.result.isFailure {
                self.StopIndicator()
                let error : Error = responseObject.result.error!
                failure(error)
                
                let str = String(decoding:  responseObject.data!, as: UTF8.self)
                print("PHP ERROR : \(str)")
            }
        }
    }
    
    public func requestPut(strURL:String, params : [String:Any]?, success:@escaping(Dictionary<String,Any>) ->Void, failure:@escaping (Error) ->Void ) {
        if !NetworkReachabilityManager()!.isReachable{
           
            let app = UIApplication.shared.delegate as? AppDelegate
            let window = app?.window
            showAlert(message: "", title: NoNetwork ,controller: window!)
             self.StopIndicator()
            return
        }
        if UserDefaults.standard.string(forKey:kAuthToken)==nil {
            strAuthToken=""
        }else{
            strAuthToken=UserDefaults.standard.string(forKey:kAuthToken)!
        }
        // let url = BaseURL + strURL
        let headers = ["authToken" : strAuthToken]
        
       //Alamofire.request(strURL, method: .put, parameters: params, headers: headers).responseJSON
        
        Alamofire.request(strURL, method: .put, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON  { responseObject in
            if !objAppShareData.isPutApiFromUpload{
               self.StopIndicator()
            }
            if responseObject.result.isSuccess {
                
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: responseObject.data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    success(dictionary as! Dictionary<String, Any>)
                    print(dictionary)
                }catch{
                    
                }
            }
            if responseObject.result.isFailure {
                self.StopIndicator()
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    
    // method foer json
    public func requestWithJson(strURL:String, params : [String : AnyObject]?, success:@escaping(Dictionary<String,Any>) ->Void, failure:@escaping (Error) ->Void ) {
        if !NetworkReachabilityManager()!.isReachable{
            
            let app = UIApplication.shared.delegate as? AppDelegate
            let window = app?.window
            showAlert(message: "", title: NoNetwork , controller: window!)
            DispatchQueue.main.async {
                self.StopIndicator()
            }
            return
        }
        
        if UserDefaults.standard.string(forKey:kAuthToken)==nil {
            strAuthToken=""
        }else{
            strAuthToken=UserDefaults.standard.string(forKey:kAuthToken)!
        }
        
        //let url = BaseURL + strURL
        let headers = ["authToken" : strAuthToken]
        //                      "Content-Type":"Application/json"]
        Alamofire.request(strURL, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { responseObject in
            
            self.StopIndicator()
            
            if responseObject.result.isSuccess {
                //                let resJson = JSON(responseObject.result.value!)
                //                success(resJson)
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: responseObject.data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    success(dictionary as! Dictionary<String, Any>)
                    print(dictionary)
                }catch{
                    
                    let error : Error = responseObject.result.error!
                    failure(error)
                    let str = String(decoding:  responseObject.data!, as: UTF8.self)
                    print("PHP ERROR : \(str)")
                }
            }
            if responseObject.result.isFailure {
                self.StopIndicator()
                let error : Error = responseObject.result.error!
                failure(error)
                
                let str = String(decoding:  responseObject.data!, as: UTF8.self)
                print("PHP ERROR : \(str)")
            }
        }
    }
    public func uploadMultipartData(strURL:String, params : [String : AnyObject]?, imageData:Data, fileName:String, mimeType:String, success:@escaping(Dictionary<String,Any>) ->Void, failure:@escaping (Error) ->Void){
        
        if !NetworkReachabilityManager()!.isReachable{
          
            let app = UIApplication.shared.delegate as? AppDelegate
            let window = app?.window
            showAlert(message: "", title: NoNetwork , controller: window!)
            DispatchQueue.main.async {
                self.StopIndicator()
            }
            return
        }
        if UserDefaults.standard.string(forKey:kAuthToken)==nil {
            strAuthToken=""
        }else{
            strAuthToken=UserDefaults.standard.string(forKey:kAuthToken)!
        }
        //let url = BaseURL + strURL
        let headers = ["authToken" : strAuthToken]
        //                      "Content-Type":"Application/json"]        
        Alamofire.upload(multipartFormData:{ multipartFormData in
            multipartFormData.append(imageData,
                                     withName:fileName,
                                     fileName:"file.png",
                                     mimeType:mimeType)
            for (key, value) in params! {
                multipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }},
                         usingThreshold:UInt64.init(),
                         to:strURL,
                         method:.post,
                         headers:headers,
                         encodingCompletion: { encodingResult in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { responseObject in
                                    self.StopIndicator()
                                    if responseObject.result.isSuccess {
//                                        let resJson = JSON(responseObject.result.value!)
//                                        success(resJson)
                                        do {
                                            let dictionary = try JSONSerialization.jsonObject(with: responseObject.data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                                            success(dictionary as! Dictionary<String, Any>)
                                            print(dictionary)
                                        }catch{
                                        }
                                    }
                                    if responseObject.result.isFailure {
                                        let error : Error = responseObject.result.error!
                                        self.StopIndicator()
                                        failure(error)
                                    }
                                }
                            case .failure(let encodingError):
                                print(encodingError)
                                self.StopIndicator()
                                failure(encodingError)
                            }
        })
    }
    
    public func requestFor(strURL:String, methodType: HTTPMethod, params : [String:Any]?, success:@escaping(JSON) ->Void, failure:@escaping (Error) ->Void ) {

        if !NetworkReachabilityManager()!.isReachable{
            
            let app = UIApplication.shared.delegate as? AppDelegate
            let window = app?.window
            showAlert(message: "", title: NoNetwork ,controller: window!)
            DispatchQueue.main.async {
                self.StopIndicator()
            }
            return
        }

        if let token = UserDefaults.standard.string(forKey:kAuthToken){
            strAuthToken = token
        }else{
            strAuthToken = ""
        }
        // let url = BaseURL + strURL
        let headers = ["authToken" : strAuthToken]
      // let headers = ["authToken" : strAuthToken, "Content-Type" : ["text/html", "application/json"]] as! [String : Any]
        Alamofire.request(strURL, method: methodType, parameters: params, headers: headers).responseJSON { responseObject in

            self.StopIndicator()
            if responseObject.result.isSuccess {
                    let json = JSON(responseObject)
                    print(json)
                    success(json)
            }else{
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    
    
    func StartIndicator(){
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        SVProgressHUD.show()
        //KRProgressHUD.show()
    }
    
    func StopIndicator(){
        
        UIApplication.shared.endIgnoringInteractionEvents()
        SVProgressHUD.dismiss()
        //KRProgressHUD.dismiss()
    }
//    // vinod
    public func requestPostForArray(strURL:String, params : [String:Any]?, success:@escaping(NSArray) ->Void, failure:@escaping (Error) ->Void ) {
        if !NetworkReachabilityManager()!.isReachable{
            
            let app = UIApplication.shared.delegate as? AppDelegate
            let window = app?.window
            showAlert(message: "", title: NoNetwork ,controller: window!)
            DispatchQueue.main.async {
                self.StopIndicator()
            }
            return
        }
        if UserDefaults.standard.string(forKey:kAuthToken)==nil {
            strAuthToken=""
        }else{
            strAuthToken=UserDefaults.standard.string(forKey:kAuthToken)!
        }
        // let url = BaseURL + strURL
        let headers = ["authToken" : strAuthToken]
        
        Alamofire.request(strURL, method: .post, parameters: params, headers: headers).responseJSON { responseObject in
            self.StopIndicator()
            if responseObject.result.isSuccess {
                
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: responseObject.data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray
                    success(dictionary )
                    print(dictionary)
                }catch{
                    
                }
            }
            if responseObject.result.isFailure {
                self.StopIndicator()
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    
}
