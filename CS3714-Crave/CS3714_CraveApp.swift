//
//  CS3714_CraveApp.swift
//  CS3714-Crave
//
//  Created by Miles Thomas on 11/3/25.
//

// New Comment

import SwiftUI
import SwiftData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

// Mark the holder as @MainActor so creating AuthViewModel(context:) is allowed
@MainActor
final class AppState: ObservableObject {
  let container: ModelContainer
  let context: ModelContext
  let authVM: AuthViewModel

  init() {
    container = try! ModelContainer(for: UserProfile.self)
    context = ModelContext(container)
    authVM = AuthViewModel(context: context) // now OK (main-actor isolated)
  }
}

@main
struct MyApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @StateObject private var appState = AppState()

  var body: some Scene {
    WindowGroup {
      AuthGateView()
        .environment(\.modelContext, appState.context)
        .environmentObject(appState.authVM)
    }
  }
}
