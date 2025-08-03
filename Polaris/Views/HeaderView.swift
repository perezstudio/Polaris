//
//  HeaderView.swift
//  Polaris
//
//  Created by Kevin Perez on 7/13/25.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
		HStack(spacing: 12) {
			Image(systemName: "tray.fill")
				.font(.title)
				.foregroundStyle(Color.blue)

			Text("Inbox")
				.font(.largeTitle)
				.fontWeight(.bold)

			Spacer()
		}
		.padding(.top, 4)
		.padding(.horizontal)
    }
}

#Preview {
    HeaderView()
}
