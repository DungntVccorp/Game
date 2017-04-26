//
//  Engine.swift
//  GS
//
//  Created by Nguyen Dung on 11/28/16.
//
//

import Foundation
import Communication

open class Engine{
    
    open static let shareInstance : Engine = {
        let instance = Engine()
        return instance
    }()
    
    private var listComponent : Array<Component>!
    
    init() {
        self.listComponent = Array<Component>()
    }
    
    open func startEngine(){
        guard onStartComponent() else {
            return
        }
        
    }
    open func registerComponent(component : Component){
        self.listComponent.append(component)
    }
    
    
    
    
    func onStartComponent() -> Bool{
        var check = true
        for component in self.listComponent.sorted(by: { (c1, c2) -> Bool in
            return c1.priority() <= c2.priority()
        }){
            do{
                try component.loadConfig()
                try component.start()
            }catch{
                check = false
                break
            }
        }
        return check
    }
    
    public func getComponent(with type : ComponentType) -> Component?{
        for component in self.listComponent.sorted(by: { (c1, c2) -> Bool in
            return c1.priority() >= c2.priority()
        }){
            if(component.ComponentType() == type){
                return component
            }
        }
        return nil
    }
    
    
    
    
}
