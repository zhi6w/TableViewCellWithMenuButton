//
//  ContextMenuAccessoryButton.swift
//  TableViewCellWithMenuButton
//
//  Created by Zhi Zhou on 2023/4/10.
//

import UIKit

open class ContextMenuAccessoryButton: UIButton {
    
    open override var menu: UIMenu? {
        didSet {
            isUserInteractionEnabled = menu != nil
        }
    }
    
    public let menuWillDisplayTriggered = Delegate<Void, Void>()
    public let menuWillEndTriggered = Delegate<Void, Void>()
    
    public let longPressBeganTriggered = Delegate<Void, Void>()
    public let longPressEndedTriggered = Delegate<Void, Void>()
    
    private var longPressGestureRecognizer: UILongPressGestureRecognizer?
    

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setupInterface()
        setupGestureRecognizers()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
            
}

extension ContextMenuAccessoryButton {
    
    private func setupInterface() {
        // 默认情况下，button 不可以交互。只有当 menu 设定后，才可以交互。
        isUserInteractionEnabled = false
        clipsToBounds = true
    }
    
    private func setupGestureRecognizers() {
        // 设定长按手势，防止在用户进行长按按钮操作时弹出 menu。只有单击按钮才可以弹出 menu。
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: nil)
        longPressGestureRecognizer?.delegate = self
        longPressGestureRecognizer?.cancelsTouchesInView = false
        longPressGestureRecognizer?.minimumPressDuration = 0.15 // 设定较短的时间，在长按时快速触发点击响应产生的“背景选中”（tableView DidSeleted）变化。

        addGestureRecognizer(longPressGestureRecognizer!)
    }
    
}

extension ContextMenuAccessoryButton {
    
    open override func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willDisplayMenuFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        super.contextMenuInteraction(interaction, willDisplayMenuFor: configuration, animator: animator)
        
        // 监听按钮的 menu 弹出。
        menuWillDisplayTriggered.callAsFunction()
    }

    open override func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willEndFor configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        super.contextMenuInteraction(interaction, willEndFor: configuration, animator: animator)
        
        // 监听按钮的 menu 关闭。
        menuWillEndTriggered.callAsFunction()
    }
    
}

extension ContextMenuAccessoryButton: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        print(">>>>", gestureRecognizer.state.rawValue)
                        
        switch gestureRecognizer.state {
        case .began:
            // 监听长按按钮开始事件。
            longPressBeganTriggered.callAsFunction()
            
        case .ended:
            // 监听长按按钮结束事件。
            longPressEndedTriggered.callAsFunction()
            
        default:
            break
        }
        
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        // 区分单击与长按手势，仅单击时才触发 menu 菜单。
        return true
    }
    
}

