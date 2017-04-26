
//
//  LoggerManager.swift
//  GS
//
//  Created by Nguyen Dung on 11/30/16.
//
//

import Foundation
import HeliumLogger
import LoggerAPI
import Core

public class LoggerManager : Component{
    
    class open func instance() -> LoggerManager {
        return Engine.shareInstance.getComponent(with: .logger) as! LoggerManager
    }
    
    open let logger = HeliumLogger()
    override open func ComponentType() -> ComponentType {
        return .logger
    }
    override open func loadConfig() throws {
       Log.logger = logger
    }
    override open func priority() -> Int {
        return 0
    }
    override open func start() throws {
    }
    override open func stop() {
        
    }
}
