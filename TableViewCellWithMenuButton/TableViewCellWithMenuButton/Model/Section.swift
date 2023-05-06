//
//  Section.swift
//  TableViewCellWithMenuButton
//
//  Created by Zhi Zhou on 2023/5/6.
//

import UIKit

class Section: NSObject {

    var items: [Item] = []
    
    
    init(items: [Item]) {
        self.items = items
    }
    
}
