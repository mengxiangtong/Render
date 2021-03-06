//
//  ListItemType.swift
//  Render
//
//  Created by Alex Usbergo on 02/05/16.
//
//  Copyright (c) 2016 Alex Usbergo.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

/// If a state represents a unique entity then it should conform to this protocol.
/// - Note: This will just improve the performance in list diffs.
public protocol ComponentStateTypeUniquing {
    
    /// The unique identifier associated to this state (if applicable)
    var stateUniqueIdentifier: String { get }
}

public protocol ListComponentItemDelegate: class {

    /// The item has been selected.
    /// - parameter item: The selected item.
    /// - parameter indexPath: The indexpath for the current item.
    /// - parameter listComponent: The list component view that owns the list item
    func didSelectItem(item: ListComponentItemType, indexPath: NSIndexPath, listComponent: ComponentViewType)
}

public protocol ListComponentItemType {
    
    /// The reuse identifier for the component passed as argument.
    var reuseIdentifier: String { get }
    
    /// The component state.
    var itemState: ComponentStateType { get  set }
    
    /// Additional configuration closure for the component.
    var configuration: ((ComponentViewType) -> Void)? { get }
    
    /// The list item delegate.
    weak var delegate: ListComponentItemDelegate? { get set }
    
    /// Creates a new instance for the associated component.
    func newComponentIstance() -> ComponentViewType
}

public class ListComponentItem<C: ComponentViewType, S: ComponentStateType>: ListComponentItemType {
    
    /// The reuse identifier for the component passed as argument.
    public var reuseIdentifier: String
    
    /// The component state.
    public var itemState: ComponentStateType
    public var state: S {
        return self.itemState as! S
    }
    
    /// Additional configuration closure for the component.
    public var configuration: ((ComponentViewType) -> Void)?
    
    /// The list item delegate.
    public weak var delegate: ListComponentItemDelegate? = nil
    
    public init(reuseIdentifier: String = String(C), state: S, configuration: ((ComponentViewType) -> Void)? = nil) {
        self.reuseIdentifier = reuseIdentifier
        self.itemState = state
        self.configuration = configuration
    }
    
    /// Creates a new instance for the associated component
    public func newComponentIstance() -> ComponentViewType {
        return C() as ComponentViewType
    }
}

//MARK: Equatable workaround

/// Used by the LCS algorithm for calculating the list diff.
struct EquatableWrapper: Equatable {
    let item: ListComponentItemType
}

func ==(lhs: EquatableWrapper, rhs: EquatableWrapper) -> Bool {
    return lhs.item.isEqual(rhs.item)
}

extension ListComponentItemType {
    
    /// Equatable workaround
    func isEqual(other: ListComponentItemType) -> Bool {
        if self.reuseIdentifier != other.reuseIdentifier {
            return false
        }
        if  let ulhs = self.itemState as? ComponentStateTypeUniquing, let urhs = other.itemState as? ComponentStateTypeUniquing {
            return ulhs.stateUniqueIdentifier == urhs.stateUniqueIdentifier
        }
        if let ulhs = self.itemState as? AnyObject, let urhs = self.itemState as? AnyObject {
            return ulhs === urhs
        }
        return false
        
    }
}
