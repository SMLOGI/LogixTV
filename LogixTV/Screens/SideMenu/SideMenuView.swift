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
    @EnvironmentObject var globalNavState: GlobalNavigationState

    private var sidebarWidth: CGFloat { isSidebarExpanded ? 250 : 100 }

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            logoView
            menuListView
            Spacer()
        }
        .frame(width: sidebarWidth)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.8), Color.black.opacity(0.3)]),
                startPoint: .leading,   // start from left
                endPoint: .trailing     // end at right
            )
        )
        .animation(.easeInOut(duration: 0.3), value: isSidebarExpanded)
        .focusSection()
        .onMoveCommand(perform: handleMoveCommand)
        .onCompatibleChange(of: focusedField, perform: handleFocusChange)
        .task { await viewModel.loadMenu() }
        .onAppear { setupInitialState() }
        .sheet(isPresented: $isShowingSearch) {
            SearchView(focusedField: $focusedField)
        }
    }

    // MARK: - Logo View
    private var logoView: some View {
        Group {
            if let logoItem = viewModel.logo,
               let url = viewModel.logoURL {
                CachedAsyncImage(url: url)
                .frame(width: 60, height: 60)
                .padding(.horizontal, 20)
                .padding(.top, 50)
                .padding(.bottom, 30)
            }
        }
    }

    // MARK: - Menu List
    private var menuListView: some View {
        VStack(alignment: .leading, spacing: 10) {
            searchButton
            ForEach(viewModel.menuList.indices, id: \.self) { index in
                menuButton(for: index)
            }
        }
        .frame(width: sidebarWidth)
    }

    private var searchButton: some View {
        Button {
            isShowingSearch = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.appPurple)
                Text("Search")
                    .font(.headline)
                    .opacity(focusedField == .searchOption ? 1 : 0)
            }
            .padding(.horizontal, isSidebarExpanded ? 12 : 2)
            .padding(.vertical, 10)
            .frame(width: sidebarWidth, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(focusedField == .searchOption ? Color.gray : .clear)
            )
        }
        .buttonStyle(.borderless)
        .focused($focusedField, equals: .searchOption)
        .padding(.horizontal, isSidebarExpanded ? 2 : 15)
    }

    private func menuButton(for index: Int) -> some View {
        let isFocused = focusedField == .menu(index)
        let menuItem = viewModel.menuList[index]
        let imageURL = viewModel.menuItemURL(at: index)

        return Button {
            selectedIndex = index
            focusedField = .menu(index)
        } label: {
            HStack(spacing: 12) {
                
                if let url = imageURL {
                    CachedAsyncImage(url: url)
                    .frame(width: 50, height: 50)
                }

                Text(menuItem.details.displayName)
                    .font(.headline)
                    .opacity(isFocused ? 1 : 0)
            }
            .padding(.horizontal, isSidebarExpanded ? 2 : 15)
            .padding(.vertical, 10)
            .frame(width: sidebarWidth, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isFocused ? Color.gray : .clear)
            )
        }
        .buttonStyle(.borderless)
        .focused($focusedField, equals: .menu(index))
        .padding(.horizontal, isSidebarExpanded ? 2 : 15)
    }

    // MARK: - Handlers
    private func handleMoveCommand(_ direction: MoveCommandDirection) {
        switch direction {
        case .right:
            if case .menu = focusedField {
                focusedField = .pageDot(0)
                globalNavState.bannerIndex = 0
            } else if focusedField == .searchOption {
                focusedField = .pageDot(0)
                globalNavState.bannerIndex = 0
            }
        case .left:
            if case .pageDot = focusedField {
                focusedField = .menu(0)
            }
        default: break
        }
    }

    private func handleFocusChange(_ oldFocus: FocusTarget?,  _ newFocus: FocusTarget?) {
        
        print("onChange oldFocus: \(String(describing: oldFocus)) newFocus:\(String(describing: newFocus))")
        
        switch newFocus {
        case .menu:
            isSidebarExpanded = true
        case .searchOption:
            isSidebarExpanded = true
        default:
            isSidebarExpanded = false
        }
        
        if case .pageDot = oldFocus, case .menu = newFocus {
            focusedField = .menu(0)
        }
        if case .carouselItem = oldFocus, case .menu = newFocus {
            focusedField = .menu(0)
        }
    }

    private func setupInitialState() {
        focusedField = .menu(0)
        isSidebarExpanded = true
    }
}

// MARK: - ViewModel helpers for precomputed URLs
extension SideMenuViewModel {
    var logoURL: URL? {
        guard let logoItem = logo else { return nil }
        return URL(string: logoItem.details.unselectedImageLink)
    }

    func menuItemURL(at index: Int) -> URL? {
        guard menuList.indices.contains(index) else { return nil }
        return URL(string: menuList[index].details.focusImageLink)
    }
}



#Preview {
    //SideMenuView()
}
