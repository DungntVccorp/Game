//
//  OperationKeepAlive.swift
//  P
//
//  Created by Nguyen Dung on 5/3/17.
//
//
class OperationKeepAlive : ConcurrentOperation{
    
    override func TcpExcute() -> (Int, replyMsg: GSProtocolMessage?) {
        var rep = Pcomm_KeepAlive.Reply()
        rep.apiReply.time = 1234
        rep.apiReply.type = 0
        do{
            let data = try rep.serializedData()
            let msg = GSProtocolMessage()
            msg.headCodeId = GSProtocolMessageType.headCode.profile
            msg.subCodeId = GSProtocolMessageType.subCode.profile_KeepAlive
            msg.protoContent = data
            
            return (0,msg)
        }catch{
            return (-1,nil)
        }
    }
}
