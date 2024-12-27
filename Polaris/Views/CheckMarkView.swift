//
//  CheckMarkView.swift
//  Polaris
//
//  Created by Kevin Perez on 12/26/24.
//


import SwiftUI

struct CheckMarkView: View {
    
    @Binding var todoStatus: Bool
    
    var body: some View {
        Image(systemName: "checkmark")
            .foregroundColor(todoStatus ? .white : .clear)
            .frame(width: 26, height: 26)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(todoStatus ? Color.blue : Color.clear)
                    .stroke(todoStatus ? Color.blue : Color.gray, lineWidth: 2)
            }
            .onTapGesture {
                withAnimation {
                    todoStatus.toggle()
                }
            }
    }
}
