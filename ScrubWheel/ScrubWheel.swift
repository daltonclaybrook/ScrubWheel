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
    func scrubWheelDidOpen(_ wheel: ScrubWheel)
}

class ScrubWheel: UIView {
 
    enum State {
        case idle
        case opening
        case scrubbing
    }
    
    struct TouchLocation {
        let center: CGPoint
        let absolute: CGPoint
        let circularized: CGPoint
        
        func angle() -> CGFloat {
            return atan2(circularized.y - center.y, circularized.x - center.x)
        }
        
        func distance() -> CGFloat {
            return absolute.distance(to: center)
        }
    }
    
    weak var delegate: ScrubWheelDelegate?
    private(set) var state: State = .idle
    var radius: CGFloat = 200.0
    private(set) var absoluteTouchLocation: CGPoint?
    private(set) var touchLocation: TouchLocation?
    
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
        let centerLocation = touchLocation?.center ?? location
        let circularLocation = circularizedLocation(fromCenter: center, location: location)
        let currentTouchLocation = TouchLocation(center: centerLocation, absolute: location, circularized: circularLocation)
        let lastTouchLocation = touchLocation
        touchLocation = currentTouchLocation
        
        switch gesture.state {
        case .began:
            state = .opening
            delegate?.scrubWheel(self, startedAt: location)
        case .changed:
            evaluateGestureChanged(currentLocation: currentTouchLocation, lastLocation: lastTouchLocation)
        default:
            state = .idle
            touchLocation = nil
        }
        
        //print("state: \(state), center: \(centerLocation), distance: \(currentTouchLocation.distance())")
    }
    
    //MARK: Private
    
    private func evaluateGestureChanged(currentLocation: TouchLocation, lastLocation: TouchLocation?) {
        let distance = currentLocation.absolute.distance(to: currentLocation.center)
        if case .opening = state, distance >= radius {
            state = .scrubbing
            delegate?.scrubWheelDidOpen(self)
        } else if case .scrubbing = state, let lastLocation = lastLocation {
            let deltaAngle = currentLocation.angle() - lastLocation.angle()
            let distance = radius * deltaAngle
            print("traveled distance: \(distance)")
        }
    }
    
    private func circularizedLocation(fromCenter center: CGPoint, location: CGPoint) -> CGPoint {
        /*
         var x = dist * cos(angle * Mathf.Deg2Rad);
         var y = dist * sin(angle * Mathf.Deg2Rad);
         var newPosition = currentPosition;
         newPosition.x += x;
         newPosition.y += y;
         */
        
        let angle = Double(atan2(location.y - center.y, location.x - center.x))
        let delta = CGPoint(x: radius * CGFloat(cos(angle)), y: radius * CGFloat(sin(angle)))
        return CGPoint(x: center.x + delta.x, y: center.y + delta.y)
    }
}
