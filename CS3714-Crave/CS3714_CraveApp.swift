//
//  CS3714_CraveApp.swift
//  CS3714-Crave
//
//  Created by Miles Thomas on 11/3/25.
//

// New Comment

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions:
                   [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}


@main
struct CS3714_CraveApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            NavigationView{
                ContentView()
            }
        }
    }
}
