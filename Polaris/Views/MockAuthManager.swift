//
//  MockAuthManager.swift
//  Polaris
//
//  Created by Kevin Perez on 1/2/25.
//

class MockAuthManager: AuthManager {
	override init() {
		super.init()
		self.isAuthenticated = false // Set to false for preview purposes
	}
	
	override func login(email: String, password: String) async throws {
		// Mock login behavior for preview
		print("Mock Login: \(email)")
	}
}
