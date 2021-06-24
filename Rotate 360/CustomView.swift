//
//  CustomView.swift
//  Rotate 360
//
//  Created by 윤태민 on 6/16/20.
//  Copyright © 2020 Taemin Yun. All rights reserved.
//

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
//        print("required init")
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

    @objc func buttonClicked(_ sender: NSButton) {
        buttons.forEach { $0.state = NSControl.StateValue.off }
        sender.state = NSControl.StateValue.on
        
        // change image of button whenever selecting a button
        for i in 0 ..< buttons.count {
            // don't need to care about internal display
            if AppDelegate.internalDisplayOrder != i {
                if buttons[i].state == NSControl.StateValue.on {
                    buttons[i].image = makeButtonImage(buttons[i], .enabledScreen)
                    
                    CustomView.selectedScreen = i
                }
                else {
                    buttons[i].image = makeButtonImage(buttons[i], .disabledScreen)
                }
            }
        }
    }
}

extension CustomView {
    func drawCustomButtons() {
        // decide active area of the CustomView
        var viewWidth: CGFloat = self.bounds.width - margin
        var viewHeight: CGFloat = self.bounds.height - margin
        
        let region = Region()
        let screens: [NSScreen] = NSScreen.screens
        
        screens.forEach { region.setProperties(screen: $0) }
        
        let scale = max(region.width / viewWidth, region.height / viewHeight)
        viewWidth += margin
        viewHeight += margin
        
        // Margins of horizon and vertical in the CustomView
        let hMargin = (viewWidth - (region.maxX - region.minX) / scale) / 2     // 2 is for each side
        let vMargin = (viewHeight - (region.maxY - region.minY) / scale) / 2
        
        // draw the button in the active area
        for i in 0 ..< screens.count {
            // distance to move to place the button in the region
            let x = (screens[i].frame.minX - region.minX) / scale + hMargin
            let y = (screens[i].frame.minY - region.minY) / scale + vMargin
            
            // Each screen's width and height
            let width = screens[i].frame.size.width / scale
            let height = screens[i].frame.size.height / scale
            
            let button = NSButton(frame: NSRect(x: x, y: y, width: width, height: height))
            button.bezelStyle = NSButton.BezelStyle.smallSquare
            
            if AppDelegate.internalDisplayOrder == i {      // internal display
                button.image = makeButtonImage(button, .disabledScreen)
                button.isEnabled = false
            }
            else {                                          // auxiliary display
                if mouseLocation.isInTheScreen(screens[i]) {
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
        return NSImage.swatchWithColor(color: color, size: NSMakeSize(button.frame.size.width, button.frame.size.height))
    }
}
