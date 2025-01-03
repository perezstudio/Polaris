import Foundation
import Supabase

class AuthManager: ObservableObject {
	@Published var isAuthenticated = false
	
	private let supabase = SupabaseClient(
		supabaseURL: URL(string: "https://umgtvtvhhmbosbpifnnd.supabase.co")!,
		supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVtZ3R2dHZoaG1ib3NicGlmbm5kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU4NjAxMTMsImV4cCI6MjA1MTQzNjExM30.Q_76qww6gkJrTmt50XNZn2mqfcRGZ_pX4faDQv9_5XI"
	)
	
	// Public getter for supabase
	var client: SupabaseClient {
		return supabase
	}
	
	init() {
		Task {
			await checkAuthStatus()
		}
	}
	
	// Check Authentication Status
	func checkAuthStatus() async {
		let session = try? await supabase.auth.session
		DispatchQueue.main.async {
			self.isAuthenticated = session != nil
		}
	}
	
	// Login
	func login(email: String, password: String) async throws {
		let _ = try await supabase.auth.signIn(email: email, password: password)
		await checkAuthStatus()
	}
	
	// Signup with Metadata and Email Confirmation
	func signup(email: String, password: String, metadata: UserMetadata) async throws {
		// Map UserMetadata directly into [String: AnyJSON]
		let metadataJSON: [String: AnyJSON] = [
			"first_name": try AnyJSON(metadata.firstName),
			"last_name": try AnyJSON(metadata.lastName),
			"date_of_birth": try AnyJSON(metadata.dateOfBirth)
		]
		
		// Perform signup with email confirmation
		let _ = try await supabase.auth.signUp(
			email: email,
			password: password,
			data: metadataJSON, // Pass the metadata as [String: AnyJSON]
			redirectTo: URL(string: "polaris://") // Redirect to the app
		)
		await checkAuthStatus()
	}
	
	func deleteLocalData() {
		let fileManager = FileManager.default
		let storeURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
		
		do {
			// Remove all SQLite database files (including .sqlite-wal and .sqlite-shm)
			let files = try fileManager.contentsOfDirectory(at: storeURL, includingPropertiesForKeys: nil)
			for file in files {
				if file.pathExtension == "sqlite" || file.pathExtension.hasPrefix("sqlite") {
					try fileManager.removeItem(at: file)
					print("Deleted database file: \(file.lastPathComponent)")
				}
			}
			print("Database cleared.")
		} catch {
			print("Failed to delete database: \(error.localizedDescription)")
		}
	}
	
	func clearSession() {
		Task {
			do {
				try await supabase.auth.signOut()
				await checkAuthStatus() // Refresh authentication state
			} catch {
				print("Failed to clear Supabase session: \(error.localizedDescription)")
			}
		}
		
		// Clear Keychain data
		clearKeychain()
		
		// Clear any cached session tokens
		UserDefaults.standard.removeObject(forKey: "supabase.auth.token")
		UserDefaults.standard.synchronize()
		
		print("Session cleared.")
	}
	
	func clearKeychain() {
		let secItemClasses = [
			kSecClassGenericPassword,
			kSecClassInternetPassword,
			kSecClassCertificate,
			kSecClassKey,
			kSecClassIdentity,
		]

		for itemClass in secItemClasses {
			let query: [String: Any] = [kSecClass as String: itemClass]
			SecItemDelete(query as CFDictionary)
		}
		print("Keychain cleared.")
	}
	
	// Logout
	func logout() async {
		do {
			// Clear Supabase session
			try await supabase.auth.signOut()
			
			// Clear everything else
			clearSession()
			deleteLocalData()
			clearKeychain() // Clear Keychain session
			await checkAuthStatus()
		} catch {
			print("Failed to sign out: \(error.localizedDescription)")
		}
	}
}
