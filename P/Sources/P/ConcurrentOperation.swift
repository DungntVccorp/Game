//
//  BaseOperation.swift
//  P
//
//  Created by Nguyen Dung on 4/27/17.
//
//

import Foundation

protocol ConcurrentOperationDelegate {
    func finishOperation(_ type : Int,_ replyMsg : GSProtocolMessage?,_ client : TcpClient)
}

open class ConcurrentOperation :  Operation{
    
    enum State {
        case ready
        case executing
        case finished
        
        func asKeyPath() -> String {
            switch self {
            case .ready:
                return "isReady"
            case .executing:
                return "isExecuting"
            case .finished:
                return "isFinished"
            }
        }
    }
    
    var state: State {
        willSet {
            willChangeValue(forKey: newValue.asKeyPath())
            willChangeValue(forKey: state.asKeyPath())
        }
        
        didSet {
            didChangeValue(forKey: oldValue.asKeyPath())
            didChangeValue(forKey: state.asKeyPath())
        }
    }
    
    
    private var delegate : ConcurrentOperationDelegate!
    var clientExcute : TcpClient!
    var excuteMessage : GSProtocolMessage!
    override init() {
        state = .ready
        super.init()
    }
    convenience init(_ delegate : ConcurrentOperationDelegate?,_ client : TcpClient,_ msg : GSProtocolMessage) {
        self.init()
        if(delegate != nil){
            self.delegate = delegate!
        }
        self.clientExcute = client
        self.excuteMessage = msg
    }
    
    // MARK: - NSOperation
    
    override open var isReady: Bool {
        return state == .ready
    }
    
    override open var isExecuting: Bool {
        return state == .executing
    }
    
    override open var isFinished: Bool {
        return state == .finished
    }
    
    override open var isAsynchronous: Bool {
        return true
    }
    override open func start() {
        if self.isCancelled {
            state = .finished
        }else{
            state = .ready
            main()
        }
    }
    
    open func TcpExcute() -> (Int,replyMsg : GSProtocolMessage?){
        return (0,nil)
    }
    
    override open func main() {
        if self.isCancelled {
            state = .finished
        }else{
            state = .executing
            debugPrint("Run OP \(excuteMessage.headCodeId) : \(excuteMessage.subCodeId)")
            let ex = self.TcpExcute()
            if(self.delegate != nil){
                self.delegate.finishOperation(ex.0,ex.1,self.clientExcute)
            }
            state = .finished

        }
        
    }
    deinit {
        debugPrint("Finish Operation")
    }
}
