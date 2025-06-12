//
//  GlobalStore.swift
//  Polaris
//
//  Created by Kevin Perez on 5/26/25.
//

import Foundation
import Observation

@Observable
class GlobalStore {
	var selectedTodo: Todo? = nil
	var showInspector: Bool = false
	
	func inspect(_ todo: Todo?) {
		selectedTodo = todo
		showInspector = todo != nil
	}
	
	func closeInspector() {
		showInspector = false
	}
}
