//
//  OperationManager.swift
//  P
//
//  Created by Nguyen Dung on 4/26/17.
//
//

import Foundation
class OperationManager : Component{
    
    class func instance() -> OperationManager?{
        return GameEngine.sharedInstance.getComponent(.Operations) as? OperationManager
    }
    
    let operationQueue: OperationQueue = OperationQueue()
    
    override public func ComponentType() -> ComponentType {
        return .Operations
    }
    
    override public func loadConfig() throws {
        operationQueue.maxConcurrentOperationCount = OperationQueue.defaultMaxConcurrentOperationCount
        operationQueue.qualityOfService = .default
    }
    override public func stop() {
        operationQueue.cancelAllOperations()
        
    }
    override public func start() throws {
    }
    func enqueue(operation:BaseOperation) {
        self.operationQueue.addOperation(operation)
    }
    func dequeue(operation:BaseOperation) {
        for op in self.operationQueue.operations {
            if op == operation {
                operation.cancel()
            }
        }
    }
}
