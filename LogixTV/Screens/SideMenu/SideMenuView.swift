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
    @ObservedObject var viewModel: SideMenuViewModel
        
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            if let logoItem = viewModel.logo {
                if let url = URL(string: logoItem.details.unselectedImageLink) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 60, height: 60)
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                    .padding(.bottom, 30)
                }
                
            }
            let menuItems = viewModel.menuList
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(menuItems.indices, id: \.self) { index in
                        let isFocused = focusedField == .menu(index)
                        
                        Button {
                            selectedIndex = index
                            focusedField = .menu(index)
                        } label: {
                            HStack(spacing: 12) {
                                if let url = URL(string: isFocused ?  menuItems[index].details.unselectedImageLink : menuItems[index].details.unselectedImageLink) {
                                    AsyncImage(url: url) { image in
                                        image.resizable()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 50, height: 50)
                                }
                                
                                if isFocused {
                                    Text(menuItems[index].details.displayName)
                                        .font(.headline)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isFocused ? Color.white.opacity(0.2) : .clear)
                            )
                            .scaleEffect(isFocused ? 1.15 : 1.0)
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                        .focused($focusedField, equals: .menu(index))
                        .padding()
                        .animation(.easeInOut(duration: 0.2), value: focusedField)
                    }
                }
                .focusSection()
                .onMoveCommand { dir in
                    if dir == .right {
                        focusedField = .playButton
                    }
                }
            Spacer()
        }
        .task {
            await viewModel.loadMenu()
        }
        .onAppear {
            // set initial focus when view appears
            focusedField = .menu(0)
        }
    }
}


#Preview {
    //SideMenuView()
}
