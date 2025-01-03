//
//  LoginView.swift
//  Polaris
//
//  Created by Kevin Perez on 1/2/25.
//


//
//  LoginView.swift
//  Polaris
//
//  Created by Kevin Perez on 1/2/25.
//

import SwiftUI
import Supabase

struct LoginView: View {
	@ObservedObject var authManager: AuthManager
	
	@State private var email = ""
	@State private var password = ""
	@State private var errorMessage = ""
	@State private var isLoading = false
	
	var body: some View {
		NavigationStack {
			VStack(alignment: .leading, spacing: 16) {
				Text("Welcome Back!")
					.font(.largeTitle)
					.fontWeight(.bold)
				
				Text("Manage your tasks effortlessly!")
					.foregroundStyle(.secondary)
					.padding(.bottom, 20)
				
				// Email Field
				TextField("Email", text: $email)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.autocapitalization(.none)
					.padding(.bottom, 8)
				
				// Password Field
				SecureField("Password", text: $password)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.padding(.bottom, 16)
				
				// Error Message
				if !errorMessage.isEmpty {
					Text(errorMessage)
						.foregroundColor(.red)
						.font(.caption)
						.padding(.bottom, 8)
				}
				
				// Login Button
				Button(action: {
					loginUser()
				}) {
					HStack {
						if isLoading {
							ProgressView()
						} else {
							Text("Login")
								.font(.headline)
								.padding(.vertical, 8)
						}
					}
					.frame(maxWidth: .infinity)
				}
				.buttonStyle(.borderedProminent)
				.padding(.bottom, 8)
			}
			.padding()
		}
	}
	
	// Login Function
	private func loginUser() {
		isLoading = true
		errorMessage = ""
		
		Task {
			do {
				try await authManager.login(email: email, password: password)
			} catch {
				errorMessage = error.localizedDescription
			}
			isLoading = false
		}
	}
}

#Preview {
	let mockAuthManager = MockAuthManager() // Use mock manager for preview
	return LoginView(authManager: mockAuthManager)
}
