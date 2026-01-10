import UIKit

class DonationHomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the navigation bar on the home screen
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func viewDonationsTapped(_ sender: UIButton) {
        // Push the My Donations screen defined in the storyboard
        guard let listVC = storyboard?.instantiateViewController(
            withIdentifier: "DonationListViewController"
        ) as? DonationListViewController else {
            print("Could not instantiate DonationListViewController")
            return
        }
        navigationController?.pushViewController(listVC, animated: true)
    }
}
