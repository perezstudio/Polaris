//
//  SyncManager.swift
//  Polaris
//
//  Created by Kevin Perez on 1/2/25.
//

import Foundation
import Supabase
import SwiftData
import Network

class SyncManager: ObservableObject {
	private let supabase = SupabaseClient(
		supabaseURL: URL(string: "https://umgtvtvhhmbosbpifnnd.supabase.co")!,
		supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVtZ3R2dHZoaG1ib3NicGlmbm5kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU4NjAxMTMsImV4cCI6MjA1MTQzNjExM30.Q_76qww6gkJrTmt50XNZn2mqfcRGZ_pX4faDQv9_5XI"
	)
	
	private let modelContext: ModelContext
	private let monitor = NWPathMonitor()
	private var isOnline = false
	
	init(context: ModelContext) {
		self.modelContext = context
		
		// Monitor network connectivity
		monitor.pathUpdateHandler = { path in
			self.isOnline = path.status == .satisfied
			if self.isOnline {
				Task {
					await self.syncProjects()
				}
			}
		}
		let queue = DispatchQueue(label: "Monitor")
		monitor.start(queue: queue)
	}
	
	// MARK: - Sync Projects
	func syncProjects() async {
		guard isOnline else { return }
		
		do {
			// Fetch local projects
			let fetchDescriptor = FetchDescriptor<Project>()
			let localProjects = try modelContext.fetch(fetchDescriptor)
			
			// Fetch remote projects from Supabase
			let response = try await supabase
				.from("projects") // Updated to use .from directly
				.select()
				.execute()
			
			// Decode the data
			let remoteProjects = try JSONDecoder().decode([SupabaseProject].self, from: response.data)
			
			// Sync from Remote to Local
			for remote in remoteProjects {
				if let localProject = localProjects.first(where: { $0.id == remote.id }) {
					// Update existing project if necessary
					if remote.created > localProject.created {
						updateLocalProject(localProject, from: remote)
					}
				} else {
					// Insert new remote project locally
					let newProject = Project(
						id: remote.id,
						title: remote.title,
						status: Status(rawValue: remote.status) ?? .InProgress,
						favorite: remote.favorite,
						icon: remote.icon,
						color: ColorPalette(rawValue: remote.color) ?? .blue,
						todos: []
					)
					modelContext.insert(newProject)
				}
			}
			
			// Sync from Local to Remote
			for local in localProjects {
				if !remoteProjects.contains(where: { $0.id == local.id }) {
					try await supabase
						.from("projects") // Updated to use .from directly
						.insert([
							"id": local.id.uuidString, // UUID -> String
							"title": local.title,
							"status": local.status.rawValue,
							"favorite": local.favorite ? "true" : "false", // Bool -> Bool (no string conversion needed)
							"icon": local.icon,
							"color": local.color.rawValue,
							"created": ISO8601DateFormatter().string(from: local.created), // Date -> ISO String
							"user_id": supabase.auth.session.user.id.uuidString ?? ""
						])
						.execute()
				}
			}
			
			// Save changes to the local database
			try modelContext.save()
			print("Sync completed successfully.")
		} catch {
			print("Failed to sync: \(error.localizedDescription)")
		}
	}
	
	// MARK: - Update Local Project
	private func updateLocalProject(_ local: Project, from remote: SupabaseProject) {
		local.title = remote.title
		local.status = Status(rawValue: remote.status) ?? .InProgress
		local.favorite = remote.favorite
		local.icon = remote.icon
		local.color = ColorPalette(rawValue: remote.color) ?? .blue
		local.created = remote.created
	}
}

// MARK: - Remote Model for Decoding
struct SupabaseProject: Codable {
	var id: UUID
	var title: String
	var status: String
	var favorite: Bool
	var icon: String
	var color: String
	var created: Date
}
