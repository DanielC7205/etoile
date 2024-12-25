//
//  FullFetchViewController.swift
//  etoile
//
//  Created by Juliette Bernheisel on 9/4/24.
//

import Foundation
import UIKit
import SwiftUI

class FullFetchViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hostingVc = UIHostingController(rootView: FullFetchLibraryView(callback: {
        }))
        hostingVc.rootView.callback = {
            let newHostingVc = HostingTabViewController()
            newHostingVc.modalPresentationStyle = .fullScreen
            hostingVc.present(newHostingVc, animated: true)
        }
        hostingVc.view.backgroundColor = .etoileBackground()
        hostingVc.modalPresentationStyle = .fullScreen
        present(hostingVc, animated: true)
    }
}
