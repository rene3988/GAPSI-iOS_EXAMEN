//
//  SearchHistoryManager.swift
//  eCommerce
//
//  Created by Gisell/Marjan on 17/08/26.
//

import Foundation

final class SearchHistoryManager {
    
    private let key = "search_history"
    private let maxItems = 20
    
    func getHistory() -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }
    
    func save(_ keyword: String) {
        
        let keyword = keyword
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard keyword.count >= 2 else {
            return
        }
        
        var history = getHistory()
        
        history.removeAll {
            $0.caseInsensitiveCompare(keyword) == .orderedSame
        }
        
        history.insert(keyword, at: 0)
        
        if history.count > maxItems {
            history = Array(history.prefix(maxItems))
        }
        
        UserDefaults.standard.set(history, forKey: key)
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
