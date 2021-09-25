//
//  DerbyView.swift
//
//  Created by Rand Dow on 9/20/21.
//

import SwiftUI

struct Sizes {
    static let bWidth = CGFloat(65)
    
    static let iWidth = CGFloat(24)
    static let cWidth = CGFloat(24)
    static let cnWidth = CGFloat(90)
    static let nWidth = CGFloat(90)
    static let gWidth = CGFloat(50)
    
    static let cFont = CGFloat(12)
    
    static let tWidth = CGFloat(40)
    static let tFont = CGFloat(11)
}

struct HText: View {
    
    let text: String
    let width: CGFloat
    
    var body: some View {
        Text(text).bold().frame(width: width).font(.system(size: Sizes.cFont))
    }
}

struct DText: View {
    
    let text: String
    let width: CGFloat
    
    var body: some View {
        Text(text).frame(width: width).font(.system(size: Sizes.cFont))
    }
}

struct TText: View {
    
    let text: String
    
    var body: some View {
        Text(text).frame(width: Sizes.tWidth).font(.system(size: Sizes.tFont))
    }
}

struct DerbyView: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var derby = Derby.shared
    
    @State var edit = false
    
    let screenSize = UIScreen.main.bounds.size
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            // Sort row buttons
            HStack {
                Spacer()
                HText(text: "Car",      width: Sizes.cWidth)
                HText(text: "Car Name", width: Sizes.cnWidth)
                HText(text: "Name",     width: Sizes.nWidth)
                HText(text: "Group",    width: Sizes.gWidth)
                Spacer()
                
                // times...
                
            }
            
            // Derby entries --------------------------------------------
            List (derby.entries) { entry in
                VStack {
                    HStack {
                        Spacer()
                        DText(text: String(entry.number), width: Sizes.cWidth)
                        DText(text: entry.carName,        width: Sizes.cnWidth)
                        DText(text: entry.name,           width: Sizes.nWidth)
                        DText(text: entry.group,          width: Sizes.gWidth)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        TText(text: String(entry.times[0]))
                        TText(text: String(entry.times[1]))
                        TText(text: String(entry.times[2]))
                        TText(text: String(entry.times[3]))
                        TText(text: String(entry.average))
                        Spacer()
                    }
                }
                //.frame(height: 90)
                .swipeActions {
//                    NavigationLink(destination: LazyView(DerbyEditView())) {
//                        VStack {
//                            VStack {
//                                Image(systemName: "square.and.pencil")
//                                Text("Share").font(.system(size: 10))
//                            }
//                            //.background(Color(.orange))
//                        }
//                    }
                    
                            Button {
                                print("Edit")
                                
                                
                            } label: {
                                Label("Edit", systemImage: "square.and.pencil")
                            }
                            .tint(.yellow)
                 
                            Button {
                                print("Delete")
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
            }
            .frame(minHeight: 0)
          //  .background(.yellow)
            // swipe left: edit, delete(with CONFIRM)
            
//            Spacer().frame(minHeight: 0)
//                .background(.orange)
            
            // Button Row ----------------------------------------
            HStack {
                Spacer().frame(minWidth: 0)
                
                NavigationLink(destination: LazyView(HeatsView())) {
                    VStack {
                        VStack {
                            Image(systemName: "tablecells")
                            Text("Heats").font(.system(size: 10))
                        }
                        //.background(Color(.orange))
                    }
                }
                .frame(width: Sizes.bWidth)
                
                NavigationLink(destination: LazyView(SettingsView())) {
                    VStack {
                        VStack {
                            Image(systemName: "gear")
                            Text("Settings").font(.system(size: 10))
                        }
                        //.background(Color(.orange))
                    }
                }
                .frame(width: Sizes.bWidth)
                
                NavigationLink(destination: LazyView(InfoView())) {
                    VStack {
                        VStack {
                            Image(systemName: "info.circle")
                            Text("Info").font(.system(size: 10))
                        }
                        //.background(Color(.orange))
                    }
                }
                .frame(width: Sizes.bWidth)
                
                Spacer().frame(minWidth: 0)
            }
            //.background(.red)
            
            //Spacer().frame(height: 10)
        }
        // full screen:
        //.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        //.edgesIgnoringSafeArea(.all)
        //        .background(Color.blue)
        // Navigation Bar --------------------------------
        .navigationBarItems(leading: EmptyView(), trailing: Button(action: {
            print("add new")
            
        }) {
            Image(systemName: "plus.circle")
            //Text("+").font(.system(size: 14)).bold()
        })
        .navigationBarTitle("Derby", displayMode: .inline)
//        .onAppear(perform: {
//            print(#function)
//        })
    }
}
