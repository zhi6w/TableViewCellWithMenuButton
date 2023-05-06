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
    
    var isExpanded = false

    
    init(text: String? = nil, secondaryText: String? = nil, isExpanded: Bool = false) {
        self.text = text
        self.secondaryText = secondaryText
        self.isExpanded = isExpanded
    }
    
}
