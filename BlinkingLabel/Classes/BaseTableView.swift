//
//  BaseTableView.swift
//  BaseTableView
//
//  Created by Слава Платонов on 02.02.2022.
//

import UIKit
import DifferenceKit

typealias TableData = (tableView: UITableView, indexPath: IndexPath, element: Any)
typealias CellDisplayData = (tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath, element: Any)
typealias CellWillDisplayData = (tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath)
typealias HeaderData = (tableView: UITableView, section: Int)
typealias MenuData = (tableView: UITableView, indexPath: IndexPath, point: CGPoint, element: Any)

class BaseTableView: UITableView {
    
    struct Error: _ErrorData {
        var title: String
        
        var descr: String
        
        var onRetry: (() -> ())?
    }
    
    struct Loading: _Loading {
        var loadingTitle: String? = nil
    }
    
    /// original data source
    private var viewState = [State]()
    public var rowAnimation: UITableView.RowAnimation = .fade
    public var shouldInterrupt = false
    
    /// public data source. Affects original, used only for diff calculattions
    public var viewStateInput: [State] {
        get {
            return viewState
        }
        set {
            let changeset = StagedChangeset(source: viewState, target: newValue)
            reload(using: changeset, with: rowAnimation, interrupt: { [weak self] change in
                guard let self = self else { return true }
                return self.shouldInterrupt }) { newState in
                self.viewState = newState
            }
        }
    }
    
    public var onCellForRow: ((TableData) -> UITableViewCell)?
    public var onCellSelect: ((TableData) -> ())?
    public var onCellEndDisplaying: ((CellDisplayData) -> ())?
    public var onHeaderView: ((HeaderData) -> UIView)?
    public var onFooterView: ((HeaderData) -> UIView)?
    public var onScroll: ((UIScrollView) -> ())?
    public var onWillDisplay: ((CellWillDisplayData) -> Void)?
    
    @available(iOS 13.0, *)
    public lazy var onMenu: ((MenuData) -> UIContextMenuConfiguration?)? = nil
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public func showError(title: String, desc: String, onRetry: (() -> ())?) {
        let errorData = Error(title: title, descr: desc, onRetry: onRetry)
        let section = SectionState(header: nil, footer: nil)
        let sectionState = State(model: section, elements: [Element(content: errorData)])
        self.viewStateInput = [sectionState]
    }
    
    public func showLoading() {
        let loadingData = Loading()
        let section = SectionState(header: nil, footer: nil)
        let sectionState = State(model: section, elements: [Element(content: loadingData)])
        var states = viewStateInput
        states.append(sectionState)
        self.viewStateInput = states
    }
    
    
}

extension BaseTableView {
    
    private func setup() {
        delegate = self
        dataSource = self
    }
}

extension BaseTableView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewState.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewState[section].model.isCollapsed ? 0 : viewState[section].elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let element = self.viewState[indexPath.section].elements[indexPath.row].content
        return element.cell(for: tableView, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        onWillDisplay?((tableView: tableView, cell: cell, indexPath: indexPath))
    }
}

extension BaseTableView: UITableViewDelegate {
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let element = self.viewState[safe: indexPath.section]?.elements[safe: indexPath.row]?.content else { return nil }
        return onMenu?((tableView: tableView, indexPath: indexPath, point: point, element: element)
)
    }
        
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let element = self.viewState[safe: indexPath.section]?.elements[safe: indexPath.row]?.content else { return }
        onCellEndDisplaying?((tableView: tableView, cell: cell, indexPath: indexPath, element: element))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let element = self.viewState[safe: indexPath.section]?.elements[safe: indexPath.row]?.content else { return }
        element.onSelect()
        deselectRow(at: indexPath, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onScroll?(scrollView)
    }
}
