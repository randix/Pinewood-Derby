//
//  DerbyEditView.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 9/24/21.
//

import SwiftUI

struct DerbyEditView: View {
    
    @Binding var entry: DerbyEntry?
    
    @State var id = UUID()
    @State var carNumber = ""
    @State var carName = ""
    @State var name = ""
    @State var group = ""
    
    let derby = Derby.shared
    
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
                TextField("Rand", text: $name)
            }
            HStack {
                Label("Group: ", systemImage: "person.3")
                // this is effectively a radio button selection
                Group {
                    if group == derby.girls {
                        Image(systemName: "circle.fill")
                    } else {
                        Image(systemName: "circle")
                    }
                    Text(derby.girls)
                }
                .onTapGesture {
                    group = derby.girls
                }
                Group {
                    if group == derby.boys {
                        Image(systemName: "circle.fill")
                    } else {
                        Image(systemName: "circle")
                    }
                    Text(derby.boys)
                }
                .onTapGesture {
                    group = derby.boys
                }
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
                    if let index = derby.entries.firstIndex(where: { $0.id == id}) {
                        derby.entries[index].carNumber = number!
                        derby.entries[index].carName = carName
                        derby.entries[index].name = name
                        derby.entries[index].group = group
                    } else {
                        
                    }
                    derby.objectWillChange.send()
                    // return from menu
                    
                }) {
                    Text("Save")
                }
                if entry == nil {
                    Button(action: {
                        let number = UInt(carNumber)    // Optional
                        let entries = derby.entries.filter { $0.carNumber == number }
                        if entries.count > 0 {
                            print("error - already entered car number \(String(describing: number))")
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
        
        .onAppear(perform: {
            if entry != nil {
                self.id = entry!.id
                carNumber = String(entry!.carNumber)
                carName = entry!.carName
                name = entry!.name
                group = entry!.group
            }
        })
    }
}
