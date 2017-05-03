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
<<<<<<< HEAD
    func didReceiveMessage(msg : GSMessage,client : TcpClient)
=======
    func didReceiveRequest(_ message : GSProtocolMessage)
>>>>>>> 87f0da7ed5e47fb7ae8fce0053aeaa04b3ecc3b1
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
<<<<<<< HEAD
                        do{
                            var next = true
                            while next{
                                let msg = try GSMessage(rawData: readData)
                                if(self.delegate != nil){
                                    self.delegate.didReceiveMessage(msg:msg, client: self)
                                }
                                next =  msg.isNext
                                if next {
                                    self.queue.sync {
                                        readData = readData.subdata(in: Int(msg.totalMessageSize)..<readData.count)
                                    }
                                }
                            }
                        }catch{
                            debugPrint("\(error.localizedDescription)")
                        }
=======
                        
//                        let data = Data(bytes: [238, 238, 0, 18, 5])
//                        let bb = try GSProtocolMessage(rawData: data)
//                        if(self.delegate != nil){
//                            self.delegate.didReceiveRequest(bb)
//                        }
                        
>>>>>>> 87f0da7ed5e47fb7ae8fce0053aeaa04b3ecc3b1
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
