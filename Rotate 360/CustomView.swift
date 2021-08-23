//
//  CustomView.swift
//  Rotate 360
//
//  Created by 윤태민 on 6/16/20.
//  Copyright © 2020 Taemin Yun. All rights reserved.
//

//  View to draw buttons representing screens connected with a computer.
//  Clicking the button of the View makes the screen selected to perform rotating.
//  However the button representing internal screen cannot be selected.

import Cocoa

@IBDesignable
class CustomView: NSView {
    let margin: CGFloat = 20.0          // Margin between window and menu item
    
    var mouseLocation: NSPoint { NSEvent.mouseLocation }
    var buttons = [NSButton]()
    var drawKey: Bool = false           // make draw function excute only once

    static var selectedScreen: Int = -1          // to know which button is selected

    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if drawKey == false {
            drawKey = true

            buttons.forEach { $0.removeFromSuperview() }
            buttons.removeAll()

            drawCustomButtons()
        }
    }
}

extension CustomView {
    func drawCustomButtons() {
        // Decide active area of the CustomView.
        var viewSize = RectangleSize(self.bounds.width - margin, self.bounds.height - margin)
        
        let region = Region()
        let screens: [NSScreen] = NSScreen.screens
        
        screens.forEach { region.setProperties(screen: $0) }
        
        let scale = max(region.width / viewSize.width, region.height / viewSize.height)
        viewSize = RectangleSize(self.bounds.width, self.bounds.height)
        
        // Margins of horizon and vertical in the CustomView
        let hMargin = (viewSize.width - region.gapX / scale) / 2     // 2 is for each side
        let vMargin = (viewSize.height - region.gapY / scale) / 2
        
        // draw the button in the active area
        for (i, screen) in screens.enumerated() {
            // Distance to move to place the button in the region
            let x = (screen.frame.minX - region.minX) / scale + hMargin
            let y = (screen.frame.minY - region.minY) / scale + vMargin
            
            // Each screen's width and height
            let screenSize = RectangleSize(screen.frame.size.width / scale, screen.frame.size.height / scale)
            
            let button = NSButton(frame: NSRect(x: x, y: y, width: screenSize.width, height: screenSize.height))
            button.bezelStyle = NSButton.BezelStyle.smallSquare
            
            if AppDelegate.internalDisplayOrder == i {      // Internal display
                button.image = makeButtonImage(button, .disabledScreen)
                button.isEnabled = false
            }
            else {                                          // Non Iternal display
                if mouseLocation.isInTheScreen(screen) {
                    button.image = makeButtonImage(button, .enabledScreen)
                    CustomView.selectedScreen = i
                }
                else {
                    button.image = makeButtonImage(button, .disabledScreen)
                }
            }

            addSubview(button)
            button.target = self
            button.action = #selector(buttonClicked)
            buttons.append(button)
        }
    }
    
    func makeButtonImage(_ button: NSButton, _ color: NSColor) -> NSImage {
        return NSImage.paint(color: color, size: NSMakeSize(button.frame.size.width, button.frame.size.height))
    }
    
    @objc func buttonClicked(_ sender: NSButton) {
        buttons.forEach { $0.state = NSControl.StateValue.off }
        sender.state = NSControl.StateValue.on
        
        // Change image of button whenever selecting a button.
        for (i, button) in buttons.enumerated() {
            // Don't need to care about internal display.
            if AppDelegate.internalDisplayOrder != i {
                if button.state == NSControl.StateValue.on {
                    button.image = makeButtonImage(button, .enabledScreen)
                    CustomView.selectedScreen = i
                }
                else {
                    button.image = makeButtonImage(button, .disabledScreen)
                }
            }
        }
    }
}
