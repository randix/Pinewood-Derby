//
//  DerbyEditView.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 9/24/21.
//

import SwiftUI

struct RacerAddView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var entry: RacerEntry?
    
    @State var id = UUID()
    @State var carNumber = ""
    @State var carName = ""
    @State var firstName = ""
    @State var lastName = ""
    @State var age = ""
    @State var group = ""
    
    @State var alertShow = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var alertButton = ""
    
    @ObservedObject var derby = Derby.shared
    
    @State var groups: [GroupEntry] = []
    @State var groupSelector = 0
    
    let fontSize = CGFloat(18)
    let circleSize = CGFloat(14)
    
    @State var showGroupModal = false
    
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
                Text("Racer Entry").font(.system(size: 20)).bold()
                Spacer()
            }
            Spacer().frame(height:30)
            
            Group {
                HStack {
                    Spacer().frame(width: 20)
                    //Image(systemName: "number.square").font(.system(size: fontSize)).frame(width: 30)
                    Text("Car Number: ").font(.system(size: fontSize))
                    TextField("88", text: $carNumber).font(.system(size: fontSize))
                        .frame(width:50)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                        .keyboardType(.numberPad)
                    //.background(.red)
                }
                HStack {
                    Spacer().frame(width: 20)
                    //Image(systemName: "car").font(.system(size: fontSize)).frame(width: 30)
                    Text("Car Name: ").font(.system(size: fontSize))
                    TextField("Ocho", text: $carName).font(.system(size: fontSize))
                        .frame(width:120)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                    //.background(.red)
                }
                HStack {
                    Spacer().frame(width: 20)
                    //Image(systemName: "person").font(.system(size: fontSize))
                    Text("Name: ").font(.system(size: fontSize))
                    TextField("first name", text: $firstName).font(.system(size: fontSize))
                        .frame(width:130)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                    //.background(.red)
                    TextField("last name", text: $lastName).font(.system(size: fontSize))
                        .frame(width:130)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                    //.background(.red)
                }
                HStack {
                    Spacer().frame(width: 20)
                    //Image(systemName: "number.square").font(.system(size: fontSize)).frame(width: 30)
                    Text("Age: ").font(.system(size: fontSize))
                    TextField("10", text: $age).font(.system(size: fontSize))
                        .frame(width:50)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                        .keyboardType(.numberPad)
                    //.background(.red)
                }
                HStack {
                    Spacer().frame(width: 20)
                    
                    Text("Group: ").font(.system(size: fontSize))
                    if derby.groups.count == 2 {
                        Group {
                            if group == derby.groups[0].group {
                                Image(systemName: "circle.fill").font(.system(size: circleSize))
                            } else {
                                Image(systemName: "circle").font(.system(size: circleSize))
                            }
                            Text(derby.groups[0].group).font(.system(size: fontSize))
                        }
                        .onTapGesture {
                            group = derby.groups[0].group
                        }
                        Spacer().frame(width:20)
                        Group {
                            if group == derby.groups[1].group {
                                Image(systemName: "circle.fill").font(.system(size: circleSize))
                            } else {
                                Image(systemName: "circle").font(.system(size: circleSize))
                            }
                            Text(derby.groups[1].group).font(.system(size: fontSize))
                        }
                        .onTapGesture {
                            group = derby.groups[1].group
                        }
                    } else {
                        Picker("Groups", selection: $groupSelector, content: {
                            ForEach(0..<groups.count, id: \.self) {
                                Text(groups[$0].group)
                            }
                        })
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 120)
                            .onChange(of: groupSelector) { _ in
                                group = groups[groupSelector].group
                            }
                    }
                    Spacer().frame(width:20)
                    
                    Button(action: {
                        showGroupModal = true
                    }) {
                        VStack {
                            Image(systemName: "plus").font(.system(size: 14))
                            Text("Groups").font(.system(size: 11))
                        }
                    }
                }
                
                Spacer().frame(height: 40)
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Dismiss")
                            .font(.system(size: 18))
                    }
                    
                    Spacer().frame(width: 40)
                    
                    Button(action: {
                        if true == updateDerby() {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        
                    }) {
                        Text("Save")
                            .font(.system(size: 18))
                    }
                    
                    if entry == nil {
                        Spacer().frame(width: 40)
                        
                        Button(action: {
                            if true == updateDerby() {
                                carNumber = ""
                                carName = ""
                                firstName = ""
                                lastName = ""
                                group = ""
                                age = ""
                            }
                        }) {
                            Text("Save+New")
                                .font(.system(size: 18))
                        }
                    }
                    
                    Spacer()
                }
            }
            
            Spacer()
        }
        .alert(isPresented: self.$alertShow) {
            Alert(title: Text(self.alertTitle),
                  message: Text(self.alertMessage),
                  dismissButton: .default(Text(self.alertButton),
                                          action: { })
            )
        }
        .onAppear(perform: {
            groups = []
            groups.append(GroupEntry(group: "---"))
            groups.append(contentsOf: derby.groups)
            if let entry = entry {
                self.id = entry.id
                carNumber = String(entry.carNumber)
                carName = entry.carName
                firstName = entry.firstName
                lastName = entry.lastName
                group = entry.group
                age = String(entry.age)
                for i in 0..<groups.count {
                    if group == groups[i].group {
                        groupSelector = i
                        break
                    }
                }
            }
        })
        .sheet(isPresented: $showGroupModal, content: { RacerGroupView(groups: $groups) })
    }
    
    func updateDerby() -> Bool {
        if let number = Int(carNumber) {
            if number < 1 || number > 99 {
                alertTitle = "Car Number Out Of Range"
                alertMessage = "Car number must be between 1 and 99."
                alertButton = "OK"
                alertShow = true
                return false
            }
            if let ageInt = Int(age) {
                if ageInt < 1 || ageInt > 99 {
                    alertTitle = "Age Out Of Range"
                    alertMessage = "Age must be between 1 and 99."
                    alertButton = "OK"
                    alertShow = true
                    return false
                }
                // check that the number has not been changed to overlap another entry
                let racersNumberCheck = derby.racers.filter { number == $0.carNumber }
                if racersNumberCheck.count == 1 && racersNumberCheck[0].id != id {
                    // another id has the same carNumber
                    alertTitle = "Duplicate Car Number"
                    alertMessage = "Duplicate car number, you cannot have two cars with the same number."
                    alertButton = "OK"
                    alertShow = true
                    return false
                }
                if carName == "" {
                    carName = "--"
                }
                if firstName == "" || lastName == "" {
                    alertTitle = "Missing Name"
                    alertMessage = "Please enter both a first and a last name."
                    alertButton = "OK"
                    alertShow = true
                    return false
                }
                if group == "" {
                    alertTitle = "Group Not Selected"
                    alertMessage = "Please select a group."
                    alertButton = "OK"
                    alertShow = true
                    return false
                }
                // find the entry in the array....
                if let index = derby.racers.firstIndex(where: { $0.id == id}) {
                    derby.racers[index].carNumber = number
                    derby.racers[index].carName = carName
                    derby.racers[index].firstName = firstName
                    derby.racers[index].lastName = lastName
                    derby.racers[index].age = ageInt
                    derby.racers[index].group = group
                } else {
                    let d = RacerEntry(number: number, carName: carName, firstName: firstName, lastName: lastName, age: ageInt, group: group)
                    derby.racers.append(d)
                }
                derby.saveRacers()
                derby.objectWillChange.send()
                return true
            } else {
                alertTitle = "Age Missing"
                alertMessage = "Please enter the age."
                alertButton = "OK"
                alertShow = true
                return false
            }
        } else {
            alertTitle = "Car Number Missing"
            alertMessage = "Please enter the car number."
            alertButton = "OK"
            alertShow = true
            return false
        }
    }
}
