//
//  tcpClient.swift
//  P
//
//  Created by Nguyen Dung on 4/27/17.
//
//

import Foundation
import Socket

protocol clientSocketDelegate {
    func clientDidDisconect(client : tcpClient)
    func clientUnknowError(client: tcpClient,err : Error)
}

class tcpClient {
    
    private var socket : Socket!
    
    private let queue = DispatchQueue.global(qos: .default)
    private let bufferSize = 4096
    let uuid : String = UUID().uuidString
    var delegate : clientSocketDelegate!
    init() {}
    convenience init(client : Socket,delegate : clientSocketDelegate? = nil) {
        self.init()
        self.socket = client
        if(delegate != nil){
            self.delegate = delegate
        }
        self.run()
    }
    
    func run(){
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        
        queue.async { [unowned self] in
            do{
                var readData = Data()
                var shouldKeepRunning : Bool = true
                repeat {
                    let bytesRead = try self.socket.read(into: &readData)
                    if(bytesRead > 0){
                        debugPrint("Did Read \(bytesRead) byte")
                    }
                    if bytesRead == 0{
                        shouldKeepRunning = false
                    }
                }while shouldKeepRunning
                readData.count = 0
                debugPrint("Client \(self.uuid) Did Disconect")
                if(self.delegate != nil){
                    self.delegate.clientDidDisconect(client: self)
                }
            }catch{
                debugPrint(error.localizedDescription)
                if(self.delegate != nil){
                    self.delegate.clientUnknowError(client: self, err: error)
                }
            }
        }
    }
    deinit{
        debugPrint("deinit client")
    }
}
