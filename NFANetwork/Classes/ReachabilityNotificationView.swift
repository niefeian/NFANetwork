//
//  ReachabilityNotificationView.swift
//  cloudclass
//
//  Created by 聂飞安 on 2018/6/29.
//  Copyright © 2018年 accfun. All rights reserved.
//

import UIKit

public class ReachabilityNotificationView: NSObject {
    
    static let sharedInstance = ReachabilityNotificationView()
    
    var isCanUseReachableViaWWAN = false
    var isCanUseWWANDownlod = false
    var isCanUseWWANLookVideo = false
    
    var reachability = Reachability()
    
    
   open class func stareNetNotication(){
        sharedInstance.shart()
    }
    
   open class func stopNetNotication(){
        sharedInstance.stop()
    }
    
    open class func getIsReachable() -> Bool {
        return sharedInstance.reachability?.isReachable ?? false
    }
   open class func getIsReachableViaWiFi() -> Bool {
        return sharedInstance.reachability?.isReachableViaWiFi ?? false
    }
    
    open class func getIsReachableViaWWAN() -> Bool {
        return sharedInstance.reachability?.isReachableViaWWAN ?? false
    }
    
    
    open class func checkLookVideo(_ completion :  @escaping (_ result : Bool)->()){
        sharedInstance.checkLook(completion)
    }
    
    private func stop(){
        NotificationCenter.default.removeObserver(self)
    }
    
    private func shart(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do{
            try
                reachability?.startNotifier()
        }catch{
            
        }
    }
    
    // 主动检测网络状态
    @objc func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability // 准备获取网络连接信息
        if !reachability.isReachable{
            return
        }
        
        if reachability.isReachableViaWWAN {
           
        }
        
        if reachability.isReachableViaWiFi  {
          
        }
    }
    
    
    private func checkLook(_ completion :  @escaping (_ result : Bool)->()){
        if !(reachability?.isReachableViaWiFi ?? false){
            if !(reachability?.isReachable ?? false){
                completion(false)
            }
            
            if (reachability?.isReachableViaWWAN ?? false){
                //用流量了
                if !isCanUseWWANLookVideo {
                    
                }else{
                    completion(isCanUseWWANLookVideo)
                }
            }
        }
        completion(true)
    }
    
  
    
}
