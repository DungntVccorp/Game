//
//  ClientHander.swift
//  GameServer
//
//  Created by Nguyen Dung on 9/30/16.
//
//

import Dispatch
import Foundation
import Socks
class ClientHander: NSObject {
    private var client : TCPClient!
    private var close : Bool = false
    private var ClientMessage : Array<Array<UInt8>>!
    var uuid : String!
    
    
    convenience init(client : TCPClient) {
        self.init()
        self.client = client
        self.uuid = UUID().uuidString
        self.ClientMessage = Array<Array<UInt8>>()
        print("Client: \(self.client.socket.address)")
        DispatchQueue(label: "\(self.client.ipAddress()) : \(self.client.socket.address.port) : receive").async {
            while !self.close{
                do{
                    let data = try self.client.receiveAll()
                    if(data.count == 0){
                        print("Client disconnect and remove form connect list")
                        self.close = true
                    }else{
                        self.ClientMessage.append(data)
                        if(data.count == 61){
                            DispatchQueue.main.async {
                                //Timer.scheduledTimer(timeInterval: 45, target: self, selector: #selector(ClientHander.onSendTest), userInfo: nil, repeats: true)
                                self.sendMessage(msg: "DONE");
                            }    
                        }
                        
                    }
                }catch{
                    print(error)
                    self.close = true
                }
            }
            
            do{
                try self.client.close()
                GSShare.sharedInstance.removeClient(client: self)
            }catch{
                print(error)
            }

        }
    }
    deinit {
        self.client = nil
        self.uuid = nil
        self.ClientMessage = nil
        print("REMOVE CLASS")
    }
    func onSendTest(){
        print("Send Test Message")
        self.sendMessage(msg: "test \n")
       
    }
    
    func sendMessage(msg : String){
        sendMessage(data: msg.data(using: String.Encoding.utf8)!)
    }
    
    func sendMessage(data : Data){
        sendMessage(data: data.bytes)
    }
    func sendMessage(bytes : [UInt8]){
        do{
            try self.client.send(bytes: Data)
        }catch{
            print(error)
        }
    }
    
}
