//
//  DonorTabBarController.swift
//  AppPlateFul
//

import UIKit

class DonorTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🚀 DonorTabBar viewDidLoad")
        setupTabBar()
    }
    
    private func setupTabBar() {
        let greenColor = UIColor(red: 0.725, green: 0.796, blue: 0.631, alpha: 1)
        let creamColor = UIColor(red: 0.969, green: 0.957, blue: 0.933, alpha: 1)
        
        tabBar.tintColor = greenColor
        tabBar.unselectedItemTintColor = .gray
        tabBar.backgroundColor = creamColor
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = creamColor
            appearance.stackedLayoutAppearance.selected.iconColor = greenColor
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: greenColor]
            appearance.stackedLayoutAppearance.normal.iconColor = .gray
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
