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
    @EnvironmentObject var globalNavState: GlobalNavigationState
    
    private let menuFont: Font = .system(size: 30, weight: .medium, design: .rounded)

    private var sidebarWidth: CGFloat {
        return isSidebarExpanded ? 230 : 100
    }
    private var sidebarPadding: CGFloat { isSidebarExpanded ? 10 : 4 }

    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            
            logoView
            menuListView
            Spacer()
            
            shaddowTrappedView
        }
        .frame(width: sidebarWidth)
        .background(
            .regularMaterial // or .thinMaterial, .regularMaterial, etc.
        )
       // .animation(.easeInOut(duration: 0.3), value: isSidebarExpanded)
        .focusSection()
        .onCompatibleChange(of: focusedField, perform: handleFocusChange)
        .task { await viewModel.loadMenu() }
        .onAppear { setupInitialState() }

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
    
    private var shaddowTrappedView: some View {
        Color.clear
            .frame(width: 50, height: 50)
            .focusable(true)
            .focused($focusedField, equals: .trapFocused)
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
        SideMenuItemView(
            isFocused: focusedField == .searchOption,
            isExpanded: isSidebarExpanded,
            title: "Search",
            icon: .system(name: "magnifyingglass", color: Color.appPurple),
            width: sidebarWidth,
            padding: sidebarPadding,
            highlightColor: .white,
            textColor: .white.opacity(0.8)
        ) {
            globalNavState.activeScreen = .search
        }
        .focused($focusedField, equals: .searchOption)
    }

    private func menuButton(for index: Int) -> some View {
        let isFocused = focusedField == .menu(index)
        let menuItem = viewModel.menuList[index]
        let imageURL = viewModel.menuItemURL(at: index)

        return SideMenuItemView(
            isFocused: isFocused,
            isExpanded: isSidebarExpanded,
            title: menuItem.details.displayName,
            icon: .remote(url: imageURL!),
            width: sidebarWidth,
            padding: sidebarPadding,
            highlightColor: .white,
            textColor: .white.opacity(0.8)
        ) {
            selectedIndex = index
            focusedField = .menu(index)
            isSidebarExpanded = isSidebarExpanded
        }
        .focused($focusedField, equals: .menu(index))
        .onMoveCommand(perform: handleMoveCommand)
    }

    // MARK: - Handlers
    private func handleMoveCommand(_ direction: MoveCommandDirection) {
        switch direction {
        case .right:
            if case .menu = focusedField {
                withAnimation {
                    focusedField = .pageDot(0)
                    globalNavState.bannerIndex = 0
                    self.isSidebarExpanded = false
                }
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
        case .menu, .searchOption, .trapFocused:
            if isSidebarExpanded == false {
                isSidebarExpanded = true
            }
        default:
            if isSidebarExpanded {
                isSidebarExpanded = false
            }
        }
        
        if case .pageDot = oldFocus, case .menu = newFocus {
            focusedField = .menu(0)
        } else if case .carouselItem = oldFocus, case .menu = newFocus {
            focusedField = .menu(0)
        } else if focusedField == .trapFocused {
            print("handleFocusChange trapFocused")
            focusedField = .menu(viewModel.menuList.count - 1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                print("handleFocusChange trapFocused asyncAfter")
                focusedField = .menu(viewModel.menuList.count - 1)
            }
        } else if newFocus == .sideTrappedFocused, case .menu = oldFocus {
            focusedField = .pageDot(0)
        }else if newFocus == .sideTrappedFocused, case .pageDot = oldFocus {
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
        // print("***** Url for (\(index)) : \(menuList[index].details.focusImageLink)")
        return URL(string: menuList[index].details.focusImageLink)
    }
}



#Preview {
    //SideMenuView()
}
