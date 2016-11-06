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
    @IBOutlet weak var progressLabel: UILabel!
    
    fileprivate var progress: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrubWheel.delegate = self
        showProgress()
    }
    
    fileprivate func showProgress() {
        progressLabel.text = "\(Int(round(progress)))"
    }
}

extension ViewController: ScrubWheelDelegate {
    
    func scrubWheel(_ wheel: ScrubWheel, startedAt location: CGPoint) {
        
    }
    
    func scrubWheel(_ wheel: ScrubWheel, didAdvanceBy arcLength: CGFloat) {
        progress += arcLength
        showProgress()
    }
    
    func scrubWheelDidOpen(_ wheel: ScrubWheel) {
        showProgress()
    }
    
    func scrubWheelDidClose(_ wheel: ScrubWheel) {
        
    }
}
