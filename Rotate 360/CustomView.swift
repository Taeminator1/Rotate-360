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
    
    var mouseLocation: NSPoint { NSEvent.mouseLocation }
    
    var buttons = [NSButton]()
    var button = NSButton()
    
    var minX: CGFloat = 0
    var minY: CGFloat = 0
    var maxX: CGFloat = 0
    var maxY: CGFloat = 0               // for x, y coordinates to include conneted screens
    var lengthX: CGFloat = 0
    var lengthY: CGFloat = 0            // size of region wehre there are screens
    
    let margin: CGFloat = 20.0          // Margin between window and menu item
//    let lineWidth: CGFloat = 1.0
    
    var width: CGFloat = 360
    var height: CGFloat = 160           // Size of CustomView
    
    var scale: CGFloat = 0
    
    var drawKey: Bool = false           // make draw function excute only once
    
    static var selectedScreen: Int = -1          // to know which button is selected
    
    override init(frame frameRect: NSRect) {
        super.init(frame:frameRect);
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)!
        
//        print("required init method in CustomView")
    }
    
    init(frame frameRect: NSRect, otherInfo:Int) {
        super.init(frame:frameRect);
        
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
//        print("draw funtion in CustomView")
        
        if drawKey == false {
            drawKey = true

            for i in 0 ..< buttons.count {
                buttons[i].removeFromSuperview()
            }
            buttons.removeAll()

            makeCustomButtons()
        }
    }
    
    
    
    func makeCustomButtons() {
        
        minX = 0; minY = 0; maxX = 0; maxY = 0;
        lengthX = 0; lengthY = 0
        
        width = 360; height = 160
        
        scale = 0
        
        let screens: [NSScreen] = NSScreen.screens
        
        // decide region for connected screens`
        for i in 0 ..< screens.count {
            if screens[i].frame.minX < minX { minX = screens[i].frame.minX }
            if screens[i].frame.minY < minY { minY = screens[i].frame.minY }
            if screens[i].frame.maxX > maxX { maxX = screens[i].frame.maxX }
            if screens[i].frame.maxY > maxY { maxY = screens[i].frame.maxY }
            
            lengthX += screens[i].frame.maxX - screens[i].frame.minX
            lengthY += screens[i].frame.maxY - screens[i].frame.minY
        }
        
        scale = (lengthX / width) > (lengthY / height) ? (lengthX / width) : (lengthY / height)
        width += margin
        height += margin
        
        for i in 0 ..< screens.count {
            button = NSButton(frame: NSRect(
                x: (screens[i].frame.minX - minX)/scale + (width-(maxX-minX)/scale)/2,
                y: (screens[i].frame.minY - minY)/scale + (height-(maxY-minY)/scale)/2,
                width: screens[i].frame.size.width/scale,
                height: screens[i].frame.size.height/scale))
            button.title =  "button[\(i)]"
            button.bezelStyle = NSButton.BezelStyle.smallSquare
            
            if AppDelegate.internalDisplayOrder != i {      // for not internal display
                if mouseLocation.x >= screens[i].frame.minX && mouseLocation.x <= screens[i].frame.maxX && mouseLocation.y >= screens[i].frame.minY && mouseLocation.y <= screens[i].frame.maxY {
                    button.image = NSImage.swatchWithColor(color: NSColor(red: 99/255, green: 157/255, blue: 214/255, alpha: 1.0), size: NSMakeSize(button.frame.size.width, button.frame.size.height))
                    
                    CustomView.selectedScreen = i
                }
                else {
                    button.image = NSImage.swatchWithColor(color: NSColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1.0), size: NSMakeSize(button.frame.size.width, button.frame.size.height))
                }
            }
            else {                                          // for internal display
                button.image = NSImage.swatchWithColor(color: NSColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1.0), size: NSMakeSize(button.frame.size.width, button.frame.size.height))
                button.isEnabled = false
            }
            
            // Things to do: give name to the button of the screen
//            button.title = "Screen Name"

            addSubview(button)
            button.target = self
            button.action = #selector(buttonClicked)
            buttons.append(button)
            
//            if AppDelegate.internalDisplayOrder == i {
////                button.title = "Internal Display"
//                button.isEnabled = false
//            }
        }
    }

    @objc func buttonClicked(_ sender: NSButton) {
        
        for i in 0 ..< buttons.count {
            buttons[i].state = NSControl.StateValue.off
        }
        
        sender.state = NSControl.StateValue.on
        
        // change image of button whenever selecting a button
        for i in 0 ..< buttons.count {
            // don't need to care about internal display
            if AppDelegate.internalDisplayOrder != i {
                if buttons[i].state == NSControl.StateValue.on {
                    buttons[i].image = NSImage.swatchWithColor(color: NSColor(red: 99/255, green: 157/255, blue: 214/255, alpha: 1.0), size: NSMakeSize(buttons[i].frame.size.width, buttons[i].frame.size.height))
                    
                    CustomView.selectedScreen = i
    //                print("Button[\(i)] is clicked.")
                }
                else {
                    buttons[i].image = NSImage.swatchWithColor(color: NSColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1.0), size: NSMakeSize(buttons[i].frame.size.width, buttons[i].frame.size.height))
                }
            }
        }
    }
}

extension NSImage {
class func swatchWithColor(color: NSColor, size: NSSize) -> NSImage {
    let image = NSImage(size: size)
    
    image.lockFocus()
    color.drawSwatch(in: NSMakeRect(0, 0, size.width, size.height))
    image.unlockFocus()
    
    return image
   }
}