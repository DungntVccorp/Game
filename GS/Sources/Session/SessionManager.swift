//
//  SessionManager.swift
//  GS
//
//  Created by Nguyen Dung on 11/29/16.
//
//

import Foundation
import Component



class SessionManager : Component{
    required public init(){}
    
    public func loadConfig() throws {
        
    }
    public func ComponentType() -> ComponentType {
        return .Session
    }
    public func priority() -> Int {
        return 0
    }
    public func start() throws {
        
    }
    public func stop() {
        
    }
}
