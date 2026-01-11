//
//  UserCellDelegate.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import Foundation

/// Delegate protocol used by a user cell to notify the parent controller
/// about user interactions without creating tight coupling.
///
/// This keeps the cell reusable and shifts all navigation / logic handling
/// to the view controller.
protocol UserCellDelegate: AnyObject {

    /// Called when the info button inside a user cell is tapped.
    /// - Parameter indexPath: Identifies which user cell triggered the action.
    func didTapInfoButton(at indexPath: IndexPath)

    /// Called when the star (favorite) button inside a user cell is tapped.
    /// - Parameter indexPath: Identifies which user cell triggered the action.
    func didTapStarButton(at indexPath: IndexPath)
}
