//
//  ViewController.swift
//  DropdownAlert
//
//  Created by Brendan Conron on 05/22/2016.
//  Copyright (c) 2016 Brendan Conron. All rights reserved.
//

import UIKit
import DropdownAlert

class ViewController: UIViewController {

    // MARK: - Views

    @IBOutlet weak var basicAnimationButton: UIButton!
    @IBOutlet weak var springAnimationButton: UIButton!



}

// MARK: - UIViewController
extension ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }



}

// MARK: - Setup
private extension ViewController {
    private func setup() {
        DropdownAlert.defaultBackgroundColor = UIColor.blackColor()
        DropdownAlert.defaultTextColor = UIColor.whiteColor()
        self.basicAnimationButton.addTarget(self, action: #selector(showBasicAnimation), forControlEvents: .TouchUpInside)
        self.springAnimationButton.addTarget(self, action: #selector(showSpringAnimation), forControlEvents: .TouchUpInside)
    }
}

private extension ViewController {
    @objc private func showBasicAnimation() {
        DropdownAlert.showWithAnimation(.Basic(timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)), title: "Sweet demo!", message: "Look how cool this is!", duration: 2)
    }

    @objc private func showSpringAnimation() {
        DropdownAlert.showWithAnimation(.Spring(bounce: 15, speed: 12), title: "Spring", message: "So bouncy!", duration: 2)
    }

}
