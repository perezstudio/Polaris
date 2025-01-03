//
//  PolarisApp.swift
//  Polaris
//
//  Created by Kevin Perez on 10/18/24.
//

import SwiftUI
import SwiftData
import Supabase

@main
struct PolarisApp: App {
	// Configure Supabase Client
	let supabase = SupabaseClient(
		supabaseURL: URL(string: "https://umgtvtvhhmbosbpifnnd.supabase.co")!,
		supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVtZ3R2dHZoaG1ib3NicGlmbm5kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU4NjAxMTMsImV4cCI6MjA1MTQzNjExM30.Q_76qww6gkJrTmt50XNZn2mqfcRGZ_pX4faDQv9_5XI"
	)
	
	let syncManager: SyncManager

	init() {
		// Initialize SyncManager with ModelContainer's context
		syncManager = SyncManager(context: container.mainContext)
	}
	
	// Track Authentication State
	@StateObject private var authManager = AuthManager()
	
	var container: ModelContainer = {
		let schema = Schema([
			Todo.self,
			Project.self,
			SearchItem.self
		])
		let modelConfiguration = ModelConfiguration(
			schema: schema,
			isStoredInMemoryOnly: false
		)
		
		do {
			return try ModelContainer(for: schema)
		} catch {
			fatalError("Failed to initialize model container: \(error)")
		}
	}()
	
	var body: some Scene {
		WindowGroup {
			Group {
				if authManager.isAuthenticated {
					ContentView(authManager: authManager, syncManager: syncManager)
						.modelContainer(container) // Inject ModelContainer here
						.ignoresSafeArea(.keyboard, edges: .bottom)
				} else {
					OpeningView(authManager: authManager)
						.modelContainer(container) // Inject ModelContainer here
				}
			}
			.onOpenURL { url in
				// Handle Supabase Auth Deep Linking
				Task {
					do {
						try await supabase.auth.session(from: url)
						await authManager.checkAuthStatus()
					} catch {
						print("Failed to handle URL: \(error.localizedDescription)")
					}
				}
			}
		}
	}
}
