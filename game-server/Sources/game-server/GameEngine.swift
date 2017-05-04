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
        listComponent.append(component)
    }
    
    public func getComponent(_ type : ComponentType) -> Component?{
        let l = listComponent.filter { (c : Component) -> Bool in
            return c.ComponentType() == type
        }
        if(l.count == 1){
            return l.first
        }else{
            return nil
        }
    }
    
    public func startEngine() throws {
        //for com in listComponent
        do{
            
            for component in listComponent.sorted(by: { (c1, c2) -> Bool in
                return c1.priority() < c2.priority()
            }){
                try component.loadConfig()
                try component.start()
            }
            if let gs = listComponent.first(where: { (c : Component) -> Bool in
                return c.ComponentType() == .GS
            }) as? GameServer{
                tcp = Tcp(gs)
                tcp.startTcp()
            }
        }catch{
            throw error
        }
    }
    
    
    
    
}
