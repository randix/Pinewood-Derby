//
//  DerbyView.swift
//
//  Created by Rand Dow on 9/20/21.
//

import SwiftUI

struct Sizes {
    static let bWidth = CGFloat(50)
    
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
        Text(text).bold().frame(width: width, alignment: .leading).font(.system(size: Sizes.cFont))
    }
}

struct DText: View {
    
    let text: String
    let width: CGFloat
    
    var body: some View {
        Text(text).frame(width: width, alignment: .leading).font(.system(size: Sizes.cFont))
    }
}

struct TText: View {
    
    let text: String
    
    var body: some View {
        Text(text).frame(width: Sizes.tWidth, alignment: .leading).font(.system(size: Sizes.tFont))
    }
}

struct DerbyView: View {
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @ObservedObject var derby = Derby.shared
    
    @State var thisEntry: DerbyEntry?
    @State var showEditModal = false
    
    let screenSize = UIScreen.main.bounds.size
    
    var body: some View {
        NavigationView {
            VStack {
                
                // Sort row buttons
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            print("sort on car")
                        }) { HText(text: "Car",      width: Sizes.cWidth).background(.green) }
                        Button(action: {
                            print("sort on car name")
                        }) { HText(text: "Car Name", width: Sizes.cnWidth).background(.gray) }
                        Button(action: {
                            print("sort on name")
                        }) { HText(text: "Name",     width: Sizes.nWidth).background(.green) }
                        Button(action: {
                            print("sort on group")
                        }) {HText(text: "Group",     width: Sizes.gWidth).background(.gray) }
                        Spacer()
                        
                        // times...
                        
                    }
                }
                .frame(height:20)
                .background(.yellow)
                
                // Derby entries --------------------------------------------
                List (derby.entries) { entry in
                    VStack {
                        HStack {
                            DText(text: String(entry.carNumber), width: Sizes.cWidth).background(.gray)
                            DText(text: entry.carName,           width: Sizes.cnWidth).background(.purple)
                            DText(text: entry.name,              width: Sizes.nWidth).background(.gray)
                            DText(text: entry.group,             width: Sizes.gWidth).background(.purple)
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
                    .frame(minHeight: 30)
                    .swipeActions {
                        Button {
                            thisEntry = entry
                            showEditModal = true
                        } label: {
                            Label("Edit", systemImage: "square.and.pencil")
                        }
                        .tint(.yellow)
                        
                        Button {
                            print("Delete")
                            // add confirmation
                            
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                    .frame(width: UIScreen.main.bounds.size.width, height: 40)
                }
                .frame(width: UIScreen.main.bounds.size.width)
                .background(.yellow)
                
                Spacer()
                
                // Button Row ----------------------------------------
                VStack {
                    HStack {
                        Spacer()
                        
                        NavigationLink(destination: LazyView(HeatsView())) {
                            VStack {
                                VStack {
                                    Image(systemName: "tablecells").font(.system(size: 11))
                                    Text("Heats").font(.system(size: 11))
                                }
                            }
                        }
                        .frame(width: Sizes.bWidth)
                        .background(Color(.orange))
                        
                        Spacer().frame(width: 30)
                        
                        NavigationLink(destination: LazyView(SettingsView())) {
                            VStack {
                                VStack {
                                    Image(systemName: "gear").font(.system(size: 11))
                                    Text("Settings").font(.system(size: 11))
                                }
                            }
                        }
                        .frame(width: Sizes.bWidth)
                        .background(Color(.orange))
                        
                        Spacer().frame(width: 30)
                        
                        NavigationLink(destination: LazyView(InfoView())) {
                            VStack {
                                VStack {
                                    Image(systemName: "info.circle").font(.system(size: 11))
                                    Text("Info").font(.system(size: 11))
                                }
                            }
                        }
                        .frame(width: Sizes.bWidth)
                        .background(Color(.orange))
                        
                        Spacer()
                    }
                }
                .frame(height: 30)
                .background(.gray)
                
                Spacer().frame(height: 90)
            }
            .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            .background(.yellow)
            .sheet(isPresented: $showEditModal, content: { DerbyEditView(entry: $thisEntry) })
            // Navigation Bar --------------------------------
            //.navigationBarTitle("Derby", displayMode: .inline)
            //.navigationBarHidden(true)
            //.navigationViewStyle(StackNavigationViewStyle())  // iPads prefer master/detail view, this makes it look like an iPhone
//            .navigationBarItems(leading: EmptyView(), trailing: Button(action: {
//                thisEntry = nil
//                showEditModal = true
//            }) {
//                Image(systemName: "plus.circle")
//                //Text("+").font(.system(size: 14)).bold()
//            })
        }
    }
}
