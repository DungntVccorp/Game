//
//  GameServer.swift
//  P
//
//  Created by Nguyen Dung on 4/19/17.
//
//

import Foundation


public class GameServer : Component,clientSocketDelegate,ConcurrentOperationDelegate{
    
    
    class func instance() -> GameServer?{
        return GameEngine.sharedInstance.getComponent(.GS) as? GameServer
    }
    
    
    private var listConnection : SynchronizedArray = SynchronizedArray<TcpClient>()
    private var totalByteSend : Int = 0
    
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
    func didReceiveMessage(msg: GSProtocolMessage, client: TcpClient) {
        switch msg.headCodeId {
        case GSProtocolMessageType.headCode.profile:
            switch msg.subCodeId {
            case GSProtocolMessageType.subCode.profile_KeepAlive:
                OperationManager.instance()?.enqueue(operation: OperationKeepAlive(self, client, msg))
                break
            case GSProtocolMessageType.subCode.profile_login:
                break
            default:
                break
            }
        default:
            break
        }
    }
    
    
    func finishOperation(_ type: Int, _ replyMsg: GSProtocolMessage?, _ client: TcpClient) {
        do{
            guard let data = try replyMsg?.data() else { return }
            totalByteSend = totalByteSend + (try client.sendMessage(data))
            debugPrint("\(totalByteSend / 1024)Kb")
        }catch{
            debugPrint(error.localizedDescription)
        }
    }
}



