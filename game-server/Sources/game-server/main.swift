import Foundation
import SwiftRedis

GameEngine.sharedInstance.registerComponent(component: OperationManager())
GameEngine.sharedInstance.registerComponent(component: DatabaseManager())
GameEngine.sharedInstance.registerComponent(component: GameServer())
do{
    try GameEngine.sharedInstance.startEngine()
    RunLoop.current.run()
}catch{
    debugPrint(error.localizedDescription)
}
