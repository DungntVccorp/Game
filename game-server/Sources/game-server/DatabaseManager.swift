//
//  DatabaseManager.swift
//  P
//
//  Created by Nguyen Dung on 4/24/17.
//
//

import Foundation
import SwiftRedis
import Config
import LoggerAPI
public enum dbError : Error{
    case invalid_config
    case password_invalid
    case connect_invalid
}

class DatabaseManager : Component{
    
    var database : Redis!
    var timerPing : Timer!
    var isReady : Bool = false
    
    class func instance() -> DatabaseManager?{
        return GameEngine.sharedInstance.getComponent(.Database) as? DatabaseManager
    }
    
    override public func ComponentType() -> ComponentType {
        return .Database
    }
    
    override public func loadConfig() throws {
        guard ConfigManager.sharedInstance.dbHost.isEmpty == false && ConfigManager.sharedInstance.dbPort != 0 && ConfigManager.sharedInstance.dbPassword.isEmpty == false else {
            throw dbError.invalid_config
        }
        database = Redis()
        //redis-server --requirepass password123
    }
    override public func start() throws {
        database.connect(host: ConfigManager.sharedInstance.dbHost, port: Int32(ConfigManager.sharedInstance.dbPort)) { (err) in
            if(err != nil){
                Log.error(err?.localizedDescription ?? "")
            }else{
                database.auth(ConfigManager.sharedInstance.dbPassword, callback: { (err) in
                    if(err != nil){
                        Log.error(err?.localizedDescription ?? "")
                    }else{
                        self.isReady = true
                        Log.info("Database Connected")
                    }
                })
            }
        }
    }
    
    
    
    
    
    
    
}
