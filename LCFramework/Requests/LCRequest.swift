//
//  LCRequest.swift
//  RequestSample
//
//  Created by Leo on 8/23/15.
//  Copyright (c) 2015 Perfectidea Inc. All rights reserved.
//

import UIKit

struct GlobalDefine {
 
    static let appVersion = "app-Version"
    static let appModel = "app-model"
    static let sysVersion = "app-Version"
    static let userAccount = "app-User"
    static let userToken = "app-token"
    
    static let getMethod = "GET"
    static let postMethod = "POST"
    static let putMethod = "PUT"
    
    static let baseTimeout : NSTimeInterval = 30
}

public class GLobalFuncion {
    static func getAppVersion() -> String {
        return NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String
    }
    static func getAppBuidVersion() -> String {
        return NSBundle.mainBundle().infoDictionary?[kCFBundleVersionKey] as! String
    }
}

public enum LCRequestTag {
    case LCRequestTagDefault
}

/*
typedef void (^completionBlock) (PFRequestTag tag, NSData *responseData);
typedef void (^saveBlock) (PFRequestTag tag);
typedef void (^falureBlock) (PFRequestTag tag, NSError *error);
*/
public class LCRequest: NSOperation {
    
    // MARK: define the callback methods
    public var completion : ((tag : LCRequestTag , responseCode : Int, json : NSDictionary) -> ())?
    public var failure : ((tag : LCRequestTag, responseCode : Int, error : NSError?) -> ())?
    public var onRceiveData : ((tag : LCRequestTag, totalLength : Int) -> ())?
    
    // MARK: variables
    private var usePostBody : Bool?
    private var timeout : NSTimeInterval = GlobalDefine.baseTimeout
    private var tag : LCRequestTag?
    
    private var conn : NSURLConnection?
    private var request : NSMutableURLRequest?
    private var responseData : NSMutableData?
    private var url : NSURL?
    private var params : Dictionary<String, AnyObject>?
    private var method : String?
    
    private var responseCode : Int?
    
    public init(u : NSURL, d : Dictionary<String, AnyObject>!, t : NSTimeInterval, m : String, useBody : Bool, tag : LCRequestTag) {
        super.init()
        self.responseCode = 404
        self.tag = tag
        self.params = d
        self.timeout = t
        self.method = m
        self.usePostBody = useBody
        
        if (!useBody) {
            self.url = convertParamWithUrl(u)
        }
        else {
            self.url = u
        }
        createRequest()
    }
    
    
    // MARK : Private methods
    
    func createRequest() -> () {
        var request = NSMutableURLRequest(URL: url!)
        request.timeoutInterval = timeout
        request.HTTPMethod = method!
        
        //add http header
        let device = UIDevice.currentDevice();
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue(GLobalFuncion.getAppVersion(), forHTTPHeaderField: GlobalDefine.appVersion)
        request.addValue(device.model, forHTTPHeaderField: GlobalDefine.appModel)
        request.addValue(device.systemVersion, forHTTPHeaderField: GlobalDefine.sysVersion)
        
        //add post body
        if (usePostBody == true) {
            var param : NSString = generateParams()
            var data : NSData = param.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!
            
            request.HTTPBody = data;
            request .setValue(String(format: "%li", data.length), forHTTPHeaderField: "Content-Length")
        }
        
        self.request = request
    }
    
    /*
    @discussion Conert http request url
    */
    func convertParamWithUrl(url : NSURL) -> NSURL {
        
        var str : NSMutableString = NSMutableString(string: url.absoluteString!)

        if (self.params?.isEmpty != nil) {
            str.appendString("?")
            str.appendString(generateParams() as String)
        }
        return NSURL(string: str as String)!
    }
    
    func generateParams() -> NSString {
        
        var counter : Int = 0;
        var str : NSMutableString = NSMutableString()
        for (key , value) in params! {
            var param : NSString!
            if value is NSArray {
                
                let items = value as! NSArray
                var tmp : NSMutableString = NSMutableString()
                for s in items {
                    tmp.appendString(s as! String);
                }
                param = NSString(string: tmp);
            }
            else if value is NSNumber {
                param = NSString(format: "%@", value as! NSNumber);
            }
            else {
                param = NSString(format: "%@", value as! NSString);
            }
            str.appendFormat("%@=%@", key as NSString , param.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!);
            
            if (counter < params!.count - 1) {
                str.appendString("&");
            }
            
            counter += 1
        }
        
        return str;
    }
    
    public override func start() {
        super.start()
        
        self.conn = NSURLConnection(request: request!, delegate: self)
        self.conn?.start()
    }
}

extension LCRequest : NSURLConnectionDataDelegate {
    
    public func connection(connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: NSURLProtectionSpace) -> Bool {
        
        return true
    }
    
    public func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        var httpResponse = response as! NSHTTPURLResponse
        self.responseCode = httpResponse.statusCode
        self.responseData = NSMutableData()
    }
    
    public func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        responseData?.appendData(data)
        onRceiveData?(tag: tag!, totalLength: responseData!.length)
    }
    
    public func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        //print("result : \(responseData)")
        failure?(tag: tag!, responseCode: responseCode!, error: error);
    }
    
    public func connectionDidFinishLoading(connection: NSURLConnection) {
        //print("result : \(responseData)")
        unowned(unsafe) var weakSelf = self
        responseData?.toJson(responseData!, completion: {json, error in
            if (error != nil) {
                weakSelf.failure?(tag: weakSelf.tag!, responseCode: weakSelf.responseCode!, error: error);
            }
            else {
                weakSelf.completion?(tag: weakSelf.tag!, responseCode: weakSelf.responseCode!, json: json)
            }
            
        })
        
    }
}

extension NSData {
    
    public func toJson(data : NSData, completion : (json : NSDictionary, error : NSError?) -> ()) -> () {
        var error : NSError? = nil
        var json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
        completion(json: json, error: error)
    }
}

