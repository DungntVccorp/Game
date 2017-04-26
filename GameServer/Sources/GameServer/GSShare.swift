//
//  GSShare.swift
//  GameServer
//
//  Created by Nguyen Dung on 9/30/16.
//
//

import Foundation
import Socks
import Dispatch
import Extension
import CryptoSwift

class GSShare: NSObject {
    private var listClient = Dictionary<String,ClientHander>()
    private var listClientID = Array<String>()
    class var sharedInstance: GSShare {
        struct Static {
            static let instance: GSShare = GSShare()
        }
        return Static.instance
    }
    
    func addClient(newClient : ClientHander){
        // RANDOM ID SET TO NEW CLIENT
        
        let uuid = UUID().uuidString
        newClient.uuid = uuid
        self.listClient[uuid] = newClient
        self.listClientID.append(uuid)
    }
    func removeClient(client : ClientHander){
        let uid = client.uuid
        listClientID.removeObject(object: uid ?? "")
        listClient.removeValue(forKey: uid ?? "")
        // SEND ALL DIS
        DispatchQueue(label: "gs.GSShare.removeClient").async {[unowned self] in
            for c in self.listClientID{
                self.listClient[c]?.sendMessage(data: [52, 13, 10])
            }    
        }
        
    }
    
    
}
