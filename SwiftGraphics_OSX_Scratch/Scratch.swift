//
//  Scratch.swift
//  SwiftGraphics
//
//  Created by Jonathan Wight on 1/26/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import SwiftGraphics

class Thing: HitTestable, Drawable {

    typealias ThingType = protocol <HitTestable, Drawable, Geometry>

    let geometry:ThingType
    var transform:CGAffineTransform = CGAffineTransformIdentity

    init(geometry:ThingType) {
        self.geometry = geometry
        self.center = geometry.frame.mid
    }

    var bounds:CGRect { get { return geometry.frame } }

    var center:CGPoint = CGPointZero

    var frame:CGRect { get { return CGRect(center:center, size:bounds.size) } }

    func drawInContext(context:CGContextRef) {
        let localTransform = transform + CGAffineTransform(translation: frame.origin)
        context.with(localTransform) {
            self.geometry.drawInContext(context)
        }
        context.strokeRect(frame)
    }

    func contains(point:CGPoint) -> Bool {
        return (frame * transform).contains(point)
    }

//    func onEdge(point:CGPoint, lineThickness:CGFloat) -> Bool {
//        return geometry.onEdge(point, lineThickness: lineThickness)
//    }

//    var position: CGPoint {
//        get {
//            return frame.mid * transform
//        }
//        set {
//            let oldValue = position
//            let delta = newValue - oldValue
//            transform = transform + CGAffineTransform(translation: delta)
//        }
//    }

}



extension Rectangle: HitTestable {
    public func contains(point:CGPoint) -> Bool {
        return self.frame.contains(point)
    }

//    // TODO: Move to "EdgeHitTestable" protocol?
//    public func onEdge(point:CGPoint, lineThickness:CGFloat) -> Bool {
//        if self.frame.insetted(dx: -lineThickness * 0.5, dy: -lineThickness * 0.5).contains(point) {
//            return self.frame.insetted(dx: lineThickness * 0.5, dy: lineThickness * 0.5).contains(point) == false
//        }
//        return false
//    }
}





extension NSIndexSet {

    func with <T>(array:Array <T>, maxCount:Int = 512, block:Array <T> -> Void) {
        with(maxCount:maxCount) {
            (buffer:UnsafeBufferPointer<Int>) -> Void in
            var items:Array <T> = []
            for index in buffer {
                items.append(array[index])
            }
            block(items)
        }
    }

    func with(maxCount:Int = 512, block:UnsafeBufferPointer <Int> -> Void) {

        var range = NSRange(location:0, length:self.count)
        var indices = Array <Int> (count:maxCount, repeatedValue: NSNotFound)
        indices.withUnsafeMutableBufferPointer() {
            (inout buffer:UnsafeMutableBufferPointer<Int>) -> Void in

            var count = 0
            do  {
                count = self.getIndexes(buffer.baseAddress, maxCount: maxCount, inIndexRange: &range)
                if count > 0 {
                    let constrained_buffer = UnsafeBufferPointer<Int> (start: buffer.baseAddress, count: count)
                    block(constrained_buffer)
                }
            }
            while count > 0
        }
    }



//getIndexes(buffer, maxCount: 1000, inIndexRange: nil)

}