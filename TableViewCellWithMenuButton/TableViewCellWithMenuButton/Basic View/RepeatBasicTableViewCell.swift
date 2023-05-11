//
//  RepeatBasicTableViewCell.swift
//  TableViewCellWithMenuButton
//
//  Created by Zhi Zhou on 2023/4/10.
//

import UIKit

class RepeatBasicTableViewCell: UITableViewCell {

    private let contextMenuButton = ContextMenuAccessoryButton(type: .custom)
    
    var menu: UIMenu? {
        didSet {
            guard let menu = menu else { return }
            
            contextMenuButton.menu = menu
            contextMenuButton.showsMenuAsPrimaryAction = true
        }
    }
    
    private let disclosureIndicatorView = UIImageView()

    public let menuInteractionWillDisplay = Delegate<Void, Void>()
    public let menuInteractionWillEnd = Delegate<Void, Void>()
    public let longPressBegan = Delegate<Void, Void>()
    public let longPressEnded = Delegate<Void, Void>()
    
    private let leftImageView = UIImageView()
    private let primaryLabel = UILabel()
    private let secondaryButton = UIButton()
    
    /// primaryLabel 首行文字前部的缩进。
    let primaryLabelFirstLineHeadIndent: CGFloat = 16
    
    /// 控件垂直间距。
    private let verticalSpacing: CGFloat = 4
    
    private let defaultLayoutMarginsTop: CGFloat = 11
    
    private var horizontalLayoutConstraints: [NSLayoutConstraint] = []
    private var verticalLayoutConstraints: [NSLayoutConstraint] = []
    private var verticalAccessibilityLayoutConstraints: [NSLayoutConstraint] = []
    
    var isVerticalLayout = false
    var isHorizontalLayout = false
    
    /// 压缩状态下的视图。
    let compressedContentView = UIView()

    var text: String? {
        didSet {
            if traitCollection.preferredContentSizeCategory >= .accessibilityMedium {
                // 大字体
                leftImageView.layoutIfNeeded()
                indentLabel(primaryLabel, text: text, firstLineHeadIndent: leftImageView.bounds.width + primaryLabelFirstLineHeadIndent)
            } else {
                indentLabel(primaryLabel, text: text, firstLineHeadIndent: 0)
            }
        }
    }

    var secondaryText: String? {
        didSet {
            secondaryButton.setTitle(secondaryText, for: .normal)
        }
    }
    
    var image: UIImage? {
        didSet {
            leftImageView.image = image

            if traitCollection.preferredContentSizeCategory >= .accessibilityMedium {
                // 大字体
                leftImageView.layoutIfNeeded()
                indentLabel(primaryLabel, text: text, firstLineHeadIndent: leftImageView.bounds.width + primaryLabelFirstLineHeadIndent)
            } else {
                indentLabel(primaryLabel, text: text, firstLineHeadIndent: 0)
            }
        }
    }
 
    override var accessoryType: UITableViewCell.AccessoryType {
        didSet {
            super.accessoryType = .none
        }
    }
    
    override var accessoryView: UIView? {
        didSet {
            super.accessoryView = nil
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        setupInterface()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        
        // 当 text、secondaryText 都为空时，设定 text 为一个空格，用来撑起 cell 的高度。
        if text == nil, secondaryText == nil {
            text = " "
        }
    
        let size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
        
        /*
         只有在标准字体下才判断：是否因为水平布局下两个 label 的内容过多，导致水平空间不够，需要切换为垂直布局。
         大字体下默认就已经是垂直布局，所以不需要进行下一步操作。
         */
        let isAccessibilityCategory = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        if isAccessibilityCategory {
            return size
        }

        let height = layoutContentView()
                        
        // 在 tableView 自动布局下，返回正确的高度。
        return CGSize(width: size.width, height: height)
    }

}

extension RepeatBasicTableViewCell {
    
    private func setupInterface() {
        
        clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(contentSizeCategoryDidChange(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
        
        setupCompressedContentView()
        setupLeftImageView()
        setupPrimaryLabel()
        setupSecondaryButton()
        setupContextMenuButton()
        
        setupLayoutConstraints()
        updateLayoutConstraints()
    }
    
    private func setupCompressedContentView() {
                
        contentView.addSubview(compressedContentView)
        
        compressedContentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            compressedContentView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            compressedContentView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            compressedContentView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor)
        ])
    }
    
