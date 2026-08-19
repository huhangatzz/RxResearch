//
//  SearchResultController.swift
//  RxResearch
//
//  Created by Kaiser on 2026/8/19.
//

import UIKit

class SearchResultController: BaseTableViewController {

    private let keyword: String
    
    init(keyword: String) {
        self.keyword = keyword
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    

}
