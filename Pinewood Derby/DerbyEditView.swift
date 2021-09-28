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
    
    @State var id = UUID()
    @State var carNumber = ""
    @State var carName = ""
    @State var name = ""
    @State var group = ""
    
    init() {
        let entries = derby.entries.filter { derby.editEntryId == $0.id }
        if derby.edit && entries.count == 1 {
            entry = entries[0]
            _id = .init(initialValue:entry!.id)
            _carNumber = .init(initialValue: String(entry!.carNumber))
            _carName = .init(initialValue: entry!.carName)
            _name = .init(initialValue: entry!.name)
            _group = .init(initialValue: entry!.group)
            derby.currentGroup = group
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 20)
            HStack {
                Spacer().frame(minWidth: 0)
                Image(systemName: "chevron.compact.down").resizable().frame(width: 35, height: 12).opacity(0.3)
                Spacer().frame(minWidth: 0)
            }
            Spacer().frame(height: 20)
            
            HStack {
                Label("Car Number: ", systemImage: "number.square")
                TextField("88", text: $carNumber)
                    .keyboardType(.numberPad)
            }
            HStack {
                Label("Car Name: ", systemImage: "car")
                TextField("Ocho", text: $carName)
            }
            HStack {
                Label("Name: ", systemImage: "person")
                TextField("Ocho", text: $name)
            }
            HStack {
                Label("Group: ", systemImage: "person.3")
                SRadioButtonViewGroup(dataProvider: DataProvider<RadioModel>(), selectedItem: getSelectedItemLabel)
            }
            
            HStack {
                Spacer()
                
                Button(action: {
                    print("cancel")
                }) {
                    Text("Cancel")
                }
                Button(action: {
                    print("save")
                    let number = UInt(carNumber)
                    // check that the number has not been changed to overlap another entry
                    let entriesNumberCheck = derby.entries.filter { number == $0.carNumber }
                    if entriesNumberCheck.count == 1 && entriesNumberCheck[0].id != id {
                        // another id has the same carNumber
                        print("error: duplicate carNumber")
                        return
                    }
                    // find the entry in the array....
                    let index = derby.entries.firstIndex{ $0.id == id}
                    derby.entries[index!].carNumber = number!
                    derby.entries[index!].carName = carName
                    derby.entries[index!].name = name
                    derby.entries[index!].group = group
                    derby.objectWillChange.send()
                }) {
                    Text("Save")
                }
                if !derby.edit {
                    Button(action: {
                        print("save and new")
                        let number = UInt(carNumber)    // Optional
                        let entries = derby.entries.filter { $0.carNumber == number }
                        if entries.count > 0 {
                            print("error - already entered car number \(number)")
                        }
                        
                        Derby.shared.addEntry()
                    }) {
                        Text("Save + New")
                    }
                }
                
                Spacer()
            }
            
            Spacer()
        }
        .navigationBarTitle("Derby Entry", displayMode: .inline)
    }
    
    func getSelectedItemLabel<T>(item: T) {
        group = String((item as! RadioModel).label)
        print("selected item : \((item as! RadioModel).label)")
    }
    
}
