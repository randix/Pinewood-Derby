//
//  DerbyView.swift
//
//  Created by Rand Dow on 9/20/21.
//

import SwiftUI

struct DerbyView: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var derby = Derby.shared
    
    let bWidth = CGFloat(60)
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            // Derby entries --------------------------------------------
            List (derby.entries) { entry in
                HStack {
                    Text(String(entry.idx))
                    Text(String(entry.number))
                    Text(entry.carName)
                    Text(entry.name)
                    Text(entry.group)
                }
            }
            .frame(minHeight: 0)
            .background(.yellow)
            // swipe left: edit, delete(with CONFIRM)
            
//            Spacer().frame(minHeight: 0)
//                .background(.orange)
            
            // Button Row ----------------------------------------
            HStack {
                Spacer().frame(minWidth: 0)
                
                NavigationLink(destination: LazyView(HeatsView())) {
                    VStack {
                        VStack {
                            Image(systemName: "wifi")
                            Text("Share").font(.system(size: 10))
                        }
                        //.background(Color(.orange))
                    }
                }
                .frame(width: bWidth)
                
                NavigationLink(destination: LazyView(HeatsView())) {
                    VStack {
                        VStack {
                            Image(systemName: "tablecells")
                            Text("Heats").font(.system(size: 10))
                        }
                        //.background(Color(.orange))
                    }
                }
                .frame(width: bWidth)
                
                NavigationLink(destination: LazyView(SettingsView())) {
                    VStack {
                        VStack {
                            Image(systemName: "gear")
                            Text("Settings").font(.system(size: 10))
                        }
                        //.background(Color(.orange))
                    }
                }
                .frame(width: bWidth)
                
                NavigationLink(destination: LazyView(InfoView())) {
                    VStack {
                        VStack {
                            Image(systemName: "info.circle")
                            Text("Info").font(.system(size: 10))
                        }
                        //.background(Color(.orange))
                    }
                }
                .frame(width: bWidth)
                
                Spacer().frame(minWidth: 0)
            }
            .background(.red)
            
            //Spacer().frame(height: 10)
        }
        // full screen:
        //.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        //.edgesIgnoringSafeArea(.all)
        //        .background(Color.blue)
        // Navigation Bar --------------------------------
        .navigationBarItems(leading: EmptyView(), trailing: Button(action: {
        }) {
            Image(systemName: "plus.circle")
            //Text("+").font(.system(size: 14)).bold()
        })
        .navigationBarTitle("Derby", displayMode: .inline)
        .background(.green)
    }
}




