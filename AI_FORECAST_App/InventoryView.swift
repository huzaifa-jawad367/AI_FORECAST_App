//
//  InventoryView.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 20/02/2025.
//

import SwiftUI

struct InventoryView: View {
    
    @Binding var authState: AuthState
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    InventoryView(authState: .constant(.Inventory))
}
