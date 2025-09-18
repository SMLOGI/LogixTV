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

            // ✅ focusSection applied only to menu block
            VStack(alignment: .leading, spacing: 10) {

                Button {
                    isShowingSearch = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color.appPurple)

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
                            if let url = URL(string: isFocused ? menuItems[index].details.focusImageLink : menuItems[index].details.unselectedImageLink) {
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
                    .focused($focusedField, equals: .menu(index))
                    .padding()
                    .animation(.easeInOut(duration: 0.2), value: focusedField)
                }
            }
            .focusSection()   // ✅ sidebar section ends here
            .defaultFocus($focusedField, .menu(0))
            
            Spacer()

            Text(focusedField?.description ?? "No Focus")
                .font(.system(size: 20))
                .frame(width: 60)
        }
        .background {
            if isSidebarExpanded {
                Color.black.opacity(0.5)
            } else {
                Color.black
            }
        }
        .onMoveCommand { dir in
            switch dir {
            case .right:
                focusedField = .playButton   // ✅ ensure this exists in FocusTarget
            default:
                break
            }
        }
        .onChange(of: focusedField) { oldFocus, newFocus in
            print("onChange oldFocus: \(String(describing: oldFocus)) newFocus:\(String(describing: newFocus))")

            switch newFocus {
            case .menu:
                isSidebarExpanded = true
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
            print("onAppear SideMenuView")
            focusedField = .menu(0)   // ✅ safe initial fallback
            isSidebarExpanded = true
        }
        .sheet(isPresented: $isShowingSearch) {
            SearchView(focusedField: $focusedField)
        }
    }
}


#Preview {
    //SideMenuView()
}
