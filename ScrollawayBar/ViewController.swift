//
//  ViewController.swift
//  ScrollawayBar
//
//  Created by James Gillin on 3/14/17.
//  Copyright © 2017 James Gillin. All rights reserved.
//

import UIKit

let scrollawayDownThreshold: CGFloat = 80
//It feels snappier to have a low scrolling threshold for making the view reappear when scrolling up
let scrollawayUpThreshold: CGFloat = 10

class ViewController: UIViewController {
    
    fileprivate var scrollawayBar: UIView!
    fileprivate var tableView: UITableView!
    fileprivate let _rows: [Int?] = Array(repeating: nil, count: 50)
    fileprivate var _lastContentOffset: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupScrollawayBar()
        _setupTableView()
        _setupStackView()
    }
}

fileprivate extension ViewController {
    func _setupScrollawayBar() {
        scrollawayBar = UIView()
        scrollawayBar.backgroundColor = #colorLiteral(red: 1, green: 0.3214458082, blue: 0.2577915473, alpha: 1)
    }
    
    func _setupTableView() {
        tableView = UITableView()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func _setupStackView() {
        let stackView = UIStackView(arrangedSubviews: [scrollawayBar, tableView])
        stackView.axis = .vertical
        stackView.distribution = .fill
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: stackView, attribute: .bottom, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: stackView, attribute: .trailing, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0))
        
        stackView.addConstraint(NSLayoutConstraint(item: scrollawayBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 80))
        stackView.addConstraint(NSLayoutConstraint(item: scrollawayBar, attribute: .bottom, relatedBy: .equal, toItem: tableView, attribute: .top, multiplier: 1.0, constant: 0))
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "whatever")
        cell.textLabel?.text = "Cell \(indexPath.row)"
        if indexPath.row % 2 == 0 { cell.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1) }
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //store this off to later calculate whether we scrolled up or down, and by how much
        _lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        //Don't even mess with showing/hiding if we don't have enough content to fill the screen
        guard scrollView.contentSize.height > view.bounds.height else { return }
        
        let currentOffset = scrollView.contentOffset.y
        
        //user scrolling down
        if currentOffset > _lastContentOffset {
            if currentOffset - _lastContentOffset > scrollawayDownThreshold, scrollawayBar.isHidden == false {
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    self?.scrollawayBar.isHidden = true
                })
            }
        }
            
        //user scrolling up
        else if currentOffset < _lastContentOffset {
            if _lastContentOffset - currentOffset > scrollawayUpThreshold, scrollawayBar.isHidden == true {
                UIView.animate(withDuration: 0.3, animations: { [weak self] in
                    self?.scrollawayBar.isHidden = false
                })
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //user scrolled to top; ensure view is not hidden
        if scrollView.contentOffset.y == 0 {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.scrollawayBar.isHidden = false
            })
        }
    }
}
