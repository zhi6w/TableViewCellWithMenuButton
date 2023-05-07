//
//  ViewController.swift
//  TableViewCellWithMenuButton
//
//  Created by Zhi Zhou on 2023/4/10.
//

import UIKit

class ViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private var sections: [Section] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
        setupInterface()
    }

}

extension ViewController {
    
    private func loadData() {
        
        (0..<3).forEach { _ in
            var items: [Item] = []
            (0..<6).forEach { _ in
                let item = Item(text: "Text", secondaryText: "Secondary Text")
                
                /* ----- menu ----- */
                var menu: UIMenu!
                
                var defaultActions: [UIAction] = []
                let neverAction = UIAction(title: RepeatOption.never.rawValue, handler: { _ in
                    self.updateMenu(menu, withTitle: RepeatOption.never.rawValue)
                    item.menu = menu
                })
                
                let everyDayAction = UIAction(title: RepeatOption.everyDay.rawValue, handler: { _ in
                    self.updateMenu(menu, withTitle: RepeatOption.everyDay.rawValue)
                    item.menu = menu
                })
                
                let everyWeekAction = UIAction(title: RepeatOption.everyWeek.rawValue, handler: { _ in
                    self.updateMenu(menu, withTitle: RepeatOption.everyWeek.rawValue)
                    item.menu = menu
                })
                
                let every2WeeksAction = UIAction(title: RepeatOption.every2Weeks.rawValue) { _ in
                    self.updateMenu(menu, withTitle: RepeatOption.every2Weeks.rawValue)
                    item.menu = menu
                }
                
                let everyMonthAction = UIAction(title: RepeatOption.everyMonth.rawValue, handler: { _ in
                    self.updateMenu(menu, withTitle: RepeatOption.everyMonth.rawValue)
                    item.menu = menu
                })
                
                let everyYearAction = UIAction(title: RepeatOption.everyYear.rawValue, handler: { _ in
                    self.updateMenu(menu, withTitle: RepeatOption.everyYear.rawValue)
                    item.menu = menu
                })
                
                defaultActions = [neverAction, everyDayAction, everyWeekAction, every2WeeksAction, everyMonthAction, everyYearAction]
                
                // ----------
                
                var customActions: [UIAction] = []
                let customAction = UIAction(title: RepeatOption.custom.rawValue) { _ in
                    self.updateMenu(menu, withTitle: RepeatOption.custom.rawValue)
                    item.menu = menu
                }
                
                customActions = [customAction]
                
                menu = UIMenu(children: [
                    UIMenu(identifier: .init(rawValue: "available"), options: .displayInline, children: defaultActions),
                    UIMenu(identifier: .init(rawValue: "custom"), options: .displayInline, children: customActions)
                ])
                
                item.menu = menu
                
                /* ---------- */
                
                items.append(item)
            }
            
            let section = Section(items: items)
            sections.append(section)
        }
    }
    
}

extension ViewController {
    
    private func setupInterface() {
        setupTableView()
    }
    
    private func setupTableView() {
        
        tableView.register(RepeatTableViewCell.self, forCellReuseIdentifier: "\(RepeatTableViewCell.self)")

        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(RepeatTableViewCell.self)", for: indexPath) as? RepeatTableViewCell
        else {
            fatalError("Could not dequeue \(RepeatTableViewCell.self) with identifier: \(RepeatTableViewCell.self)")
        }
        
        cell.item = sections[indexPath.section].items[indexPath.row]

        cell.menuInteractionWillDisplay.delegate(on: self, callback: { (self) in
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        })

        cell.menuInteractionWillEnd.delegate(on: self, callback: { (self) in
            self.tableView.deselectRow(at: indexPath, animated: true)
        })

        cell.longPressBegan.delegate(on: self, callback: { (self) in
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        })

        cell.longPressEnded.delegate(on: self, callback: { (self) in
            self.tableView.deselectRow(at: indexPath, animated: true)
        })
                
        return cell
    }
  
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        print("Did Select Row At \(indexPath)")
    }
    
}

extension ViewController {
    
    private func updateMenu(_ menu: UIMenu, withTitle title: String) {
        let availableMenu = menu.children.filter { ($0 as? UIMenu)?.identifier == .init(rawValue: "available") }.first as? UIMenu
        let newAvailableActions = updateAction(with: availableMenu, and: title)
        let newAvailableMenu = availableMenu?.replacingChildren(newAvailableActions ?? [])

        /* ---------- */
        
        let customMenu = menu.children.filter { ($0 as? UIMenu)?.identifier == .init(rawValue: "custom") }.first as? UIMenu
        let newCustomActions = updateAction(with: customMenu, and: title)
        let newCustomMenu = customMenu?.replacingChildren(newCustomActions ?? [])
        
        guard let newAvailableMenu = newAvailableMenu, let newCustomMenu = newCustomMenu else { return }
        
        menu.replacingChildren([newAvailableMenu, newCustomMenu])
    }
    
    private func updateAction(with menu: UIMenu?, and title: String) -> [UIAction]? {
        
        let actions = menu?.children as? [UIAction]
        let newActions = actions?.compactMap({ action in
            if action.title == title {
                action.state = .on
                return action
            }
            else {
                action.state = .off
                return action
            }
        })
        
        return newActions
    }
    
}

