//
//  ProfileViewController.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 04/01/2026.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func notfication(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Notification", bundle: nil)
           let vc = storyboard.instantiateViewController(withIdentifier: "Notification")

           vc.hidesBottomBarWhenPushed = true   
           navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func logout(_ sender: Any) {
        UserSession.shared.logout()

         let storyboard = UIStoryboard(name: "TestSignin", bundle: nil)

         let loginNav = storyboard.instantiateViewController(
             withIdentifier: "TestSigninViewController"
         )

         guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first else {
             return
         }

         window.rootViewController = loginNav
         window.makeKeyAndVisible()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
