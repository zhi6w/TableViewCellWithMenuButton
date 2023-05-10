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
    
    var image: UIImage?
    
    var menu: UIMenu?
    
    
    init(text: String? = nil, secondaryText: String? = nil, image: UIImage? = nil, menu: UIMenu? = nil) {
        self.text = text
        self.secondaryText = secondaryText
        self.image = image
        self.menu = menu
    }
    
}
