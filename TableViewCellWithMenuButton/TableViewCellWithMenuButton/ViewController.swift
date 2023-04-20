//
//  ViewController.swift
//  TableViewCellWithMenuButton
//
//  Created by Zhi Zhou on 2023/4/10.
//

import UIKit

class ViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupInterface()
    }

}

extension ViewController {
    
    private func setupInterface() {
                
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

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(RepeatTableViewCell.self)", for: indexPath) as? RepeatTableViewCell

        var contentConfiguration = cell?.defaultContentConfiguration()

        contentConfiguration?.text = "Repeat - \(indexPath.row)"
        contentConfiguration?.image = UIImage(systemName: "flag.fill")
        cell?.contentConfiguration = contentConfiguration

        cell?.detailText = "Never"

        var defaultActions: [UIMenuElement] = []
        let neverAction = UIAction(title: "Never", state: .on, handler: { _ in })
        let everyDayAction = UIAction(title: "Every Day", handler: { _ in })
        let everyWeekAction = UIAction(title: "Every Week", handler: { _ in })
        let every2WeeksAction = UIAction(title: "Every 2 Weeks", handler: { _ in })
        let everyMonthAction = UIAction(title: "Every Month", handler: { _ in })
        let everyYearAction = UIAction(title: "Every Year", handler: { _ in })
        defaultActions = [neverAction, everyDayAction, everyWeekAction, every2WeeksAction, everyMonthAction, everyYearAction]

        var customActions: [UIMenuElement] = []
        let customAction = UIAction(title: "Custom", state: .off, handler: { _ in })
        customActions = [customAction]

        let menu = UIMenu(children: [
            UIMenu(options: .displayInline, children: defaultActions),
            UIMenu(options: .displayInline, children: customActions)
        ])

        cell?.menu = menu

        cell?.menuInteractionWillDisplay.delegate(on: self, callback: { (self) in
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        })

        cell?.menuInteractionWillEnd.delegate(on: self, callback: { (self) in
            self.tableView.deselectRow(at: indexPath, animated: true)
        })

        cell?.longPressBegan.delegate(on: self, callback: { (self) in
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        })

        cell?.longPressEnded.delegate(on: self, callback: { (self) in
            self.tableView.deselectRow(at: indexPath, animated: true)
        })
                
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        print("did selected")
    }
    
}

