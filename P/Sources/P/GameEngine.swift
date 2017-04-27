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
    
    public func startEngine() throws {
        //for com in listComponent
        do{
            for component in (listComponent.allObject() ?? []).sorted(by: { (c1, c2) -> Bool in
                return c1.priority() >= c2.priority()
            }){
                try component.loadConfig()
                try component.start()
            }
            
            
            debugPrint("Start Tcp")
            
            tcp = Tcp(self)
            tcp.startTcp()
            
            
            
        }catch{
            throw error
        }
    }
    
    
}
