//-------------------------------------------------------------------------------------------------
//  File Name		:	DLNetworkingManager
//  Description		:   This class manages all network calls to the server through bewlow methods.
//                  :   (1) dlLibInitiateAsyncGetRequest    - GET <HTTPMethod>
//                  :   (2) dlLibInitiateAsyncPOSTRequest   - POST <HTTPMethod>
//  Author			:	Rathish Kannan
//	E-mail			:	rathish_citys@eres.ae
//	Dated			:	11th March 2017
//
//  Copyright (c) 2017 ERES. All rights reserved.
//-------------------------------------------------------------------------------------------------


import Foundation


@objc public protocol DLNetworkingManagerDelegate {
    
    // MARK: Err Delegate
    
    /*!
     *	breif	:	service called has returned with failure
     *	param	:	[in] - NSError*     , error info return by the service
     *           :	[in] - NSString*    , message associated with the error
     *  retun    :   void
     *  dated    :   16th Apr 2017
     *  author   :   rathish_citys@eres.com
     */
    
    func syncServiceFailedWithError (_ dataResponse:NSDictionary, tag:NSInteger)
    
    // MARK: Success Delegate
    
    /*!
     *	breif	:	service called has returned with image byte data
     *	param	:	[in] NSDictionary * - response dict.
     *           :   [in] NSInteger  - tag value
     *  retun    :   void
     *  dated    :   16th Apr 2017
     *  author   :   rathish_citys@eres.com
     */
    
    func syncServiceFinished (_ dataResponse: NSDictionary, tag:NSInteger)
}


public class DLNetworkingManager :NSObject, URLSessionDelegate {
    
    public var  delegate: DLNetworkingManagerDelegate?
    
    
    // MARK: dlLibInitiateAsyncGetRequest
    
    /// dlLibInitiateAsyncGetRequest
    ///
    /// - Parameters:
    ///   - urlStr: String API Req - URL
    ///   - type: DLRequestType - enum for type of request(ex: html, pdf, etc...)
    ///   - tag: Int - Unique identity
    ///   - author : rathish_citys@eres.ae
    
    public  func dlLibInitiateAsyncGetRequest(urlStr:String, type:DLNetworkingTypes.RequestType, tag:Int) {
        
        print("GET URL SENT = \(urlStr)")
        
        let request = NSMutableURLRequest(url: URL(string: urlStr)!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 20.0)
        request.httpMethod = "GET"
        
        switch type {
        case DLNetworkingTypes.RequestType.RequestTypeImage:
            request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
            break
        case DLNetworkingTypes.RequestType.RequestTypeHTML:
            request.addValue("text/html", forHTTPHeaderField: "Content-Type")
            break
        case DLNetworkingTypes.RequestType.RequestTypePDF:
            request.addValue("application/pdf", forHTTPHeaderField: "Content-Type")
            break
        case DLNetworkingTypes.RequestType.RequestTypeDefault:
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            break
        }
        
        let defaultConfigObject =  URLSessionConfiguration.default
        let defaultSession =  URLSession.init(configuration: defaultConfigObject, delegate: self, delegateQueue: OperationQueue.main)
        let url  = URL.init(string: urlStr)
        
        let reachability = Reachability()!
        reachability.whenReachable = { reachability in
            
            DispatchQueue.main.async {
                let task = defaultSession.dataTask(with: URLRequest.init(url: url!), completionHandler: { (data, response, error) in
                    
                    var dataStr = String()
                    
                    if (data != nil){
                        dataStr = String.init(data: data!, encoding: String.Encoding.utf8)!
                    }
                    
                    if let data = dataStr.data(using: .utf8) {
                        do {
                            
                            reachability.stopNotifier()
                            
                            let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            
                            if (dict["Code"] as? NSNumber) != 0 {
                                self.delegate?.syncServiceFailedWithError(dict, tag: tag)
                            }
                            else if (dict["Response"] is String) {
                                self.delegate?.syncServiceFailedWithError(dict, tag: tag)
                            }
                            else if (dict["Response"] is NSNull) {
                                self.delegate?.syncServiceFailedWithError(dict, tag: tag)
                            }
                            else {
                                self.delegate?.syncServiceFinished(dict, tag: tag)
                            }
                            print("GET RESPONSE for ~~~:::\(urlStr) ↓ ↓ ↓ ↓ ↓  \n \(dict)")
                        } catch {
                            print(error.localizedDescription)
                            self.delegate?.syncServiceFailedWithError([:], tag: tag)
                            
                        }
                    }
                    
                })
                task.resume()
            }
            reachability.whenUnreachable = { reachability in
                print("NoNetwork")
                
            }
        }
        reachability.whenUnreachable = { reachability in
            print("NoNetwork")
            
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        
        
    }
    
    
    // MARK: dlLibInitiateAsyncPostRequest
    
    /// dlLibInitiateAsyncPostRequest
    ///
    /// - Parameters:
    ///   - urlStr: String API Req - URL
    ///   - uploadData: Data - POST Object
    ///   - type: DLRequestType - enum for type of request(ex: html, pdf, etc...)
    ///   - tag: Int - Unique identity
    ///   - author : rathish_citys@eres.ae
    
    public   func dlLibInitiateAsyncPostRequest(urlStr:String,uploadData: Data, type:DLNetworkingTypes.RequestType, tag:Int) {
        
        print("GET URL SENT = \(urlStr)")
        
        let request = NSMutableURLRequest(url: URL(string: urlStr)!, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 10)
        
        switch type {
        case DLNetworkingTypes.RequestType.RequestTypeImage:
            request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
            break
        case DLNetworkingTypes.RequestType.RequestTypeHTML:
            request.addValue("text/html", forHTTPHeaderField: "Content-Type")
            break
        case DLNetworkingTypes.RequestType.RequestTypePDF:
            request.addValue("application/pdf", forHTTPHeaderField: "Content-Type")
            break
        case DLNetworkingTypes.RequestType.RequestTypeDefault:
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            break
        }
        
        request.httpMethod = "POST"
        request.httpBody   = uploadData
        
        let defaultConfigObject =  URLSessionConfiguration.default
        let defaultSession =  URLSession.init(configuration: defaultConfigObject, delegate: self, delegateQueue: OperationQueue.main)
        
        let reachability = Reachability()!
        reachability.whenReachable = { reachability in
            
            DispatchQueue.main.async {
                let task = defaultSession.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                    
                    let dataStr = String.init(data: data!, encoding: String.Encoding.utf8)
                    
                    if let data = dataStr?.data(using: .utf8) {
                        do {
                            let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                            
                            if (dict["Code"] as? NSNumber) != 0 {
                                self.delegate?.syncServiceFailedWithError(dict, tag: tag)
                            }
                            else if (dict["Response"] is String) {
                                self.delegate?.syncServiceFailedWithError(dict, tag: tag)
                            }
                            else if (dict["Response"] is NSNull) {
                                self.delegate?.syncServiceFailedWithError(dict, tag: tag)
                            }
                            else {
                                self.delegate?.syncServiceFinished(dict, tag: tag)
                            }
                            print("GET RESPONSE for ~~~:::\(urlStr) ↓ ↓ ↓ ↓ ↓  \n \(dict)")
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    
                })
                
                task.resume()
            }
            reachability.whenUnreachable = { reachability in
                print("NoNetwork")
                
            }
        }
        reachability.whenUnreachable = { reachability in
            print("NoNetwork")
            
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
    }
    
}













