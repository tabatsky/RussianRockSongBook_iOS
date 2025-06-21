//
//  CloudItemsAdapter.swift
//  iosApp
//
//  Created by User on 21.06.2025.
//  Copyright © 2025 orgName. All rights reserved.
//

import SwiftUI
import shared

struct CloudItemsAdapter {
    let items: [CloudSong]? 
    let searchState: SearchState
    let searchFor: String
    let orderBy: OrderBy
    let onPerformAction: (AppUIAction) -> ()
    
    func getCount() -> Int {
        guard let theItems = items else {
            return 0
        }
        return theItems.count
    }
    
    func getItem(position: Int) -> CloudSong? {
        if (position < getCount()) {
            if (position >= getCount() - Int(CloudRepositoryKt.PAGE_SIZE) - 1 && searchState == SearchState.pageLoadingSuccess) {
                
                let nextPage = getCount() / Int(CloudRepositoryKt.PAGE_SIZE) + 1
                Task.detached { @MainActor in
                    self.onPerformAction(CloudSearch(searchFor: self.searchFor, orderBy: self.orderBy, page: Int32(nextPage)))
                }
            }
            return items?[position]
        } else {
            return nil
        }
    }
}
