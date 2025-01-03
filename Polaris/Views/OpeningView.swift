//
//  OpeningView.swift
//  Polaris
//
//  Created by Kevin Perez on 1/2/25.
//

import SwiftUI

struct OpeningView: View {
	
	@ObservedObject var authManager: AuthManager
	@State var loginSheet: Bool = false
	@State var signupSheet: Bool = false
	
    var body: some View {
		NavigationStack {
			VStack(alignment: .leading, spacing: 16) {
				HStack {
					Text("Polaris")
						.fontWeight(.bold)
				}
				VStack(alignment: .leading, spacing: 16) {
					Text("Your Tasks, Perfectly Aligned.")
						.font(.largeTitle)
						.fontWeight(.bold)
					Text("Plan smarter, organize effortlessly, and stay focused on what matters most")
						.font(.title)
						.fontWeight(.semibold)
						.foregroundStyle(.gray.opacity(0.8))
				}
				Spacer()
				VStack(spacing: 10) {
					Button {
						signupSheet.toggle()
					} label: {
						Label("Create Account", systemImage: "person.fill.badge.plus")
							.labelStyle(.titleOnly)
							.padding(.vertical, 8)
							.frame(maxWidth: .infinity)
					}
					.frame(maxWidth: .infinity)
					.buttonStyle(.borderedProminent)
					Button {
						loginSheet.toggle()
					} label: {
						Label("Login", systemImage: "person.fill.badge.plus")
							.labelStyle(.titleOnly)
							.padding(.vertical, 8)
							.frame(maxWidth: .infinity)
					}
					.buttonStyle(.bordered)
				}
			}
			.padding(.horizontal, 40)
			.padding(.top, 100)
			.padding(.bottom, 50)
			.sheet(isPresented: $loginSheet) {
				LoginView(authManager: authManager)
			}
			.sheet(isPresented: $signupSheet) {
				SignUpView(authManager: authManager)
			}
		}
		.background(Color(UIColor.systemGroupedBackground))
    }
}

#Preview {
	let mockAuthManager = MockAuthManager() // Use mock manager for preview
	return OpeningView(authManager: mockAuthManager)
}
