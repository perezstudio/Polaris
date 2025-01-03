//
//  AccountView.swift
//  Polaris
//
//  Created by Kevin Perez on 1/2/25.
//

import SwiftUI
import Supabase

struct AccountView: View {
	@ObservedObject var authManager: AuthManager // ObservedObject works fine here
	
	// User State
	@State private var firstName: String = ""
	@State private var lastName: String = ""
	@State private var dateOfBirth: String = ""
	@State private var email: String = ""
	@State private var isEditing = false
	@State private var errorMessage = ""
	@State private var isLoading = false
	
	var body: some View {
		NavigationStack {
			Form {
				// Account Details Section
				SwiftUI.Section(header: Text("Account Details")) {
					TextField("First Name", text: $firstName)
						.disabled(!isEditing)
					TextField("Last Name", text: $lastName)
						.disabled(!isEditing)
					TextField("Date of Birth", text: $dateOfBirth)
						.disabled(!isEditing)
					TextField("Email", text: $email)
						.disabled(true) // Email can't be changed
				}
				
				// Error Message
				if !errorMessage.isEmpty {
					Text(errorMessage)
						.foregroundColor(.red)
						.font(.caption)
						.padding(.top, 8)
				}
				
				// Save Changes Button
				if isEditing {
					Button(action: {
						updateAccount()
					}) {
						HStack {
							if isLoading {
								ProgressView()
							} else {
								Text("Save Changes")
							}
						}
						.frame(maxWidth: .infinity)
					}
					.buttonStyle(.borderedProminent)
				}
				
				// Logout Button
				SwiftUI.Section {
					Button("Logout", role: .destructive) {
						Task {
							await authManager.logout()
						}
					}
				}
			}
			.navigationTitle("Account")
			.navigationBarItems(trailing: Button(isEditing ? "Cancel" : "Edit") {
				isEditing.toggle()
			})
			.onAppear {
				Task {
					await fetchUserData()
				}
			}
		}
	}
	
	// MARK: - Fetch User Data
	private func fetchUserData() async {
		do {
			// Access the Supabase client from AuthManager
			let user = try await authManager.client.auth.user()
			
			// Retrieve metadata
			let metadata = user.userMetadata as? [String: Any] ?? [:]
			firstName = metadata["first_name"] as? String ?? ""
			lastName = metadata["last_name"] as? String ?? ""
			dateOfBirth = metadata["date_of_birth"] as? String ?? ""
			email = user.email ?? ""
		} catch {
			errorMessage = "Failed to fetch user data: \(error.localizedDescription)"
		}
	}
	
	// MARK: - Update Account
	private func updateAccount() {
		isLoading = true
		errorMessage = ""
		
		Task {
			do {
				let metadata: [String: AnyJSON] = [
					"first_name": try AnyJSON(firstName),
					"last_name": try AnyJSON(lastName),
					"date_of_birth": try AnyJSON(dateOfBirth)
				]
				
				// Update user metadata
				try await authManager.client.auth.update(
					user: UserAttributes(data: metadata)
				)
				
				isEditing = false
			} catch {
				errorMessage = "Failed to update account: \(error.localizedDescription)"
			}
			isLoading = false
		}
	}
}

#Preview {
	AccountView(authManager: AuthManager())
}
