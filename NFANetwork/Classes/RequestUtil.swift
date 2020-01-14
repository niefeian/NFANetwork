
//
//  Pods-Tools_Example
//
//  Created by 聂飞安 on 2019/8/15.
//

import UIKit
import Foundation

public typealias RequestCompletionHandler = (URLResponse?, Data?, NSError?) -> Void

internal var _requestOperationQueue: OperationQueue?

open class RequestUtil: NSObject, NSURLConnectionDataDelegate {
    
    
    //MARK: Request Properties
    open class func urlCache() -> NSCache<AnyObject, AnyObject>!
    {
        return NSCache()
    }
    
    open var url: URL
    open var method = "GET"
    open var body: Data?
    open var headers: Dictionary<String, String> = Dictionary()
    open var parameters: Dictionary<String, String> = Dictionary()
    open var completionHandler: RequestCompletionHandler
    open var bodyType : String?
    
    open var contentType: String? {
        set {
            headers["Content-Type"] = newValue
        }
        get {
            return headers["Content-Type"]
        }
    }
    
    open var userAgent: String? {
        set {
            headers["User-Agent"] = newValue
        }
        get {
            return headers["User-Agent"]
        }
    }

    //MARK: Response Properties

    open var response: URLResponse?
    open lazy var responseData = NSMutableData()
    
    //MARK: NSURLConnection
    
    internal var connection: NSURLConnection?
    
    public init(url: URL) {
        self.url = url
        completionHandler = {response, data, error in}
        super.init()
    }
    
    //MARK: Request Loading
    
    open func loadWithCompletion(_ completionHandler: @escaping RequestCompletionHandler) {
        self.completionHandler = completionHandler
        loadRequest()
    }
    
    open func loadRequest() {
        
        if (parameters.count > 0) {
            serializeRequestParameters()
        }
        
        if _requestOperationQueue == nil {
            _requestOperationQueue = OperationQueue()
            _requestOperationQueue!.maxConcurrentOperationCount = 4
            _requestOperationQueue!.name = "com.niefeian.net_framework"
        }
        
        connection = NSURLConnection(request: urlRequest() as URLRequest, delegate: self)
        connection!.setDelegateQueue(_requestOperationQueue)
        connection!.start()
    }
    
    //MARK: Request Creation
    
    open func urlRequest() -> NSMutableURLRequest {
        // 设定超时时间为20秒
        let request: NSMutableURLRequest = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = method
        request.httpBody = body
        
        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }
        
        if let validBody = body {
            if (validBody.count > 0) {
                request.setValue(String(validBody.count), forHTTPHeaderField: "Content-Length")
            }
        }
        
        return request
    }
    
    //MARK: Request Parameters
    func serializeRequestParameters() {
        contentType = "application/x-www-form-urlencoded"
        
        if (method == "GET") {
            if let queryURL = queryParametersURL() {
                url = queryURL
            }
        } else {
            body = serializedRequestBody()
        }
    }
    
    func serializedRequestBody() -> Data? {
        if bodyType == "feian.com" {
            var json : String = ""
            do {
                let data = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
                let strJson = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                json = strJson as String? ?? ""
            }catch let e {
                print(e)
            }
            #if DEBUG
                print(url.description + "?" + "m=\(json)")
            #endif
            return "m=\(json)".data(using: String.Encoding.utf8, allowLossyConversion: true)
        }
        return queryString().data(using: String.Encoding.utf8, allowLossyConversion: true)
    }
    
    func queryParametersURL() -> URL? {
        var qryString = queryString();
        if !url.absoluteString.contains("?") {
            qryString = "?" + qryString
        } else {
            qryString = "&" + qryString
        }
        return URL(string: url.absoluteString + qryString)
    }
    
    open func queryString() -> String {
        var result = method == "GET" ? "" : ""
        var firstPass = true
        
        for (key, value) in parameters {
            let encodedKey: NSString = key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! as NSString
            let encodedValue: NSString = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! as NSString
            result += firstPass ? "\(encodedKey)=\(encodedValue)" : "&\(encodedKey)=\(encodedValue)"
            firstPass = false;
        }
        #if DEBUG
            print(url.description + "?" + result)
        #endif
        return result
    }
    
    //MARK: NSURLConnectionDataDelegate

    open func connection(_ connection: NSURLConnection, didFailWithError error: Error) {
        completionHandler(nil, nil, error as NSError?)
    }
    
    open func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        self.response = response
    }
    
    open func connection(_ connection: NSURLConnection, didReceive data: Data) {
        responseData.append(data)
    }
    
    open func connectionDidFinishLoading(_ connection: NSURLConnection) {
        completionHandler(response, responseData as Data, nil)
    }
}
