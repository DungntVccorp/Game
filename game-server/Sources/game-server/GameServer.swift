//
//  GameServer.swift
//  P
//
//  Created by Nguyen Dung on 4/19/17.
//
//

import Foundation
import LoggerAPI

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
        listConnection.append(tcpClient)
    }
    
    //MARK: - 🔌 clientSocketDelegate Method
    func clientDidDisconect(client: TcpClient) {
        listConnection.remove(where: { (c : TcpClient) -> Bool in
            return c.socket.socketfd == client.socket.socketfd
        }, completion: nil)
    }
    func clientUnknowError(client: TcpClient, err: Error) {
        listConnection.remove(where: { (c : TcpClient) -> Bool in
            return c.socket.socketfd == client.socket.socketfd
        }, completion: nil)
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
            Log.info("\(totalByteSend / 1024) Kb")
        }catch{
            Log.error(error.localizedDescription)
        }
    }
}



