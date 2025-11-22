//
//  ThemeManager.swift
//  FinalProject
//
//  Created by Арсений on 21.11.2025.
//

import UIKit

final class ThemeManager {
    static let shared = ThemeManager()
    
    private let themeKey = "isDarkTheme"
    
    var isDarkTheme: Bool {
        get {
            return UserDefaults.standard.bool(forKey: themeKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: themeKey)
            applyTheme(isDark: newValue)
        }
    }
    
    private init() {
        applyTheme(isDark: isDarkTheme)
    }
    
    private func applyTheme(isDark: Bool) {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { window in
                window.overrideUserInterfaceStyle = isDark ? .dark : .light
            }
    }
    
    func toggleTheme() {
        isDarkTheme.toggle()
    }
}
    
    
    
                                        
                                        
