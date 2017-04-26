//
//  HttpServer.swift
//  GS
//
//  Created by Nguyen Dung on 1/1/17.
//
//

import Foundation
import Core
public class HttpServer : Component{
    override public func ComponentType() -> ComponentType {
        return .Http
    }
    override public func loadConfig() throws {
        
    }
    override public func priority() -> Int {
        return 2
    }
    override public func start() throws {
        
    }
    override public func stop() {
        
    }
}
