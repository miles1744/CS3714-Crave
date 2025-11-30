//
//  CS3714_CraveApp.swift
//  CS3714-Crave
//
//  Created by Miles Thomas on 11/3/25.
//

import SwiftUI
import SwiftData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@MainActor
final class AppState: ObservableObject {
    let container: ModelContainer
    let authVM: AuthViewModel

    init() {
        do {
            // Define SwiftData schema
            let schema = Schema([
                UserProfile.self,
                SavedRecipe.self      // 👈 add this line
            ])
            // In-memory store (DEV-FRIENDLY) to avoid disk/schema issues
            let config = ModelConfiguration(schema: schema,
                                            isStoredInMemoryOnly: true)

            container = try ModelContainer(for: schema,
                                           configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        // Use the container's mainContext for AuthViewModel
        authVM = AuthViewModel(context: container.mainContext)
    }
}

// Simple keyboard test view for debugging
struct KeyboardTestView: View {
    @State private var text = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Keyboard Test")
                .font(.largeTitle.bold())

            TextField("Type here", text: $text)
                .textFieldStyle(.roundedBorder)
                .padding()

            Text("You typed: \(text)")
        }
        .padding()
    }
}



@main
struct MyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            // 👉 FIRST: test keyboard with this.
            // Comment this out *after* you verify typing works here.
            // KeyboardTestView()

            // 👉 When keyboard works in KeyboardTestView, switch to this:
            AuthGateView()
                .environmentObject(appState.authVM)
                .modelContainer(appState.container)
        }
    }
}
