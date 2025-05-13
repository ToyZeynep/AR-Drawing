//
//  Button+.swift
//  ARDrawing
//
//  Created by Zeynep Toy on 11.05.2025.
//

import SwiftUI

extension Button {
    public func buttonStylePrimary(color: Color) -> some View {
        self
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 55)
            .background(color)
            .foregroundColor(.white)
            .font(.headline)
            .cornerRadius(12)
            .padding(.horizontal)
    }
}
