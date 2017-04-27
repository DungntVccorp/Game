//
//  Component.swift
//  P
//
//  Created by Nguyen Dung on 4/19/17.
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
    public init() { }
    
    var componentName : String{
        return NSStringFromClass(type(of: self))
    }
    
    
    open func loadConfig() throws{
        print("Root Load Config \(componentName)")
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
