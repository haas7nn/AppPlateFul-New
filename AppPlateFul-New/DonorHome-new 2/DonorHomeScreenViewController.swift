//
//  DonorHomeScreenViewController.swift
//  AppPlateFul
//
//  Created by Jxu on 08/01/2026.
//

import UIKit

class DonorHomeScreenViewController: UIViewController{
    
    @IBOutlet weak var CommunityLeaderBoard: UIButton!
    
    @IBOutlet weak var FavNGOS: UIButton!
    
    @IBOutlet weak var MyDonations: UIButton!
    
    @IBOutlet weak var TrackDeliveries: UIButton!
    
    @IBOutlet weak var DonationUpdates: UIButton!
    
    @IBOutlet weak var RecDonations: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CommunityLeaderBoard.layer.cornerRadius = 10
        FavNGOS.layer.cornerRadius = 10
        MyDonations.layer.cornerRadius = 10
        TrackDeliveries.layer.cornerRadius = 10
        DonationUpdates.layer.cornerRadius = 10
        RecDonations.layer.cornerRadius = 10
        
    }
}
