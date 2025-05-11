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
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}
