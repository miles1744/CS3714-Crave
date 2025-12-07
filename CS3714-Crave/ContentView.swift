//
//  ContentView.swift
//  CS3714-Crave
//
//  Created by Miles Thomas on 11/3/25.
//

import SwiftUI

/// Entry point for the app's UI
struct ContentView: View {
    var body: some View {
        // Show the authentication gate, which decides whether to show login or home
        AuthGateView()   // your real app root view
    }
}
