import Foundation
import SwiftRedis

//let redis = Redis()
//
//redis.connect(host: "127.0.0.1", port: 6379) { (er) in
//    print("Connected to Redis")
//    redis.auth("password123", callback: { (er) in
//        
//        print("authenticated to redis")
//        
//        redis.set("Redis", value: "on Swift") { (result: Bool, redisError: NSError?) in
//            if let error = redisError {
//                print(error)
//            }
//            // get the same key
//            redis.get("Redis") { (string: RedisString?, redisError: NSError?) in
//                if let error = redisError {
//                    print(error)
//                }
//                else if let string = string?.asString {
//                    print("Redis \(string)")
//                }
//            }
//        }
//    })
//    
//}

GameEngine.sharedInstance.registerComponent(component: DatabaseManager())
GameEngine.sharedInstance.registerComponent(component: GameServer())

GameEngine.sharedInstance.startEngine()
RunLoop.current.run()
