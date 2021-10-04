//
//  PinView.swift
//  PinewoodDerby
//
//  Created by Rand Dow on 10/4/21.
//

import SwiftUI

struct PinView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let derby = Derby.shared
    @State var pin = ""
    
    @State var showAlert = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "123.rectangle").font(.system(size: 18)).frame(width: 30)
                Text("Pin: ").font(.system(size: 18))
                TextField("0000", text: $pin).font(.system(size: 18))
                    .frame(width:60)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 0).lineLimit(1).minimumScaleFactor(0.4)
                    .keyboardType(.numberPad)
                Button(action: {
                    derby.isMaster = pin == derby.pin
                    log("isMaster = \(derby.isMaster)")
                    pin = ""
                    derby.objectWillChange.send()
                    if derby.isMaster == false {
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        if derby.heats.count == 0 {
                            derby.generateHeats()
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            showAlert = true
                        }
                    }
                }) {
                    Image(systemName: "checkmark").font(.system(size: 18)).frame(width: 30)
                }
                Spacer()
            }
        }
        .alert(isPresented: self.$showAlert) {
            Alert(title: Text("Generate Heats"),
                  message: Text("This will re-generate the heats!\nIf racing has started, this will invalidate all timing data!\n\nAre you sure?"),
                  primaryButton: .cancel() {
                presentationMode.wrappedValue.dismiss()
                
            },
                  secondaryButton: .destructive(Text("Generate")) {
                derby.generateHeats()
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
