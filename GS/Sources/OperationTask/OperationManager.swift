//
//  OperationManager.swift
//  GS
//
//  Created by Nguyen Dung on 11/29/16.
//
//

import Foundation
import Core

open class BaseOperation : Operation{
    var uid : String = UUID().uuidString
    
    public init(uid : String = "") {
        super.init()
        if(uid.isEmpty == false){
            self.uid = uid            
        }
    }
    override open func start() {
        super.start()
    }
    override open func main() {
        super.main()
    }
}


public class OperationManager : Component{
    
    
    
    private let operationQueue: OperationQueue = OperationQueue()

    
    public override func loadConfig() throws{
        self.operationQueue.maxConcurrentOperationCount = ProcessInfo.processInfo.activeProcessorCount * 10
        self.operationQueue.qualityOfService = .userInitiated
    }
    
    public override func ComponentType() -> ComponentType {
        return .Operations
    }
    
    public override func priority() -> Int {
        return 2
    }
    
    public override func stop() {
        self.operationQueue.cancelAllOperations()
    }
    
    public override func start() throws {
        
    }
    
    public func addNewOperation(newOperation : BaseOperation){
        self.operationQueue.addOperation(newOperation)
    }
    
}
