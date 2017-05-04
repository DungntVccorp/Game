//
//  SynchronizedArray.swift
//  P
//
//  Created by Nguyen Dung on 4/19/17.
//
//

import Foundation
public class SynchronizedArray<T> {
    
    private var array: Array<T> = Array<T>()
    
    private let accessQueue = DispatchQueue(label: "SynchronizedArrayAccess", attributes: .concurrent)
    
    public func append(newElement: T) {
        
        self.accessQueue.async(flags:.barrier) {
            self.array.append(newElement)
        }
    }
    
    public func removeAtIndex(index: Int) {
        
        self.accessQueue.async(flags:.barrier) {
            self.array.remove(at: index)
        }
    }
    
    public func removeObjectsInArray(beginIndex : Int , endIndex: Int) {
        self.accessQueue.async(flags:.barrier) {
            self.array.removeSubrange(beginIndex...endIndex)
        }
    }
    
    public func removeAllObject() {
        self.accessQueue.async(flags:.barrier) {
            self.array.removeAll()
        }
    }
    
    public var count: Int {
        var count = 0
        
        self.accessQueue.sync {
            count = self.array.count
        }
        
        return count
    }
    
    public func first() -> T? {
        var element: T?
        
        self.accessQueue.sync {
            if !self.array.isEmpty {
                element = self.array[0]
            }
        }
        
        return element
    }
    
    public func last() -> T? {
        var element: T?
        
        self.accessQueue.sync {
            if !self.array.isEmpty {
                element = self.array.last!
            }
        }
        
        return element
    }
    
    public func allObject() -> [T]? {
        var element: [T]?
        
        self.accessQueue.sync {
            if !self.array.isEmpty {
                element = self.array
            }
        }
        return element
    }
    
    public subscript(index: Int) -> T {
        set {
            self.accessQueue.async(flags:.barrier) {
                self.array[index] = newValue
            }
        }
        get {
            var element: T!
            self.accessQueue.sync {
                element = self.array[index]
            }
            
            return element
        }
    }
}
