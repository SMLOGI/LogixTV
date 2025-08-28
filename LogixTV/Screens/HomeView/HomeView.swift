//
//  HomeView.swift
//  LogixTV
//
//  Created by Subodh  on 04/08/25.
//

import SwiftUI

struct HomeView: View {

    
    @FocusState.Binding var focusedItem: FocusTarget?
    
    var body: some View {
        ZStack {
            
            HomeHeaderView(focusedItem: $focusedItem)

            ScrollView(.horizontal) {
                LazyHGrid(rows: [GridItem(.fixed(160), spacing: 20)]) {
                    VStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: 320, height: 160)
                    }
                }
                .padding()
            }
            .focusSection()
        }
        .background(Color.red)
    }
}

#Preview {
    //HomeView()
}
