//
//  Delegate.swift
//  TableViewCellWithMenuButton
//
//  Created by Zhi Zhou on 2023/4/10.
//

import UIKit

open class Delegate<Input, Output>: NSObject {
    
    private var callback: ((Input) -> Output?)?
    
    open var isDelegateSet: Bool {
        return callback != nil
    }
    
    
    open func delegate<T: AnyObject>(on target: T, callback: ((T, Input) -> Output)?) {
        
        self.callback = {
            [weak target] (input) in
            
            guard let target = target else { return nil }
            
            return callback?(target, input)
        }
    }
    
//    open func call(_ input: Input) -> Output? {
//        return callback?(input)
//    }
    
    open func callAsFunction(_ input: Input) -> Output? {
        return callback?(input)
    }
    
}

extension Delegate {
    
    public func removeDelegate() {
        self.callback = nil
    }
    
}

// MARK:- Input 全部为 Void
extension Delegate where Input == Void {
    
    public func delegate<T: AnyObject>(on target: T, callback: ((T) -> Output)?) {
        
        self.callback = {
            [weak target] (_) in
            
            guard let target = target else { return nil }
            
            return callback?(target)
        }
    }
    
//    open func call() -> Output? {
//        return self.call(())
//    }
    
    public func callAsFunction() -> Output? {
        return callback?(())
    }
    
}
