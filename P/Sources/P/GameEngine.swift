import Foundation



public class GameEngine{
    
    static let sharedInstance: GameEngine = GameEngine()
    public init() {
        print("Start")
    }
    
    private var listComponent : SynchronizedArray = SynchronizedArray<Component>()
    
    public func registerComponent(component : Component){
        listComponent.append(newElement: component)
    }
    
    public func startEngine(){
        //for com in listComponent
        
        for component in (listComponent.allObject() ?? []).sorted(by: { (c1, c2) -> Bool in
            return c1.priority() >= c2.priority()
        }){
            do{
                try component.loadConfig()
                try component.start()
            }catch{
                debugPrint(error.localizedDescription)
            }
            
        }
        
    }
    
    
}
