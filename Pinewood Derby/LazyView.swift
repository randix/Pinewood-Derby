//
//  LazyView.swift
//
//  Created by Rand Dow on 9/21/21.
//

import SwiftUI

// Normally a view is instantiated when its users are being initialized.
// This makes the operation lazy.
struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
