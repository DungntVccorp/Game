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
    func clientDidDisconect(client : TcpClient)
    func clientUnknowError(client: TcpClient,err : Error)
    func didReceiveRequest(_ message : GSProtocolMessage)
}

class TcpClient {
    
    var socket : Socket!
    
    private let queue = DispatchQueue.global(qos: .default)
    private let bufferSize = 4096
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
        queue.async { [unowned self] in
            do{
                
                var readData = Data()
                var shouldKeepRunning : Bool = true
                repeat {
                    let bytesRead = try self.socket.read(into: &readData)
                    if(bytesRead > 0){
                        debugPrint("Did Read \(bytesRead) byte form client \(self.socket.socketfd)")
                        
//                        let data = Data(bytes: [238, 238, 0, 18, 5])
//                        let bb = try GSProtocolMessage(rawData: data)
//                        if(self.delegate != nil){
//                            self.delegate.didReceiveRequest(bb)
//                        }
                        
                    }
                    if bytesRead == 0{
                        shouldKeepRunning = false
                    }
                }while shouldKeepRunning
                readData.count = 0
                debugPrint("Client \(self.socket.socketfd) Did Disconect")
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
    
    func sendMessage(_ data : Data) throws -> Int{
        if self.socket.isConnected {
            do{
                return try self.socket.write(from: data)
            }catch{
                throw error
            }
        }else{
            return -1
        }
    }
    
    deinit{
        debugPrint("deinit client")
    }
}
