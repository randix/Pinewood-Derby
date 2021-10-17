//
//  RacerGroupView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/16/21.
//

//
//  DerbyEditView.swift
//  Pinewood Derby
//
//  Created by Rand Dow on 9/24/21.
//

import SwiftUI

struct RacerGroupView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var derby = Derby.shared
    
    @State var editId: UUID?
    @State var newGroup = ""
    
    @State var alertShow = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var alertButton = ""
    
    var body: some View {
        VStack {
            Group {
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
                    Text("Groups").font(.system(size: 20)).bold()
                    Spacer()
                }
                Spacer().frame(height:20)
            }
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Dismiss")
                    .font(.system(size: 16))
                    .bold()
            }
            Spacer().frame(height:20)
            
            HStack {
                Spacer().frame(width:50)
               
                Text("New group:")
                    .font(.system(size: 18))
                TextField("group", text: $newGroup)
                    .font(.system(size: 18))
                Button(action: {
                    if editId != nil {
                        let others = derby.groups.filter { $0.group == newGroup && $0.id != editId }
                        if others.count > 0 {
                            alertTitle = "Groups Already Exists"
                            alertMessage = "Cannot have two groups with the same name."
                            alertButton = "OK"
                            alertShow = true
                            return
                        }
                        if newGroup != "" {
                            let group = derby.groups.filter { editId == $0.id }
                            let oldGroup = group[0].group
                            for r in derby.racers {
                                if r.group == oldGroup {
                                    r.group = newGroup
                                }
                            }
                        }
                        derby.objectWillChange.send()
                    } else {
                        let others = derby.groups.filter { $0.group == newGroup }
                        if others.count > 0 {
                            alertTitle = "Groups Already Exists"
                            alertMessage = "Cannot have two groups with the same name."
                            alertButton = "OK"
                            alertShow = true
                            return
                        }
                        if newGroup != "" {
                            derby.groups.append(GroupEntry(group: newGroup))
                        }
                    }
                    newGroup = ""
                    editId = nil
                    derby.saveGroups()
                }) {
                    Text(editId == nil ? "New" : "Save")
                        .font(.system(size: 18))
                        .bold()
                }
                Spacer().frame(width:50)
            }
            Spacer().frame(height:20)
            
            List(derby.groups) { group in
                Text(group.group)
                    .font(.system(size: 16))
                    .swipeActions {
                      
                        Button {
                            editId = group.id
                            newGroup = group.group
                        } label: {
                            Label("Edit", systemImage: "square.and.pencil")
                        }
                        .tint(.teal)
                        Button(action: {
                            print("delete")
                            // TODO: delete
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
            }
            .frame(width: 250)
                                
            Spacer()
        }
        .alert(isPresented: self.$alertShow) {
            Alert(title: Text(self.alertTitle),
                  message: Text(self.alertMessage),
                  dismissButton: .default(Text(self.alertButton),
                                          action: { })
            )
        }
    }
}
