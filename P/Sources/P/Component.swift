//
//  Component.swift
//  P
//
//  Created by Nguyen Dung on 4/19/17.
//
//

import Foundation
public enum ComponentType : Int{
    case Operations = 0
    case Database
    case Session
    case Service
    case logger
    case GS
    case None
    
}

open class Component{
    public init() { }
    
    var componentName : String{
        return NSStringFromClass(type(of: self))
    }
    
    open func loadConfig() throws{ }
    open func start() throws{ }
    open func stop() { }
    func priority() -> Int{
        return ComponentType().rawValue
    }
    open func ComponentType() -> ComponentType{
        return .None
    }
}
