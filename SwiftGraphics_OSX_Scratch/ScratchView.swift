//
//  ScratchView.swift
//  SwiftGraphics
//
//  Created by Jonathan Wight on 1/25/15.
//  Copyright (c) 2015 schwa.io. All rights reserved.
//

import Cocoa

import SwiftGraphics

class Model {
    var things:[Thing]
    var selectedThings:NSMutableIndexSet = NSMutableIndexSet()

    init() {
        things = [
            Thing(geometry:Rectangle(frame:CGRect(x:0, y:0, width:100, height:100))),
        ]
    }

    func objectForPoint(point:CGPoint) -> Thing? {
        for (index, thing) in enumerate(things) {
            if thing.contains(point) {
                return thing
            }
        }
        return nil
    }
}

class Dragging: NSObject {

    var view:NSView! {
        didSet {
            view.addGestureRecognizer(NSClickGestureRecognizer(target: self, action: Selector("click:")))
            view.addGestureRecognizer(NSPanGestureRecognizer(target: self, action: Selector("pan:")))
        }
    }
    var model:Model!

    func click(gestureRecognizer:NSClickGestureRecognizer) {
        let location = gestureRecognizer.locationInView(view)

        for (index, thing) in enumerate(model.things) {
            if thing.contains(location) {
                model.selectedThings.addIndex(index)
                view.needsDisplay = true
                return
            }
        }

        model.selectedThings.removeAllIndexes()
        view.needsDisplay = true
    }

    var draggedObject:Thing? = nil
    var offset:CGPoint = CGPointZero

    func pan(recognizer:NSPanGestureRecognizer) {
        let location = recognizer.locationInView(view)

        switch recognizer.state { 
            case .Began:
                draggedObject = model.objectForPoint(location)
                if let draggedObject = draggedObject {
                    offset = location - draggedObject.center
                }
            case .Changed:
                if let draggedObject = draggedObject {
                    draggedObject.center = location - offset
                }
                break
            case .Ended:
                draggedObject = nil
                offset = CGPointZero
//                dragDidFinish?()
            default:
                break
        }


        view.needsDisplay = true
    }

}


class ScratchView: NSView {

    var model = Model()
    var dragging = Dragging()

    required init?(coder: NSCoder) {
        super.init(coder:coder)

        dragging.view = self
        dragging.model = model
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        let context = NSGraphicsContext.currentContext()!.CGContext

        for (index, thing) in enumerate(model.things) {
            if model.selectedThings.containsIndex(index) {
                context.strokeColor = CGColor.redColor()
            }
            thing.drawInContext(context)
        }
    }

}
