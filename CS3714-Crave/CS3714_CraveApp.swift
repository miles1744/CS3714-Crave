//
//  CS3714_CraveApp.swift
//  CS3714-Crave
//
//  Created by Miles Thomas on 11/3/25.
//

import SwiftUI
import SwiftData
import FirebaseCore

/// Handles Firebase setup when the app launches
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()
        return true
    }
}

/// Global application state, including SwiftData and AuthViewModel
@MainActor
final class AppState: ObservableObject {
    let container: ModelContainer         // Holds the in-memory SwiftData store
    let authVM: AuthViewModel             // Handles authentication and user profile logic

    init() {
        do {
            // Define the SwiftData schema with your model types
            let schema = Schema([
                UserProfile.self,
                SavedRecipe.self,
                ChefRecipe.self
            ])

            // Create in-memory-only data configuration for temporary storage
            let config = ModelConfiguration(schema: schema,
                                            isStoredInMemoryOnly: true)

            // Initialize SwiftData model container
            container = try ModelContainer(for: schema,
                                           configurations: [config])
        } catch {
            // Crash the app if SwiftData setup fails
            fatalError("Failed to create ModelContainer: \(error)")
        }

        // Create the authentication view model using the SwiftData context
        authVM = AuthViewModel(context: container.mainContext)
    }
}

/// Temporary view used to test keyboard input in SwiftUI
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

/// App entry point
@main
struct MyApp: App {
    // Connects the AppDelegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    // Holds shared state for the app
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            

            
            AuthGateView()
                .environmentObject(appState.authVM)       // Inject AuthViewModel
                .modelContainer(appState.container)       // Inject SwiftData container
        }
    }
}
