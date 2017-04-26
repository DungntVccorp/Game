//
//  SocketDB.swift
//  GameServer
//
//  Created by Nguyen Dung on 10/1/16.
//
//

import Foundation
import SwiftRedis
import Kassandra

class SocketDB: NSObject {
    
    private var redis : Redis!
    private var kassandra : Kassandra!
    private var hostName = "127.0.0.1"
    private var portRedis : Int32 = 6379
    private var portCassandra : Int32 = 9042
    
    
    convenience init(host : String,portRedis : Int32,portCassandra : Int32) {
        self.init()
        self.hostName = host
        self.portRedis = portRedis
        self.portCassandra = portCassandra
    }
    func startConnectDB() -> Bool{
        // INT CONNECT DB
        self.kassandra = Kassandra(host: self.hostName, port: self.portCassandra)
        self.redis = Redis()
        // INIT CONNECT MEM CACHE
        return true
    }
    
    
    func testConnect(){
        //192.168.20.160
        print("Server Connect DB")
        
        self.kassandra = Kassandra(host: "10.3.3.98", port: 9042)
        try? self.kassandra.connect(oncompletion: { (Result) in
                print("Cassandra Connect Success")
        })
        if(redis == nil){
            redis = Redis()
        }
        redis.connect(host: "10.3.3.98", port: 6379) { (redisError) in
            if let error = redisError {
                print(error)
            }
            else {
                
                redis.auth("8c71db7ace2654497b83e9c8888d0287a800d0a3bb55854aef994de1fda59059") { (err) in
                    if let error = redisError {
                        print(error)
                    }else{
                        print("LOGIN DB SUCCESS")
                        print("==================")
                        print("Redis Connect Success")
                        print("==================")
//                        print("test set value")
//                        redis.set("redis", value: "Dungnt test save", callback: { (done, err) in
//                            if(done){
//                                print("Save Done")
//                            }
//                            else{
//                                print(err)
//                            }
//                        })
                        print("test get value")
                        redis.get("redis", callback: { (string: RedisString?, redisError: NSError?) in
                            if(err == nil){
                                print(string?.asString ?? "")
                                
                            }
                        })
                    }
                }
                
                
                
                
            }
        }
    }
}
