//
//  TcpServer.swift
//  GS
//
//  Created by Nguyen Dung on 12/31/16.
//
//

import Foundation
import Socket
import Dispatch
import LoggerAPI
import Core
import Commessage


public class TcpServer: Component {
    
    private var listenSocket : Socket?
    static let bufferSize = 4096
    var continueRunning = true
    var clients = [Int32: Socket]()
    let socketLockQueue = DispatchQueue(label: "com.ibm.serverSwift.socketLockQueue")
    let port: Int = 1988
        
    deinit {
        // Close all open sockets...
        listenSocket = nil        
    }
    
    public override func ComponentType() -> ComponentType {
        return .Tcp
    }
    public override func loadConfig() throws{
        Log.debug("Load Config")
    }
    public override func priority() -> Int {
        return 2
    }
    public override func start() throws {
        DispatchQueue.global(qos: .userInteractive).async {[unowned self] in
            do{
                try self.listenSocket = Socket.create(family: Socket.ProtocolFamily.inet, type: Socket.SocketType.stream, proto: Socket.SocketProtocol.tcp)
                guard let socket = self.listenSocket else {
                    Log.verbose("Unable to unwrap socket...")
                    return
                }
                try socket.listen(on: self.port)
                Log.verbose("Listening on port: \(socket.listeningPort)")
                repeat {
                    let newSocket = try socket.acceptClientConnection()
                    Log.verbose("Accepted connection from: \(newSocket.remoteHostname) on port \(newSocket.remotePort)")               
                    self.addNewConnection(socket: newSocket)
                } while self.continueRunning
            }catch let error{
                guard let socketError = error as? Socket.Error else {
                    Log.error("Unexpected error...")
                    return
                }
                if self.continueRunning {
                    Log.error("Error reported:\n \(socketError.description)")
                }
            }
        }
        
    }
    public override func stop() {
        continueRunning = false
        
        // Close all open sockets...
        for socket in clients.values {
            socket.close()
        }
        clients.removeAll()
        listenSocket?.close()
        
    }
    
    
    //MARK: - 🔌 ACCEPT CLIENT CONNECTION Method
    func addNewConnection(socket: Socket) {
        
        // Add the new socket to the list of connected sockets...
        socketLockQueue.sync { [unowned self, socket] in
            self.clients[socket.socketfd] = socket
        }
        // Create the run loop work item and dispatch to the default priority global queue...
        DispatchQueue.global(qos: .default).async { [unowned self, socket] in
            var shouldKeepRunning = true
            var readData = Data(capacity: TcpServer.bufferSize)
            do {
                repeat {
                    let bytesRead = try socket.read(into: &readData)
                    
                    if bytesRead > 0 {
                        Log.verbose("Received from connection at \(socket.remoteHostname):\(socket.remotePort): \(bytesRead) bytes ")
                        do{
                            let msg = try Commessage(rawData: readData)
                            readData = readData.subdata(in: msg.msg_size! ..< readData.count)
                            Log.verbose("Push Task")
                            Service.instance()?.pushTask(msg: msg, socket: socket)
                        }catch CommessageError.size_invalid{
                            Log.info("Appen Receive Data")
                        }
                        catch{
                            print(error)
                            readData.count = 0
                            shouldKeepRunning = false
                            break
                        }
                    }
                    if bytesRead == 0 {
                        shouldKeepRunning = false
                        break
                    }
                } while shouldKeepRunning
                Log.verbose("Socket: \(socket.remoteHostname):\(socket.remotePort) closed...")
                socket.close()
                
                self.socketLockQueue.sync { [unowned self, socket] in
                    self.clients[socket.socketfd] = nil
                }
            }
            catch let error {
                guard let socketError = error as? Socket.Error else {
                    Log.error("Unexpected error by connection at \(socket.remoteHostname):\(socket.remotePort)...")
                    return
                }
                if self.continueRunning {
                    Log.error("Error reported by connection at \(socket.remoteHostname):\(socket.remotePort):\n \(socketError.description)")
                }
            }
        }
    }
}
