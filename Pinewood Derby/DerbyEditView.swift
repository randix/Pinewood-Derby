//
//  DerbyEditView.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 9/24/21.
//

import SwiftUI

struct DerbyEditView: View {
    
    let derby = Derby.shared
    var entry: DerbyEntry?
    
    @State var carNumber: String = ""
    @State var carName: String = ""
    @State var name: String = ""
    @State var group: String = ""
    
    init() {
        let entries = derby.entries.filter { derby.editEntryId == $0.id }
        if derby.edit && entries.count == 1 {
            entry = entries[0]
            carNumber = String(entry!.number)
            carName = entry!.name
            name = entry!.name
            group = entry!.group
        }
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Car Number")) {
                    TextField("88", text: $carNumber)
                        .keyboardType(.numberPad)
                }
                Section(header: Text("Car Name")) {
                    TextField("Ocho", text: $carName)
                        .keyboardType(.numberPad)
                    
                }
                Section(header: Text("Name")) {
                    TextField("Fred Smith", text: $name)
                }
                Section(header: Text("Group")) {
                    TextField("girls", text: $group)
                }
                
                HStack {
                    Button(action: {
                        print("cancel")
                    }) {
                        Text("Cancel")
                    }
                    Button(action: {
                        print("save")
                        Derby.shared.addEntry()
                    }) {
                        Text("Save")
                    }
                    if !derby.edit {
                        Button(action: {
                            print("save and new")
                        }) {
                            Text("Save + New")
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Derby Entry", displayMode: .inline)
    }
}
