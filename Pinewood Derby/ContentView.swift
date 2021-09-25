//
//  ContentView.swift
//
//  Created by Rand Dow on 9/21/21.
//

import SwiftUI

struct ContentView: View {
    
    @State var link = true
    
    var body: some View {
        NavigationView {
            NavigationLink(destination: DerbyView(), isActive: $link) {
                Text("").frame(width: 20)
            }
            VStack {
                HStack {
                    Spacer().frame(minWidth: 0)
                }
                Spacer().frame(minHeight: 0)
            }
        }
//        .frame(width: UIScreen.main.bounds.size.width,
//               height: UIScreen.main.bounds.size.height,
//               alignment: .leading)
//        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
//        .edgesIgnoringSafeArea(.all)
        
        //.navigationBarHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())  // iPads prefer master/detail view, this makes it look like an iPhone
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
