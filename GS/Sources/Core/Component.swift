//
//  Component.swift
//  GS
//
//  Created by Nguyen Dung on 11/29/16.
//
//

import Foundation


public enum ComponentType{
    case None
    case Tcp
    case Http
    case Database
    case logger
    case Session
    case Operations
    case Event
    case Service
    
}

open class Component{
    
    public init(){}
    
    open func loadConfig() throws{
        print("Root Load Config")
    }
    open func start() throws{
    }
    open func stop() {
    }
    open func priority() -> Int{
        return 1000
    }
    open func ComponentType() -> ComponentType{
        return .None
    }
}

