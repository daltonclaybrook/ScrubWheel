//
//  ViewController.swift
//  ScrubWheel
//
//  Created by Dalton Claybrook on 11/5/16.
//  Copyright © 2016 Claybrook Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scrubWheel: ScrubWheel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrubWheel.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: ScrubWheelDelegate {
    
    func scrubWheel(_ wheel: ScrubWheel, startedAt location: CGPoint) {
        
    }
}
