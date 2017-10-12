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
fileprivate extension ViewController {
    func setup() {
        DropdownAlert.defaultBackgroundColor = UIColor.black
        DropdownAlert.defaultTextColor = UIColor.white
        self.basicAnimationButton.addTarget(self, action: #selector(ViewController.showBasicAnimation), for: .touchUpInside)
        self.springAnimationButton.addTarget(self, action: #selector(ViewController.showSpringAnimation), for: .touchUpInside)
    }
}

fileprivate extension ViewController {
    @objc func showBasicAnimation() {
        DropdownAlert.showWithAnimation(animationType: .Basic(timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)), title: "Sweet demo!", message: "Look how cool this is!", duration: 2)
    }

    @objc func showSpringAnimation() {
        DropdownAlert.showWithAnimation(animationType: .Spring(bounce: 15, speed: 12), title: "Spring", message: "So bouncy!", duration: 2)
        //DropdownAlert.showWithAnimation(animationType: animationType,: .Spring(bounce: 15, speed: 12), title: "Spring", message: "So bouncy!", duration: 2)
    }

}
