//
//  DerbyEditView.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 9/24/21.
//

import SwiftUI

struct DerbyEditView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var entry: DerbyEntry?
    
    @State var id = UUID()
    @State var carNumber = ""
    @State var carName = ""
    @State var name = ""
    @State var group = ""
    
    @State var alertShow = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var alertButton = ""
    
    let derby = Derby.shared
    
    let fontSize = CGFloat(14)
    let circleSize = CGFloat(10)
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 20)
            
            // chevron down
            HStack {
                Spacer().frame(minWidth: 0)
                Image(systemName: "chevron.compact.down").resizable().frame(width: 35, height: 12).opacity(0.3)
                Spacer().frame(minWidth: 0)
            }
            Spacer().frame(height: 20)
            
            // Title
            HStack {
                Spacer()
                Text("Car Entry").font(.system(size: 15)).bold()
                Spacer()
            }
            
            Group {
                HStack {
                    Spacer().frame(width: 20)
                    Image(systemName: "number.square").font(.system(size: fontSize)).frame(width: 30)
                    Text("Car Number: ").font(.system(size: fontSize))
                    TextField("88", text: $carNumber).font(.system(size: fontSize))
                        .keyboardType(.numberPad)
                }
                HStack {
                    Spacer().frame(width: 20)
                    Image(systemName: "car").font(.system(size: fontSize)).frame(width: 30)
                    Text("Car Name: ").font(.system(size: fontSize))
                    TextField("Ocho", text: $carName).font(.system(size: fontSize))
                }
                HStack {
                    Spacer().frame(width: 20)
                    Image(systemName: "person").font(.system(size: fontSize))
                    Text("Name: ").font(.system(size: fontSize))
                    TextField("Rand", text: $name).font(.system(size: fontSize))
                }
                HStack {
                    Spacer().frame(width: 20)
                    Image(systemName: "person.3").font(.system(size: fontSize))
                    Text("Group: ").font(.system(size: fontSize))
                    Group {
                        if group == derby.girls {
                            Image(systemName: "circle.fill").font(.system(size: circleSize))
                        } else {
                            Image(systemName: "circle").font(.system(size: circleSize))
                        }
                        Text(derby.girls).font(.system(size: fontSize))
                    }
                    .onTapGesture {
                        group = derby.girls
                    }
                    Spacer().frame(width:20)
                    Group {
                        if group == derby.boys {
                            Image(systemName: "circle.fill").font(.system(size: circleSize))
                        } else {
                            Image(systemName: "circle").font(.system(size: circleSize))
                        }
                        Text(derby.boys).font(.system(size: fontSize))
                    }
                    .onTapGesture {
                        group = derby.boys
                    }
                }
            }
            
            Spacer().frame(height: 20)
            
            HStack {
                Spacer()
                
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                }
                
                Spacer().frame(width: 40)
                
                Button(action: {
                    updateDerby()
                    self.presentationMode.wrappedValue.dismiss()
                    
                }) {
                    Text("Save")
                }
                
                if entry == nil {
                    Spacer().frame(width: 40)
                    
                    Button(action: {
                        updateDerby()
                        carNumber = ""
                        carName = ""
                        name = ""
                        group = ""
                    }) {
                        Text("Save+New")
                    }
                }
                
                Spacer()
            }
            
            Spacer()
        }
        .navigationBarTitle("Derby Entry", displayMode: .inline)
        .alert(isPresented: self.$alertShow) {
            Alert(title: Text(self.alertTitle),
                  message: Text(self.alertMessage),
                  dismissButton: .default(Text(self.alertButton),
                                          action: { })
            )
        }
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
    
    func updateDerby() {
        let number = UInt(carNumber)
        // check that the number has not been changed to overlap another entry
        let entriesNumberCheck = derby.entries.filter { number == $0.carNumber }
        if entriesNumberCheck.count == 1 && entriesNumberCheck[0].id != id {
            // another id has the same carNumber
            alertTitle = "Duplicate"
            alertMessage = "Duplicate car number"
            alertButton = "OK"
            alertShow = true
            return
        }
        // find the entry in the array....
        if let index = derby.entries.firstIndex(where: { $0.id == id}) {
            derby.entries[index].carNumber = number!
            derby.entries[index].carName = carName
            derby.entries[index].name = name
            derby.entries[index].group = group
        } else {
            let d = DerbyEntry(number: number!, carName: carName, name: name, group: group)
            derby.entries.append(d)
        }
        derby.saveDerbyData()
        derby.objectWillChange.send()
    }
}
