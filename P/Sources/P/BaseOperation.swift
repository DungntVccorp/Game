//
//  BaseOperation.swift
//  P
//
//  Created by Nguyen Dung on 4/27/17.
//
//

import Foundation

open class BaseOperation :  Operation{
    open override func main() {
        debugPrint("main Operation")
    }
    open override func cancel() {
        debugPrint("Cancel Operation")
    }
}
