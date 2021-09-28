//
//  MyRadioButtonGroup.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 9/28/21.
//

import Foundation

class RadioModel: RadioModelable {
    var id: Int
    var isChecked: Bool
    var label: String
    
    required init(id: Int, isChecked: Bool, label: String) {
        print(#function)
        self.id = id
        self.isChecked = isChecked
        self.label = label
    }
}

class DataProvider<T>: RadioDataProviding where T: RadioModelable {
    @Published var items: [RItem] = []
    
    init() {
        self.items = getItems()
    }
    
    func getItems() -> [T] {
        print(#function)
        let derby = Derby.shared
        return [T(id: 1, isChecked: derby.currentGroup == derby.girls, label: Derby.shared.girls),
                T(id: 2, isChecked: derby.currentGroup == derby.boys, label: Derby.shared.boys)
        ]
    }
    
    func toggle(id: Int) {
        print(#function)
        for var item in self.items {
            if item.id == id {
                item.isChecked = true
            } else {
                item.isChecked = false
            }
        }
        self.objectWillChange.send()
    }
}
