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
            
            contextMenuButton.menu = menu
            contextMenuButton.showsMenuAsPrimaryAction = true
        }
    }
    
    private let disclosureIndicatorView = UIImageView()

    public let menuInteractionWillDisplay = Delegate<Void, Void>()
    public let menuInteractionWillEnd = Delegate<Void, Void>()
    public let longPressBegan = Delegate<Void, Void>()
    public let longPressEnded = Delegate<Void, Void>()
    
    private let primaryLabel = UILabel()
    private let secondaryLabel = UILabel()
    
    /// 控件垂直间距。
    private let verticalSpacing: CGFloat = 4
    
    private var horizontalLayoutConstraints: [NSLayoutConstraint] = []
    private var verticalLayoutConstraints: [NSLayoutConstraint] = []
    
    var isVerticalLayout = false
    var isHorizontalLayout = false
    
    private var compressedSizeLayoutConstraints: [NSLayoutConstraint] = []
    private var expandedSizeLayoutConstraints: [NSLayoutConstraint] = []
        
    /// 展开状态下的视图。
    let expandedContentView = UIView()
    
    var isExpanded = false
    
    /// 展开视图的内容高度。
    private var expandedContentViewHeight: CGFloat {
        if isExpanded {
            UIView.animate(withDuration: 0.25) {
                self.expandedContentView.alpha = 1
            }
            
            return expandedContentView.bounds.height
        }
        else {
            UIView.animate(withDuration: 0.25) {
                self.expandedContentView.alpha = 0
            }
            
            return 0
        }
    }
    
    var text: String? {
        didSet {
            primaryLabel.text = text

//            let paragraphStyle = NSMutableParagraphStyle()
//            paragraphStyle.firstLineHeadIndent = 10 // 第一行的前方缩进空白。
////            paragraphStyle.headIndent = 10 // 除了第一行之外其他行的前方缩进空白。
//
//            primaryLabel.attributedText = NSAttributedString(string: text ?? " ", attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        }
    }

    var secondaryText: String? {
        didSet {
            secondaryLabel.text = secondaryText
        }
    }
    
    var item: Item? {
        didSet {
            guard let item = item else { return }
            
            text = item.text
            secondaryText = item.secondaryText
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
        
        /* 只有在标准字体下才判断：是否因为水平布局下两个 label 的内容过多，导致水平空间不够，需要切换为垂直布局。
           大字体下默认就已经是垂直布局，所以不需要进行下一步操作。
         */
        let isAccessibilityCategory = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        if isAccessibilityCategory {
            return .init(width: size.width, height: size.height + expandedContentViewHeight)
        }

        // 先切换为单行显示，计算出 label 内文字的真实宽度。
        primaryLabel.numberOfLines = 1
        primaryLabel.sizeToFit()
        primaryLabel.numberOfLines = 0 // 然后再恢复为多行显示。

        // 先切换为单行显示，计算出 label 内文字的真实宽度。
        secondaryLabel.numberOfLines = 1
        secondaryLabel.sizeToFit()
        secondaryLabel.numberOfLines = 0 // 然后再恢复为多行显示。

        // 水平布局时，两个 label 显示区域的宽度。
        let labelsAreaWidth = contentView.bounds.width - layoutMargins.left - layoutMargins.right

        // label 在单行显示下，文字内容的宽度。
        let labelsWidth = primaryLabel.bounds.width + secondaryLabel.bounds.width

        // 计算多行显示下，label 的高度。
        let primaryLabelHeight = heightFor(label: primaryLabel, at: labelsAreaWidth)
        let secondaryLabelHeight = heightFor(label: secondaryLabel, at: labelsAreaWidth)
        
        var height: CGFloat = 0

        // 当两个 label 的水平单行文字宽度超出两个 label 的显示区域宽度时，改为垂直布局；否则为水平布局。
        if labelsWidth < labelsAreaWidth {
            // 水平布局
            setupHorizontalLayoutConstraints()
            isHorizontalLayout = true
            isVerticalLayout = false
            
            height = (primaryLabelHeight == 0 ? secondaryLabelHeight : primaryLabelHeight) + layoutMargins.top + layoutMargins.bottom
        } else {
            // 垂直布局
            setupVerticalLayoutConstraints()
            isHorizontalLayout = false
            isVerticalLayout = true
            
            height = primaryLabelHeight + secondaryLabelHeight + layoutMargins.top + layoutMargins.bottom + verticalSpacing
        }
        
        height += expandedContentViewHeight

        // 在 tableView 自动布局下，返回正确的高度。
        return CGSize(width: size.width, height: height)
    }

}

extension RepeatTableViewCell {
    
    private func setupInterface() {
        
        clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(contentSizeCategoryDidChange(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)

        setupPrimaryLabel()
        setupSecondaryLabel()
        setupDisclosureIndicatorView()
        setupExpandedView()
        setupContextMenuButton()
        
        setupLayoutConstraints()
        updateLayoutConstraints()
    }
    
    private func setupPrimaryLabel() {
//        primaryLabel.text = " "
        primaryLabel.adjustsFontForContentSizeCategory = true
        primaryLabel.numberOfLines = 0
        primaryLabel.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .regular)
        
        contentView.addSubview(primaryLabel)
        
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 在垂直状态下，已较低的优先级抗拉伸。保证两个 label 在垂直布局时不发生布局冲突错误。
        primaryLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
    
    private func setupSecondaryLabel() {
//        secondaryLabel.text = " "
        secondaryLabel.adjustsFontForContentSizeCategory = true
        secondaryLabel.numberOfLines = 0
        secondaryLabel.font = .systemFont(ofSize: UIFont.preferredFont(forTextStyle: .headline).pointSize, weight: .regular)
        secondaryLabel.textColor = .secondaryLabel
        
        contentView.addSubview(secondaryLabel)
        
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 在垂直状态下，已较高的优先级抗拉伸。保证两个 label 在垂直布局时不发生布局冲突错误。
        secondaryLabel.setContentHuggingPriority(.defaultLow + 1, for: .vertical)
    }
    
    private func setupDisclosureIndicatorView() {
        
        disclosureIndicatorView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        disclosureIndicatorView.image = UIImage(systemName: "chevron.up.chevron.down", withConfiguration: UIImage.SymbolConfiguration(textStyle: .subheadline, scale: .small))?.withTintColor(.secondaryLabel, renderingMode: .alwaysOriginal) // 使用 UIImage.SymbolConfiguration(textStyle:) 保证图片能适配可访问性文本大小设置。

        contentView.addSubview(disclosureIndicatorView)
        
        disclosureIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupExpandedView() {

        contentView.addSubview(expandedContentView)
        
        expandedContentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupContextMenuButton() {

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

extension RepeatTableViewCell {
    
    @objc private func contentSizeCategoryDidChange(_ notification: Notification) {
        updateLayoutConstraints()
    }
    
    private func setupLayoutConstraints() {
                
        horizontalLayoutConstraints = [
            // primaryLabel
            primaryLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            primaryLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            
            // lessThanOrEqualTo 保证 primaryLabel 不会在收缩动画还未结束时，出现跳动的问题。同时为了防止出现模糊约束的警告。
            primaryLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),
            
            // secondaryLabel
//            secondaryLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            secondaryLabel.topAnchor.constraint(equalTo: primaryLabel.topAnchor),
            secondaryLabel.bottomAnchor.constraint(equalTo: primaryLabel.bottomAnchor),
            
            // disclosureIndicatorView
            disclosureIndicatorView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            disclosureIndicatorView.leadingAnchor.constraint(equalTo: secondaryLabel.trailingAnchor, constant: 8),
            disclosureIndicatorView.centerYAnchor.constraint(equalTo: secondaryLabel.centerYAnchor)
        ]
  
        verticalLayoutConstraints = [
            // primaryLabel
            primaryLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            primaryLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            primaryLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
                        
            // secondaryLabel
            secondaryLabel.leadingAnchor.constraint(equalTo: primaryLabel.leadingAnchor),
//            secondaryLabel.trailingAnchor.constraint(equalTo: primaryLabel.trailingAnchor),
//            secondaryLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: primaryLabel.lastBaselineAnchor, multiplier: 1.0),
            secondaryLabel.topAnchor.constraint(equalTo: primaryLabel.bottomAnchor, constant: verticalSpacing),
            
            // lessThanOrEqualTo 保证 secondaryLabel 不会在收缩动画还未结束时，出现跳动的问题。同时为了防止出现模糊约束的警告。
            secondaryLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor),
            
            // disclosureIndicatorView
            disclosureIndicatorView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor),
            disclosureIndicatorView.leadingAnchor.constraint(equalTo: secondaryLabel.trailingAnchor, constant: 8),
            disclosureIndicatorView.centerYAnchor.constraint(equalTo: secondaryLabel.centerYAnchor)
        ]
        
        /* ------------------------------------------------------------ */
        
        compressedSizeLayoutConstraints = [
            expandedContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            expandedContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            expandedContentView.topAnchor.constraint(equalTo: secondaryLabel.bottomAnchor, constant: verticalSpacing)
        ]
        
        let expandedContentViewBottomAnchorConstraint = expandedContentView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.bottomAnchor)
        
        // 单独设定 datePicker 的底部约束优先级为低，是为了防止出现模糊约束的警告。同时不会出现展开动画时的跳动问题。
        expandedContentViewBottomAnchorConstraint.priority = .defaultLow
        
        expandedSizeLayoutConstraints = [
            expandedContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            expandedContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            expandedContentView.topAnchor.constraint(equalTo: secondaryLabel.bottomAnchor, constant: verticalSpacing),
            expandedContentViewBottomAnchorConstraint
        ]
    }
    
    private func updateLayoutConstraints() {
        
        if traitCollection.preferredContentSizeCategory.isAccessibilityCategory {
            // 大字体下的布局更新
            setupVerticalLayoutConstraints()
            
            isVerticalLayout = true
            isHorizontalLayout = false
        } else {
            // 标准字体下的布局更新。
            setupHorizontalLayoutConstraints()
            
            isHorizontalLayout = true
            isVerticalLayout = false
        }
        
        if isExpanded {
            NSLayoutConstraint.activate(expandedSizeLayoutConstraints)
            NSLayoutConstraint.deactivate(compressedSizeLayoutConstraints)
        } else {
            NSLayoutConstraint.activate(compressedSizeLayoutConstraints)
            NSLayoutConstraint.deactivate(expandedSizeLayoutConstraints)
        }
    }
    
    private func setupHorizontalLayoutConstraints() {
        // 标准字体下的布局更新。
        NSLayoutConstraint.deactivate(verticalLayoutConstraints)
        NSLayoutConstraint.activate(horizontalLayoutConstraints)
    }
    
    private func setupVerticalLayoutConstraints() {
        // 大字体下的布局更新
        NSLayoutConstraint.deactivate(horizontalLayoutConstraints)
        NSLayoutConstraint.activate(verticalLayoutConstraints)
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
    
}

