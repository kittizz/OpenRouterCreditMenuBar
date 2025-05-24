//
//  ContentView.swift
//  OpenRouterCreditMenuBar
//
//  Created by Kittithat Patepakorn on 24/5/2568 BE.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("OpenRouter Credit Menu Bar")
                .font(.title)
            Text("Check your menu bar for the credit display!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 300, height: 200)
    }
}

#Preview {
    ContentView()
}
