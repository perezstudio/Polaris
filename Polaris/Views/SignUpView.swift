//
//  SignUpView.swift
//  Polaris
//
//  Created by Kevin Perez on 1/2/25.
//

import SwiftUI
import Supabase

struct SignUpView: View {
    @ObservedObject var authManager: AuthManager
    
    // Form Fields
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var dateOfBirth = Date()
    @State private var agreedToTerms = false
    
    // Error Handling
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    Text("Create an Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Get started with Polaris and manage your tasks effortlessly.")
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 20)
                    
                    // First Name & Last Name
                    HStack(spacing: 12) {
                        TextField("First Name", text: $firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                        TextField("Last Name", text: $lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                    }
                    
                    // Email
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    // Password
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Confirm Password
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Date of Birth Picker
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                        .datePickerStyle(.compact)
                    
                    // Terms of Service Checkbox
                    Toggle(isOn: $agreedToTerms) {
                        Text("I agree to the Terms of Service")
                    }
                    
                    // Error Message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    // Sign Up Button
                    Button(action: {
                        signUpUser()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                            } else {
                                Text("Sign Up")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isFormValid)
                }
                .padding()
            }
            .navigationTitle("Sign Up")
        }
    }
    
    // MARK: - Form Validation
    private var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        password == confirmPassword &&
        password.count >= 8 &&
        agreedToTerms
    }
    
    // MARK: - Sign Up User
	private func signUpUser() {
		guard isFormValid else {
			errorMessage = "Please fill out all fields correctly and agree to the Terms of Service."
			return
		}

		isLoading = true
		errorMessage = ""
		
		let metadata = UserMetadata(
			firstName: firstName,
			lastName: lastName,
			dateOfBirth: ISO8601DateFormatter().string(from: dateOfBirth) // Convert Date to ISO8601 String
		)
		
		Task {
			do {
				try await authManager.signup(
					email: email,
					password: password,
					metadata: metadata
				)
			} catch {
				errorMessage = error.localizedDescription
			}
			isLoading = false
		}
	}
}
