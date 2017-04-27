//
//  GameServer.swift
//  P
//
//  Created by Nguyen Dung on 4/19/17.
//
//

import Foundation


public class GameServer : Component,clientSocketDelegate{
    
    
    private var listConnection : SynchronizedArray = SynchronizedArray<TcpClient>()
    
    
    override public func ComponentType() -> ComponentType {
        return .GS
    }
    
    override public func start() throws {
    }
    
    
    
    //MARK: -  CLIENT DID CONNECT
    
    func clientDidConnect( _ tcpClient : TcpClient){
        listConnection.append(newElement: tcpClient)
        
        
    }
    
    //MARK: - 🔌 clientSocketDelegate Method
    func clientDidDisconect(client: TcpClient) {
        guard let listConnect = listConnection.allObject() else { return }
        var index : Int = 0
        for c in listConnect{
            if(c.socket.socketfd == client.socket.socketfd){
                self.listConnection.removeAtIndex(index: index)
                break
            }
            index = index + 1
        }
    }
    func clientUnknowError(client: TcpClient, err: Error) {
        guard let listConnect = listConnection.allObject() else { return }
        var index : Int = 0
        for c in listConnect{
            if(c.socket.socketfd == client.socket.socketfd){
                listConnection.removeAtIndex(index: index)
                break
            }
            index = index + 1
        }
    }
}



