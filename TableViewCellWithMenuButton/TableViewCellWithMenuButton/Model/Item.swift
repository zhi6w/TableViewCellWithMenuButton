//
//  Item.swift
//  TableViewCellWithMenuButton
//
//  Created by Zhi Zhou on 2023/5/6.
//

import UIKit

class Item: NSObject {

    var text: String?
    
    var secondaryText: String?
    
    var menu: UIMenu?
    
    
    init(text: String? = nil, secondaryText: String? = nil, menu: UIMenu? = nil, isExpanded: Bool = false) {
        self.text = text
        self.secondaryText = secondaryText
        self.menu = menu
    }
    
}
