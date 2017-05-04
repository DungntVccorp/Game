import Foundation



public class GameEngine{
    
    //MARK: - 💤 LazyLoad Method
    private var tcp : Tcp!
    
    
    
    static let sharedInstance: GameEngine = GameEngine()
    public init() {
        print("Start")
        
    }
    
    private var listComponent : SynchronizedArray = SynchronizedArray<Component>()
    
    public func registerComponent(component : Component){
        listComponent.append(newElement: component)
    }
    
    public func getComponent(_ type : ComponentType) -> Component?{
        for c in (listComponent.allObject() ?? []){
            if(c.ComponentType() == type){
                return c
            }
        }
        return nil
    }
    
    public func startEngine() throws {
        //for com in listComponent
        do{
            for component in (listComponent.allObject() ?? []).sorted(by: { (c1, c2) -> Bool in
                return c1.priority() < c2.priority()
            }){
                try component.loadConfig()
                try component.start()
            }
            
            for c in (listComponent.allObject() ?? []){
                if(c.ComponentType() == .GS){
                    tcp = Tcp(c as! GameServer)
                    tcp.startTcp()
                    break
                }
            }
        }catch{
            throw error
        }
    }
    
    
    
    
}
