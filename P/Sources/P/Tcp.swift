//
//  Tcp.swift
//  P
//
//  Created by Nguyen Dung on 4/19/17.
//
//

import Foundation
import Socket
import Config
import Dispatch

public enum TcpError : Error {
    case Unable_to_unwrap_socket
}

class Tcp {
    
    
    //MARK: - 💤 LazyLoad Method
    private var parentController : GameServer!
    private var tcpSocket : Socket!
    private var queue : DispatchQueue!
    
    
    
    lazy var isContinueRunning: Bool = {
        let continueRunning : Bool = true
        return continueRunning
    }()
    
    init() { }
    
    convenience init(_ engine : GameServer){
        self.init()
        parentController = engine
    }
    
    func startTcp(){
        queue = DispatchQueue.global(qos: .userInteractive)
        queue.async {[unowned self] in
            do {
                self.tcpSocket = try Socket.create(family: Socket.ProtocolFamily.inet, type: Socket.SocketType.stream, proto: Socket.SocketProtocol.tcp)
                
                try self.tcpSocket.listen(on: ConfigManager.sharedInstance.getTcpPort, maxBacklogSize: 500)
                debugPrint("Listening on port: \(self.tcpSocket.listeningPort)")
                repeat{
                    let newClientConnect = try self.tcpSocket.acceptClientConnection()
                    let client  = TcpClient(client: newClientConnect,delegate: self.parentController)
                    self.parentController.clientDidConnect(client)
                    debugPrint("Client \(client.socket.socketfd) Did Connect")
                }while self.isContinueRunning
            }
            catch {
                debugPrint(error.localizedDescription)
            }
        }
        dispatchMain()
    }
    
    
    
    
}
