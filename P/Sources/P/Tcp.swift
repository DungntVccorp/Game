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

class Tcp : clientSocketDelegate {
    
    
    //MARK: - 💤 LazyLoad Method
    private var parentController : GameEngine!
    private var tcpSocket : Socket!
    private var queue : DispatchQueue!
    private var listConnection : SynchronizedArray = SynchronizedArray<tcpClient>()
    
    
    lazy var isContinueRunning: Bool = {
        let continueRunning : Bool = true
        return continueRunning
    }()
    init() { }
    
    convenience init(_ engine : GameEngine){
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
                    let client  = tcpClient(client: newClientConnect,delegate: self)
                    self.listConnection.append(newElement:client)
                    debugPrint("Client \(client.uuid) Did Connect")
                }while self.isContinueRunning
            }
            catch {
                debugPrint(error.localizedDescription)
            }
        }
        dispatchMain()
    }
    
    
    
    //MARK: - 🔌 clientSocketDelegate Method
    func clientDidDisconect(client: tcpClient) {
        guard let listConnect = self.listConnection.allObject() else { return }
        var index : Int = 0
        for c in listConnect{
            if(c.uuid == client.uuid){
                self.listConnection.removeAtIndex(index: index)
                break
            }
            index = index + 1
        }
    }
    func clientUnknowError(client: tcpClient, err: Error) {
        guard let listConnect = self.listConnection.allObject() else { return }
        var index : Int = 0
        for c in listConnect{
            if(c.uuid == client.uuid){
                self.listConnection.removeAtIndex(index: index)
                break
            }
            index = index + 1
        }
    }
}
