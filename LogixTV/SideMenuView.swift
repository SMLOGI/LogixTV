//
//  SideMenuView.swift
//  LogixTV
//
//  Created by Subodh  on 05/08/25.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var isSidebarExpanded: Bool
    @Binding var selectedIndex: Int
    @FocusState.Binding var focusedField: FocusTarget?
    let menuItems: [MenuItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 100) {
            Image(systemName: "play.tv.fill")
                .font(.largeTitle)
                .foregroundColor(.purple)
                .padding(.top, 150)
                .padding(.bottom, 100)
                .frame(height: 60)
            
            VStack(alignment: .leading, spacing: 20) {
                ForEach(menuItems.indices, id: \.self) { index in
                    let isFocused = focusedField == .menu(index)
                    
                    HStack(spacing: 12) {
                        Image(systemName: menuItems[index].icon)
                            .font(.headline)
                            .foregroundColor(isFocused ? .black : .white)
                        
                        Text(menuItems[index].title)
                            .foregroundColor(isFocused ? .black : .white)
                            .font(.headline)
                            .opacity(isSidebarExpanded || isFocused ? 1 : 0)
                            .animation(.easeInOut(duration: 0.2), value: isSidebarExpanded)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        isFocused ?
                        Color.white.opacity(0.2) :
                            Color.clear
                    )
                    .cornerRadius(10)
                    .focusable(true)
                    .focused($focusedField, equals: .menu(index))
                    .onTapGesture {
                        selectedIndex = index
                    }
                }
            }
            
            Spacer()
        }
        .padding(.top)
        .background(
            Group {
                if focusedField != nil {
                    LinearGradient(
                        colors: [Color.black, Color.purple.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                } else {
                    Color.clear
                }
            }
        )
        .frame(maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.3), value: focusedField)
        .focusSection()
    }
}

#Preview {
    //SideMenuView()
}
