import Foundation

var isStart : Bool = true
let gs = SocketSever(port: 4443)

if(gs.startSocket()){
    gs.startHandler()
}
else{
    isStart = false
}
//let gDB = SocketDB()
//gDB.testConnect()

/// KEEP MAIN APPLICATION
if(isStart){
    RunLoop.current.run();
}
