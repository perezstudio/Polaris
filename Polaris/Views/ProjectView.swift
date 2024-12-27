//
//  ProjectView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//

import SwiftUI

struct ProjectView: View {
	
	@Bindable var project: Project
	
    var body: some View {
		Text(project.title)
    }
}

//#Preview {
//    ProjectView()
//}
