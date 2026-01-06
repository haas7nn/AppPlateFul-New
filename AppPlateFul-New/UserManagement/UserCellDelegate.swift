//
//  UserCellDelegate.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import Foundation

// Delegate protocol for handling user cell interactions
protocol UserCellDelegate: AnyObject {
    
    // Triggered when the info button is tapped
    func didTapInfoButton(at indexPath: IndexPath)
    
    // Triggered when the star (favorite) button is tapped
    func didTapStarButton(at indexPath: IndexPath)
}
