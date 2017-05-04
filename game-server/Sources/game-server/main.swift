import Foundation

import HeliumLogger
import LoggerAPI

/// CONFIG LOG

HeliumLogger.use()

GameEngine.sharedInstance.registerComponent(component: OperationManager())
GameEngine.sharedInstance.registerComponent(component: DatabaseManager())
GameEngine.sharedInstance.registerComponent(component: GameServer())
do{
    try GameEngine.sharedInstance.startEngine()
    RunLoop.current.run()
}catch{
    Log.error(error.localizedDescription)
}