    private func setupLeftImageView() {
        
        leftImageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        
        leftImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        compressedContentView.addSubview(leftImageView)
        
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupPrimaryLabel() {
//        primaryLabel.text = " "
        primaryLabel.adjustsFontForContentSizeCategory = true
        primaryLabel.numberOfLines = 0
        primaryLabel.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .regular)
        
        compressedContentView.addSubview(primaryLabel)
        
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 在垂直状态下，以较低的优先级抗拉伸。保证 label 与 secondaryButton 在垂直布局时不发生布局冲突错误。
        primaryLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    private func setupSecondaryButton() {
        
        secondaryButton.isUserInteractionEnabled = false
        
        // 使用 button 来进行展示，为了明确自动布局，防止出现 lessThanEqual 的布局形式导致的高度计算错误（例如：旋转屏幕时）。
        secondaryButton.setTitleColor(.secondaryLabel, for: .normal)
        secondaryButton.titleLabel?.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .regular)
        secondaryButton.titleLabel?.adjustsFontForContentSizeCategory = true
        secondaryButton.adjustsImageSizeForAccessibilityContentSizeCategory = true
        secondaryButton.setImage(UIImage(systemName: "chevron.up.chevron.down", withConfiguration: UIImage.SymbolConfiguration(scale: .small))?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal), for: .normal)

        updateSecondaryButtonContentHorizontalAlignment(.trailing)

        compressedContentView.addSubview(secondaryButton)
        
        secondaryButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupDisclosureIndicatorView() {
        
        disclosureIndicatorView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        disclosureIndicatorView.image = UIImage(systemName: "chevron.up.chevron.down", withConfiguration: UIImage.SymbolConfiguration(textStyle: .subheadline, scale: .small))?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal) // 使用 UIImage.SymbolConfiguration(textStyle:) 保证图片能适配可访问性文本大小设置。

        compressedContentView.addSubview(disclosureIndicatorView)
        
        disclosureIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        disclosureIndicatorView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    private func setupContextMenuButton() {
        
        // 将 contextMenuButton 文字设定为一个空格，方便 menu 弹出菜单的定位。
        contextMenuButton.setTitle(" ", for: .normal)
        contextMenuButton.contentHorizontalAlignment = .trailing

        contextMenuButton.menuWillDisplayTriggered.delegate(on: self) { (self) in
            self.menuInteractionWillDisplay.callAsFunction()
        }
        
        contextMenuButton.menuWillEndTriggered.delegate(on: self) { (self) in
            self.menuInteractionWillEnd.callAsFunction()
        }
        
        contextMenuButton.longPressBeganTriggered.delegate(on: self) { (self) in
            self.longPressBegan.callAsFunction()
        }
        
        contextMenuButton.longPressEndedTriggered.delegate(on: self) { (self) in
            self.longPressEnded.callAsFunction()
        }

        addSubview(contextMenuButton)
        contextMenuButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contextMenuButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contextMenuButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contextMenuButton.topAnchor.constraint(equalTo: self.topAnchor),
            contextMenuButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
}

extension RepeatBasicTableViewCell {
    
    @objc private func contentSizeCategoryDidChange(_ notification: Notification) {
        updateLayoutConstraints()
    }
    
    private func setupLayoutConstraints() {
                
        horizontalLayoutConstraints = [
            // Left Image View
            leftImageView.leadingAnchor.constraint(equalTo: compressedContentView.leadingAnchor),
            leftImageView.centerYAnchor.constraint(equalTo: primaryLabel.centerYAnchor),
            
            // Primary Label
            primaryLabel.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: primaryLabelFirstLineHeadIndent),
            primaryLabel.topAnchor.constraint(equalTo: compressedContentView.topAnchor),
            primaryLabel.bottomAnchor.constraint(equalTo: compressedContentView.bottomAnchor),
            
            // Secondary Button
            secondaryButton.trailingAnchor.constraint(equalTo: compressedContentView.trailingAnchor),
            secondaryButton.topAnchor.constraint(equalTo: primaryLabel.topAnchor),
            secondaryButton.bottomAnchor.constraint(equalTo: primaryLabel.bottomAnchor),
            
            // Compressed Content View
            compressedContentView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor)
        ]
  
