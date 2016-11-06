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
    func scrubWheel(_ wheel: ScrubWheel, didAdvanceBy arcLength: CGFloat)
    func scrubWheelDidOpen(_ wheel: ScrubWheel)
    func scrubWheelDidClose(_ wheel: ScrubWheel)
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
    private(set) var absoluteTouchLocation: CGPoint?
    private(set) var touchLocation: TouchLocation?
    
    var radius: CGFloat = 100.0
    var centerDotRadius: CGFloat = 3.0
    var touchDotRadius: CGFloat = 10.0
    
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
        
    }
    
    //MARK: Superclass
    
    override func draw(_ rect: CGRect) {
        guard state != .idle, let location = touchLocation, let context = UIGraphicsGetCurrentContext() else { return }
        
        // Center Dot
        let centerRect = circleRect(withRadius: centerDotRadius, center: location.center)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setFillColor(UIColor.black.cgColor)
        context.setLineWidth(2.0)
        context.addEllipse(in: centerRect)
        
        // Outer Ring
        let outerRad = radius + touchDotRadius + 4.0
        let innerRad = radius - touchDotRadius - 4.0
        let outerRect = circleRect(withRadius: outerRad, center: location.center)
        let innerRect = circleRect(withRadius: innerRad, center: location.center)
        context.addEllipse(in: outerRect)
        context.addEllipse(in: innerRect)
        
        let touchDotRect: CGRect
        let pathRadius: CGFloat
        let lineTerminatorPoint: CGPoint
        
        switch state {
        case .opening:
            pathRadius = location.distance()
            touchDotRect = circleRect(withRadius: touchDotRadius, center: location.absolute)
            lineTerminatorPoint = location.absolute
        default:
            pathRadius = radius
            touchDotRect = circleRect(withRadius: touchDotRadius, center: location.circularized)
            lineTerminatorPoint = location.circularized
        }
        
        context.move(to: location.center)
        context.addLine(to: lineTerminatorPoint)
        
        let rect = circleRect(withRadius: pathRadius, center: location.center)
        context.addEllipse(in: rect)
        context.addEllipse(in: touchDotRect)
        
        context.strokePath()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let location = touches.first.flatMap({ $0.location(in: self) }) else { return }
        state = .opening
        touchLocation = TouchLocation(center: location, absolute: location, circularized: .zero)
        delegate?.scrubWheel(self, startedAt: location)
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let location = touches.first.flatMap({ $0.location(in: self) }), let lastTouchLocation = touchLocation else { return }
        
        let centerLocation = lastTouchLocation.center
        let circularLocation = circularizedLocation(fromCenter: centerLocation, location: location)
        let currentTouchLocation = TouchLocation(center: centerLocation, absolute: location, circularized: circularLocation)
        touchLocation = currentTouchLocation
        
        evaluateGestureChanged(currentLocation: currentTouchLocation, lastLocation: lastTouchLocation)
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        cancel()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        cancel()
    }
    
    //MARK: Private
    
    private func cancel() {
        state = .idle
        touchLocation = nil
        delegate?.scrubWheelDidClose(self)
        setNeedsDisplay()
    }
    
    private func evaluateGestureChanged(currentLocation: TouchLocation, lastLocation: TouchLocation) {
        let distance = currentLocation.absolute.distance(to: currentLocation.center)
        if case .opening = state, distance >= radius {
            state = .scrubbing
            delegate?.scrubWheelDidOpen(self)
        } else if case .scrubbing = state {
            var deltaAngle = currentLocation.angle() - lastLocation.angle()
            if abs(deltaAngle) > CGFloat(3.0 * M_PI / 2.0) {
                // correction for crossing over from 2*PI to 0, or vice versa
                let mod = deltaAngle < 0.0 ? M_PI * 2.0 : -M_PI * 2.0
                deltaAngle += CGFloat(mod)
            }
            let distance = radius * deltaAngle
            delegate?.scrubWheel(self, didAdvanceBy: distance)
        }
    }
    
    private func circularizedLocation(fromCenter center: CGPoint, location: CGPoint) -> CGPoint {
        let angle = atan2(location.y - center.y, location.x - center.x)
        return CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
    }
    
    private func circleRect(withRadius radius: CGFloat, center: CGPoint) -> CGRect {
        return CGRect(x: center.x - radius, y: center.y - radius, width: radius*2, height: radius*2)
    }
}
