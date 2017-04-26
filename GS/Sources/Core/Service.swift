//
//  Service.swift
//  GS
//
//  Created by Nguyen Dung on 1/3/17.
//
//

import Foundation
import Commessage
import Socket
import LoggerAPI

public class Service : Component{
    public override func ComponentType() -> ComponentType {
        return .Service
    }
    class public func instance() -> Service? {
        return Engine.shareInstance.getComponent(with: .Service) as? Service
    }

    
    public override func loadConfig() throws {
        
    }
    public override func priority() -> Int {
        return 1
    }
    public override func start() throws {
        
    }
    public override func stop() {
        
    }
    
    public func pushTask(msg : Commessage,socket : Socket){
        Log.info("SYNC TASK")
    }
}
