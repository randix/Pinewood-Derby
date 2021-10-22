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
    
    @Binding var groups: [GroupEntry]
  
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
                    if newGroup == "" { return }
                    alertTitle = "Group Already Exists"
                    alertMessage = "Cannot have two groups with the same name."
                    alertButton = "OK"
                    if editId != nil {
                        let others = groups.filter { $0.group == newGroup && $0.id != editId }
                        if others.count > 0 {
                            alertShow = true
                            return
                        }
                        let group = groups.filter { editId == $0.id }
                        let oldGroup = group[0].group
                        log("group change: from \(oldGroup) to \(newGroup)")
                        group[0].group = newGroup
                        for r in derby.racers {
                            if r.group == oldGroup {
                                r.group = newGroup
                            }
                        }
                        derby.saveRacers()
                    } else {
                        let others = groups.filter { $0.group == newGroup }
                        if others.count > 0 {
                            alertShow = true
                            return
                        }
                        log("group add: \(newGroup)")
                        groups.append(GroupEntry(group: newGroup))
                    }
                    newGroup = ""
                    editId = nil
                    updateGroups()
                }) {
                    Text(editId == nil ? "New" : "Save")
                        .font(.system(size: 18))
                        .bold()
                }
                Spacer().frame(width:50)
            }
            Spacer().frame(height:20)
            
            List(groups) { group in
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
                            var oldName: String = ""
                            for i in 0..<groups.count {
                                if groups[i].id == group.id {
                                    oldName = group.group
                                    groups.remove(at: i)
                                    break
                                }
                            }
                            for r in derby.racers {
                                if r.group == oldName {
                                    r.group = ""
                                }
                            }
                            derby.saveRacers()
                            updateGroups()
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
    
    func updateGroups() {
        derby.groups = []
        for group in groups {
            if group.group == "---" {
                continue
            }
            derby.groups.append(group)
        }
        derby.saveGroups()
        derby.objectWillChange.send()
    }
}
