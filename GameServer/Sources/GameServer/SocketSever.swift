//
//  SocketSever.swift
//  GameServer
//
//  Created by Nguyen Dung on 9/30/16.
//
//

import Foundation
import Socks
import SocksCore
import Dispatch
class SocketSever: NSObject {
    private var socket_sever : SynchronousTCPServer!
    private var currentPort : UInt16 = 4444
    convenience init(port : UInt16) {
        self.init()
        self.currentPort = port
    }
    
    func startSocket() -> Bool{
        
        do{
            let address = InternetAddress.any(port: self.currentPort, ipVersion: AddressFamily.unspecified)
            self.socket_sever = try SynchronousTCPServer(address: address)
            print("Listening on \"\(self.socket_sever.address.hostname)\" (\(self.socket_sever.address.addressFamily)) \(self.socket_sever.address.port)")
            return true
            
        }catch{
            print("Socket Start Failure")
            print(error)
            return false
        }
    }
    func startHandler(){
        DispatchQueue(label: "MainSocketHandler").async {
            do{
                try self.socket_sever.startWithHandler(handler: { (client) in
                    GSShare.sharedInstance.addClient(newClient: ClientHander(client: client))
                })
            }catch{
                print("Client Connect False \(error)")
            }
        }
        
    }
}
