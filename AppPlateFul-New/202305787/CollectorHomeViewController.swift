//
//  CollectorHomeViewController.swift
//  AppPlateFul-New
//
//  Created by Hassan Fardan on 09/01/2026.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth


class CollectorHomeViewController: UIViewController {
    
    @IBOutlet weak var communityLeaderboardBtn: UIButton!
    @IBOutlet weak var updateDeliveryBtn: UIButton!
    @IBOutlet weak var collectorProfileBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    
    @IBAction func communityLeaderboardTapped(_ sender: UIButton) {
        // Navigate to leaderboard
    }
    
    @IBAction func updateDeliveryStatusTapped(_ sender: UIButton) {
        // Navigate to delivery status
    }
    
    @IBAction func collectorProfileTapped(_ sender: UIButton) {
        // Navigate to profile
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        // Handle logout
    }
}
