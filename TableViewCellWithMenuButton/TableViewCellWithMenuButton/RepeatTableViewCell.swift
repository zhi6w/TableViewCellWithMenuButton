//
//  RepeatTableViewCell.swift
//  TableViewCellWithMenuButton
//
//  Created by Zhi Zhou on 2023/4/10.
//

import UIKit

class RepeatTableViewCell: UITableViewCell {

    private let contextMenuButton = ContextMenuAccessoryButton(type: .custom)
    
    var menu: UIMenu? {
        didSet {
            guard let menu = menu else { return }
            
            var contentConfiguration = self.contentConfiguration as? UIListContentConfiguration
            contentConfiguration?.secondaryText = " "

            self.contentConfiguration = contentConfiguration
            
            contextMenuButton.menu = menu
            contextMenuButton.showsMenuAsPrimaryAction = true
        }
    }
    
    var detailText: String? {
        didSet {
            contextMenuButton.setTitle(detailText, for: .normal)
        }
    }

    let menuInteractionWillDisplay = Delegate<Void, Void>()
    let menuInteractionWillEnd = Delegate<Void, Void>()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value2, reuseIdentifier: reuseIdentifier)

        setupInterface()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentSizeCategoryDidChange()
    }

}

extension RepeatTableViewCell {
    
    private func setupInterface() {
        var contentConfiguration = defaultContentConfiguration()
        contentConfiguration.text = " "

        self.contentConfiguration = contentConfiguration

        setupContextMenuButton()
    }
    
    private func setupContextMenuButton() {
        
        if #unavailable(iOS 15.0) {
            // iOS 14 使用系统图片无法进行自动大小缩放，所以只能自定义图片，并选中 Preserve Vector Data。
            contextMenuButton.setImage(UIImage(named: "chevron.up.chevron.down")?.withConfiguration(UIImage.SymbolConfiguration(scale: .small)).withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal), for: .normal)
            contextMenuButton.setImage(UIImage(named: "chevron.up.chevron.down")?.withConfiguration(UIImage.SymbolConfiguration(scale: .small)).withTintColor(.tertiaryLabel, renderingMode: .alwaysOriginal), for: .highlighted)
        } else {
            contextMenuButton.setImage(UIImage(systemName: "chevron.up.chevron.down", withConfiguration: UIImage.SymbolConfiguration(scale: .small))?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal), for: .normal)
            contextMenuButton.setImage(UIImage(systemName: "chevron.up.chevron.down", withConfiguration: UIImage.SymbolConfiguration(scale: .small))?.withTintColor(.tertiaryLabel, renderingMode: .alwaysOriginal), for: .highlighted)
        }
        
        contextMenuButton.setTitleColor(.secondaryLabel, for: .normal)
        contextMenuButton.setTitleColor(.tertiaryLabel, for: .highlighted)
        
        if #unavailable(iOS 15.0) {
            contextMenuButton.titleLabel?.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .regular)
        } else {
            contextMenuButton.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
        }

        contextMenuButton.titleLabel?.adjustsFontForContentSizeCategory = true
        contextMenuButton.adjustsImageSizeForAccessibilityContentSizeCategory = true

        contentView.addSubview(contextMenuButton)
        contextMenuButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contextMenuButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contextMenuButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contextMenuButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            contextMenuButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        contextMenuButton.contentHorizontalAlignment = .right

        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
            configuration.imagePlacement = .trailing
            configuration.imagePadding = layoutMargins.right
            contextMenuButton.configuration = configuration

        } else {
            contextMenuButton.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft // 将按钮内图片与文字位置调换。

            contextMenuButton.contentEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 20)
            // 因为通过设定特殊的阿拉伯语本地化适配，所以阅读顺序为从右到左。
            contextMenuButton.imageEdgeInsets = .init(top: 0, left: layoutMargins.right, bottom: 0, right: -layoutMargins.right)
        }
    }
    
}

extension RepeatTableViewCell {
    
    private func contentSizeCategoryDidChange() {
        
        let isAccessibilityCategory = traitCollection.preferredContentSizeCategory.isAccessibilityCategory

        contextMenuButton.layoutIfNeeded()

        if isAccessibilityCategory {
            // 超大字体
            contextMenuButton.contentHorizontalAlignment = .left
            
            let buttonTitleLabelHeight = contextMenuButton.titleLabel?.bounds.height ?? 0
            let contentVerticalMargin = contentView.bounds.height - buttonTitleLabelHeight * 2 - layoutMargins.top - layoutMargins.bottom

            if #available(iOS 15.0, *) {
                var configuration = contextMenuButton.configuration
                configuration?.contentInsets = .init(top: contentVerticalMargin, leading: layoutMargins.left, bottom: -(contextMenuButton.titleLabel?.bounds.height ?? 0), trailing: layoutMargins.right)
                
                contextMenuButton.configuration = configuration
            } else {
                contextMenuButton.contentEdgeInsets = .init(top: contentVerticalMargin, left: layoutMargins.left, bottom: -(contextMenuButton.titleLabel?.bounds.height ?? 0), right: 0)
            }
        }
        else {
            // 标准字体
            contextMenuButton.contentHorizontalAlignment = .right

            if #available(iOS 15.0, *) {
                var configuration = contextMenuButton.configuration
                configuration?.contentInsets = .init(top: 0, leading: layoutMargins.left, bottom: 0, trailing: layoutMargins.right)

                contextMenuButton.configuration = configuration
            } else {
                contextMenuButton.contentEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: layoutMargins.left)
            }
        }
    }
    
}

