//
//  ScrubWheel.swift
//  ScrubWheel
//
//  Created by Dalton Claybrook on 11/5/16.
//  Copyright © 2016 Claybrook Software. All rights reserved.
//

import UIKit

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(point.x - self.x, 2.0) + pow(point.y - self.y, 2.0))
    }
}

protocol ScrubWheelDelegate: class {
    func scrubWheel(_ wheel: ScrubWheel, startedAt location: CGPoint)
}

class ScrubWheel: UIView {
 
    enum State {
        case idle, opening, scrubbing
    }
    
    weak var delegate: ScrubWheelDelegate?
    private(set) var state: State = .idle
    var radius: CGFloat = 200.0
    
    //MARK: Initializers
    
    init() {
        super.init(frame: .zero)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(ScrubWheel.panGestureRecognized(_:)))
        addGestureRecognizer(gesture)
    }
    
    //MARK: Actions
    
    @objc private func panGestureRecognized(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        let translation = gesture.translation(in: self)
        let initialLocation = CGPoint(x: location.x + translation.x, y: location.y + translation.y)
        let distance = location.distance(to: initialLocation)
        
        switch gesture.state {
        case .began:
            state = .opening
            delegate?.scrubWheel(self, startedAt: location)
        case .changed:
            
            break
        case .cancelled:
            break
        case .ended:
            break
        case .failed:
            break
        case .possible:
            break
        default:
            break
        }
    }
    
    //MARK: Private
}