        verticalLayoutConstraints = [
            // Left Image View
            leftImageView.leadingAnchor.constraint(equalTo: compressedContentView.leadingAnchor),
            leftImageView.centerYAnchor.constraint(equalTo: compressedContentView.centerYAnchor),
            
            // Primary Label
            primaryLabel.leadingAnchor.constraint(equalTo: leftImageView.trailingAnchor, constant: primaryLabelFirstLineHeadIndent),
            primaryLabel.trailingAnchor.constraint(equalTo: compressedContentView.trailingAnchor),
            primaryLabel.topAnchor.constraint(equalTo: compressedContentView.topAnchor),
            
            // Secondary Button
            secondaryButton.leadingAnchor.constraint(equalTo: primaryLabel.leadingAnchor),
            secondaryButton.trailingAnchor.constraint(equalTo: primaryLabel.trailingAnchor),
            secondaryButton.topAnchor.constraint(equalTo: primaryLabel.bottomAnchor, constant: verticalSpacing),
            secondaryButton.bottomAnchor.constraint(equalTo: compressedContentView.bottomAnchor),
            
            // Compressed Content View
            compressedContentView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor)
        ]
        
        // 大字体下的垂直布局。
        verticalAccessibilityLayoutConstraints = [
            // Left Image View
            leftImageView.leadingAnchor.constraint(equalTo: compressedContentView.leadingAnchor),
            leftImageView.topAnchor.constraint(equalTo: compressedContentView.topAnchor),
            
            // Primary Label
            primaryLabel.leadingAnchor.constraint(equalTo: compressedContentView.leadingAnchor),
            primaryLabel.trailingAnchor.constraint(equalTo: compressedContentView.trailingAnchor),
            primaryLabel.topAnchor.constraint(equalTo: compressedContentView.topAnchor),
                        
            // Secondary Label
            secondaryButton.leadingAnchor.constraint(equalTo: primaryLabel.leadingAnchor),
            secondaryButton.trailingAnchor.constraint(equalTo: primaryLabel.trailingAnchor),
            secondaryButton.topAnchor.constraint(equalTo: primaryLabel.bottomAnchor, constant: verticalSpacing),
            
            // lessThanOrEqualTo 保证 secondaryLabel 不会在收缩动画还未结束时，出现跳动的问题。同时为了防止出现模糊约束的警告。
            secondaryButton.bottomAnchor.constraint(equalTo: compressedContentView.bottomAnchor),
            
            // Compressed Content View
            compressedContentView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor)
        ]
    }
    
    private func updateLayoutConstraints() {
        
        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            // 大字体下的布局更新
            setupVerticalAccessibilityLayoutConstraints()
            
            isVerticalLayout = true
            isHorizontalLayout = false
        } else {
            // 标准字体下的布局更新。
            layoutContentView()
        }
    }
    
    /// 标准字体状态的水平布局。
    private func setupHorizontalLayoutConstraints() {
        NSLayoutConstraint.deactivate(verticalLayoutConstraints)
        NSLayoutConstraint.deactivate(verticalAccessibilityLayoutConstraints)
        NSLayoutConstraint.activate(horizontalLayoutConstraints)

        updateSecondaryButtonContentHorizontalAlignment(.trailing)
        updateContextMenuButtonContentHorizontalAlignment(.trailing)
        
        var configuration = contextMenuButton.configuration ?? UIButton.Configuration.plain()
        configuration.contentInsets.leading = 0
        contextMenuButton.configuration = configuration
    }
    
    /// 标准字体状态的垂直布局。
    private func setupVerticalLayoutConstraints() {
        NSLayoutConstraint.deactivate(horizontalLayoutConstraints)
        NSLayoutConstraint.deactivate(verticalAccessibilityLayoutConstraints)
        NSLayoutConstraint.activate(verticalLayoutConstraints)
        
        updateSecondaryButtonContentHorizontalAlignment(.leading)
        updateContextMenuButtonContentHorizontalAlignment(.leading)
        
        leftImageView.layoutIfNeeded()
        var configuration = contextMenuButton.configuration ?? UIButton.Configuration.plain()
        configuration.contentInsets.leading = layoutMargins.left + ((leftImageView.bounds.width == 0) ? 0 : leftImageView.bounds.width + primaryLabelFirstLineHeadIndent)
        contextMenuButton.configuration = configuration
    }
    
    /// 大字体状态的垂直布局。
    private func setupVerticalAccessibilityLayoutConstraints() {
        NSLayoutConstraint.deactivate(horizontalLayoutConstraints)
        NSLayoutConstraint.deactivate(verticalLayoutConstraints)
        NSLayoutConstraint.activate(verticalAccessibilityLayoutConstraints)
        
        updateSecondaryButtonContentHorizontalAlignment(.leading)
        updateContextMenuButtonContentHorizontalAlignment(.leading)
        
        var configuration = contextMenuButton.configuration ?? UIButton.Configuration.plain()
        configuration.contentInsets.leading = 0
        contextMenuButton.configuration = configuration
    }
    
    /// 计算 label 的真实高度。
    private func heightFor(label: UILabel, at width: CGFloat) -> CGFloat {
        
        let maxSize = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let textHeight = label.sizeThatFits(maxSize).height
        let lineHeight = label.font.lineHeight
        let numberOfLines = lroundf(Float(textHeight / lineHeight))
                
        let oneLineHeight = label.textRect(forBounds: contentView.bounds, limitedToNumberOfLines: 1).height
                
        return oneLineHeight * CGFloat(numberOfLines)
    }
    
    private func indentLabel(_ label: UILabel, text: String?, firstLineHeadIndent: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = firstLineHeadIndent // 第一行的前方缩进空白。
//        paragraphStyle.headIndent = 10 // 除了第一行之外其他行的前方缩进空白。
        
        guard let text = text else { return }
                        
        label.attributedText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
    }
    
    /// 布局计算 cell。
    @discardableResult
    private func layoutContentView() -> CGFloat {
        // 先切换为单行显示，计算出 label 内文字的真实宽度。
        primaryLabel.numberOfLines = 1
        primaryLabel.sizeToFit()
        primaryLabel.numberOfLines = 0 // 然后再恢复为多行显示。

        // 计算按钮的宽高。
        secondaryButton.layoutIfNeeded()
        secondaryButton.sizeToFit()

        let secondaryButtonWidth = secondaryButton.bounds.width
        let secondaryButtonHeight = secondaryButton.bounds.height //secondaryButton.titleLabel?.bounds.height ?? 0

        // 水平布局时，primaryLabel 与 secondaryButton 显示区域的宽度。
        var viewsAreaWidth = contentView.bounds.width - layoutMargins.left - layoutMargins.right
        
        leftImageView.layoutIfNeeded()
        viewsAreaWidth -= leftImageView.bounds.width
        viewsAreaWidth -= (leftImageView.bounds.width != 0 ? primaryLabelFirstLineHeadIndent : 0)

        // primaryLabel 在单行显示下，内容的宽度。
        let viewsWidth = primaryLabel.bounds.width + secondaryButtonWidth

        // 计算多行显示下，primaryLabel 的高度。
        let primaryLabelHeight = heightFor(label: primaryLabel, at: viewsAreaWidth)
        
        var height: CGFloat = 0

        // 当两个控件的水平单行宽度超出两个控件的显示区域宽度时，改为垂直布局；否则为水平布局。
        if viewsWidth < viewsAreaWidth {
            // 水平布局
            setupHorizontalLayoutConstraints()
            isHorizontalLayout = true
            isVerticalLayout = false
            
            height = (primaryLabelHeight == 0 ? secondaryButtonHeight : primaryLabelHeight) + layoutMargins.top + layoutMargins.bottom
        } else {
            // 垂直布局
            setupVerticalLayoutConstraints()

            isHorizontalLayout = false
            isVerticalLayout = true
            
            height = primaryLabelHeight + secondaryButtonHeight + layoutMargins.top + layoutMargins.bottom + verticalSpacing
        }
        
        return height
    }
    
    /// 更新占位按钮的水平对齐。
    ///
    /// 水平对齐的位置决定了弹出的 menu 锚点位置。
    private func updateContextMenuButtonContentHorizontalAlignment(_ alignment: UIControl.ContentHorizontalAlignment) {

        contextMenuButton.contentVerticalAlignment = .bottom
                
        var contextMenuButtonConfiguration = contextMenuButton.configuration ?? UIButton.Configuration.plain()
        
        switch alignment {
        case .leading:
            contextMenuButton.contentHorizontalAlignment = .leading
            contextMenuButtonConfiguration.contentInsets.leading = directionalLayoutMargins.leading
            
        case .left:
            contextMenuButton.contentHorizontalAlignment = .left
            contextMenuButtonConfiguration.contentInsets.leading = directionalLayoutMargins.leading
            
        case .trailing:
            contextMenuButton.contentHorizontalAlignment = .trailing
            contextMenuButtonConfiguration.contentInsets.trailing = directionalLayoutMargins.trailing
            
        case .right:
            contextMenuButton.contentHorizontalAlignment = .right
            contextMenuButtonConfiguration.contentInsets.trailing = directionalLayoutMargins.trailing
            
        default:
            break
        }
        
        contextMenuButton.configuration = contextMenuButtonConfiguration
    }
    
    /// 更新 secondaryButton 的水平对齐。
    private func updateSecondaryButtonContentHorizontalAlignment(_ alignment: UIControl.ContentHorizontalAlignment) {
        
        var configuration = secondaryButton.configuration ?? UIButton.Configuration.plain()
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 8
        
        switch alignment {
        case .leading:
            secondaryButton.contentHorizontalAlignment = .leading
            configuration.contentInsets.leading = 0
            
        case .left:
            secondaryButton.contentHorizontalAlignment = .left
            configuration.contentInsets.leading = 0
            
        case .trailing:
            secondaryButton.contentHorizontalAlignment = .trailing
            configuration.contentInsets.trailing = 0
            
        case .right:
            secondaryButton.contentHorizontalAlignment = .right
            configuration.contentInsets.trailing = 0
            
        default:
            break
        }

        secondaryButton.configuration = configuration
    }
    
}

