//
//  CustomizationTooltip.swift
//  etoile
//
//  Created by Juliette Bernheisel on 9/30/24.
//

import Foundation
import UIKit

class CustomizationTooltip: UIViewController {
    init(up: @escaping () -> (), down: @escaping () -> ()) {
        self.up = up
        self.down = down
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let up: () -> ()
    let down: () -> ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.etoileBackground()
        
        let upButton = UIButton()
        upButton.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        upButton.setImage(UIImage(systemName: "chevron.up.circle.fill"), for: .selected)
        upButton.addTarget(self, action: #selector(upPressed), for: .touchUpInside)
        
        view.addSubview(upButton)
        
        upButton.snp.makeConstraints { make in
            make.height.equalTo(view.snp.height).multipliedBy(0.5)
            make.width.equalTo(view.snp.width).multipliedBy(0.5)
            make.left.equalTo(view)
            make.top.equalTo(view)
        }
        
        let downButton = UIButton()
        downButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        downButton.setImage(UIImage(systemName: "chevron.down.circle.fill"), for: .selected)
        downButton.addTarget(self, action: #selector(downPressed), for: .touchUpInside)
        
        view.addSubview(downButton)
        
        downButton.snp.makeConstraints { make in
            make.height.equalTo(view.snp.height).multipliedBy(0.5)
            make.width.equalTo(view.snp.width).multipliedBy(0.5)
            make.right.equalTo(view)
            make.top.equalTo(view)
        }
        
    }
    
    @objc func upPressed() {
        Task.detached {
            self.up()
        }
        dismiss(animated: true)
    }
    
    @objc func downPressed() {
        Task.detached {
            self.down()
        }
        dismiss(animated: true)
    }
}
