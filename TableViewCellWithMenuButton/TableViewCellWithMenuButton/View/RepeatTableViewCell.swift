//
//  RepeatTableViewCell.swift
//  TableViewCellWithMenuButton
//
//  Created by Zhi Zhou on 2023/5/7.
//

import UIKit

class RepeatTableViewCell: RepeatBasicTableViewCell {

    var item: Item? {
        didSet {
            guard let item = item else { return }
            
            text = item.text
            secondaryText = item.secondaryText
            menu = item.menu
        }
    }

}
