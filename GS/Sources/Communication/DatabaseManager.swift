//
//  DatabaseManager.swift
//  GS
//
//  Created by Nguyen Dung on 11/29/16.
//
//

import Foundation
import Core

public class DatabaseManager : Component{
    

    public override func loadConfig() throws{
    }
    
    public override func ComponentType() -> ComponentType {
        return .Database
    }
    
    public override func priority() -> Int {
        return 1
    }
    
    public override func stop() {
        
    }
    
    public override func start() throws {
    } 
}
