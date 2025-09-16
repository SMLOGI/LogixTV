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
    @State private var isShowingSearch = false

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            if let logoItem = viewModel.logo {
                if let url = URL(string: logoItem.details.unselectedImageLink) {
                    CachedAsyncImage(url: url)
                    .frame(width: 60, height: 60)
                    .padding(.horizontal, 20)
                    .padding(.top, 50)
                    .padding(.bottom, 30)
                }
                
            }
            let menuItems = viewModel.menuList
                VStack(alignment: .leading, spacing: 20) {
                    
                    Button {
                        //selectedIndex = index
                        //focusedField = .menu(index)
                        isShowingSearch = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                            
                            if focusedField == .searchOption {
                                Text("Search")
                                    .font(.headline)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(focusedField == .searchOption ? Color.gray : .clear)
                        )
                        .scaleEffect(focusedField == .searchOption ? 1.15 : 1.0)
                    }
                    .buttonStyle(.borderless)
                    //.contentShape(Rectangle())
                    .focused($focusedField, equals: .searchOption)
                    .padding()
                    .animation(.easeInOut(duration: 0.2), value: focusedField)
                    
                    ForEach(menuItems.indices, id: \.self) { index in
                        let isFocused = focusedField == .menu(index)
                        
                        Button {
                            selectedIndex = index
                            focusedField = .menu(index)
                        } label: {
                            HStack(spacing: 12) {
                                if let url = URL(string: isFocused ?  menuItems[index].details.focusImageLink : menuItems[index].details.unselectedImageLink) {
                                    CachedAsyncImage(url: url)
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
                                    .fill(isFocused ? Color.gray : .clear)
                            )
                            .scaleEffect(isFocused ? 1.15 : 1.0)
                        }
                        .buttonStyle(.borderless)
                        //.contentShape(Rectangle())
                        .focused($focusedField, equals: .menu(index))
                        .padding()
                        .animation(.easeInOut(duration: 0.2), value: focusedField)
                    }
                }
                .onMoveCommand { dir in
                    switch dir {
                    case .right:
                        focusedField = .playButton
                    default:
                        break
                    }
                }
            Spacer()
            Text(focusedField?.description ?? "No Focus")
                .font(.system(size: 20))
                .frame(width: 60)
        }
        .background {
            if isSidebarExpanded {
                /*LinearGradient(
                        colors: [Color.white.opacity(0.5), Color.white.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .blur(radius: 10)*/
                Color.black.opacity(0.5)
            } else {
                Color.black
            }
        }
        .focusSection()
        .onChange(of: focusedField) { oldFocus, newFocus in
            switch newFocus {
            case .menu(let index):
                isSidebarExpanded = true
                
                if case .menu = oldFocus {
                    // old focus was already menu → don’t reset
                } else {
                    focusedField = .menu(0)
                }
                print("Menu \(index) focused")
            case .searchOption:
                isSidebarExpanded = true
            default:
                isSidebarExpanded = false
            }
        }
        .task {
            await viewModel.loadMenu()
        }
        .onAppear {
            // set initial focus when view appears
            focusedField = .menu(0)
            isSidebarExpanded =  true
        }
        .sheet(isPresented: $isShowingSearch) {
            SearchView(focusedField: $focusedField)   // Pass your dataset if needed
        }
    }
}


#Preview {
    //SideMenuView()
}
