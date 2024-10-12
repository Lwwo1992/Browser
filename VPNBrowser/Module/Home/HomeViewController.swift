//
//  HomeViewController.swift
//  VPNBrowser
//
//  Created by xyxy on 2024/10/8.
//

import UIKit

class HomeViewController: ViewController {
    override var rootView: AnyView? {
        return AnyView(HomeView())
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
