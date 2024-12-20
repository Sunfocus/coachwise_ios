//
//  Router.swift
//  SecurityGuard
//
//  Created by Sunfocus Solutions on 13/11/24.
//

import Foundation
import SwiftUI

final class Router: ObservableObject {
    
    enum NavigationStyle {
        case push
        case present
    }
    
    enum RootFlow {
        case onboarding
        case tab
    }
    
    @Published var authNavPath = NavigationPath()
    @Published var dashboardNavPath = NavigationPath()
    @Published var isUserLoggedIn: Bool = true
    @Published var isModalPresented = false
    
    var root: RootFlow = .onboarding
    var currentModalDestination: AnyHashable?
    private var authDestinations: [AuthFlow] = []
    private var dashboardDestinations: [DashboardFlow] = []
    
    func setRoot(to newRoot: RootFlow) {
        root = newRoot
        switch newRoot {
        case .onboarding:
            authNavigateToRoot()
        case .tab:
            dashboardNavigateToRoot()
        }
    }
}


extension Router {
    
    // Generic navigation to push or present a destination.
    func navigate<T: Hashable>(
        to destination: T,
        path: inout NavigationPath,
        destinations: inout [T],
        style: NavigationStyle = .push
    ) {
        switch style {
        case .push:
            handlePushNavigation(to: destination, path: &path, destinations: &destinations)
        case .present:
            handlePresentNavigation(to: destination)
        }
    }
    
    // Handle push navigation, adding/removing destination from path and destinations.
    private func handlePushNavigation<T: Hashable>(
        to destination: T,
        path: inout NavigationPath,
        destinations: inout [T]
    ) {
        if let index = destinations.firstIndex(of: destination) {
            path.removeLast(path.count - (index + 1))
            destinations.removeLast(destinations.count - (index + 1))
        } else {
            path.append(destination)
            destinations.append(destination)
        }
    }
    
    private func handlePresentNavigation<T: Hashable>(to destination: T) {
        if let modalDestination = destination as? AuthFlow {
            currentModalDestination = modalDestination
            isModalPresented = true
        } else {
            assertionFailure("Present style is not supported for this destination type.")
        }
    }
    
    func navigateBack<T>(path: inout NavigationPath, destinations: inout [T]) {
        guard !destinations.isEmpty else { return }
        path.removeLast()
        destinations.removeLast()
    }
    func navigateToRoot<T>(path: inout NavigationPath, destinations: inout [T]) {
        path = NavigationPath()
        destinations.removeAll()
    }
}

//MARK: - Auth Flow -
extension Router {
    func navigate(to destination: AuthFlow, style: NavigationStyle = .push) {
        navigate(to: destination, path: &authNavPath, destinations: &authDestinations, style: style)
    }
    func authNavigateBack() {
        navigateBack(path: &authNavPath, destinations: &authDestinations)
    }
    func authNavigateToRoot() {
        navigateToRoot(path: &authNavPath, destinations: &authDestinations)
    }
}
//MARK: - Dashboard Flow -
extension Router{
    func navigate(to destination: DashboardFlow, style: NavigationStyle = .push) {
        navigate(to: destination, path: &dashboardNavPath, destinations: &dashboardDestinations, style: style)
    }
    func dashboardNavigateBack() {
        navigateBack(path: &dashboardNavPath, destinations: &dashboardDestinations)
    }
    func dashboardNavigateToRoot() {
        navigateToRoot(path: &dashboardNavPath, destinations: &dashboardDestinations)
    }
}
