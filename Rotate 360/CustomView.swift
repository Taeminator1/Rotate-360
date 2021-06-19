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

            makeCustomButtons()
        }
    }
    
    func makeCustomButtons() {
        // View에 그릴 screen이 차지할 공간 결정
        var viewWidth: CGFloat = self.bounds.width - margin
        var viewHeight: CGFloat = self.bounds.height - margin
        
        let region = Region()
        let screens: [NSScreen] = NSScreen.screens
        
        screens.forEach { region.setProperties(screen: $0) }
        
        let scale = max(region.width / viewWidth, region.height / viewHeight)
        viewWidth += margin
        viewHeight += margin
        
        // View에 실제로 버튼 그리기
        for i in 0 ..< screens.count {
            let hMargin = (viewWidth - region.width / scale) / 2
            let vMargin = (viewHeight - region.height / scale) / 2
            
            // 각 스크린의 꼭지점이 region에 잘 배치되기 위해 이동해야할 거리
            let x = (screens[i].frame.minX - region.minX) / scale + hMargin
            let y = (screens[i].frame.minY - region.minY) / scale + vMargin
            
            // 각 스크린의 너비와 높이
            let width = screens[i].frame.size.width / scale
            let height = screens[i].frame.size.height / scale
            
            let button = NSButton(frame: NSRect(x: x, y: y, width: width, height: height))
            button.bezelStyle = NSButton.BezelStyle.smallSquare
            
            if AppDelegate.internalDisplayOrder != i {      // for not internal display
                if mouseLocation.x >= screens[i].frame.minX && mouseLocation.x <= screens[i].frame.maxX && mouseLocation.y >= screens[i].frame.minY && mouseLocation.y <= screens[i].frame.maxY {
                    button.image = NSImage.swatchWithColor(color: NSColor.enabledScreen, size: NSMakeSize(button.frame.size.width, button.frame.size.height))
                    
                    CustomView.selectedScreen = i
                }
                else {
                    button.image = NSImage.swatchWithColor(color: NSColor.disabledScreen, size: NSMakeSize(button.frame.size.width, button.frame.size.height))
                }
            }
            else {                                          // for internal display
                button.image = NSImage.swatchWithColor(color: NSColor.disabledScreen, size: NSMakeSize(button.frame.size.width, button.frame.size.height))
                button.isEnabled = false
            }

            addSubview(button)
            button.target = self
            button.action = #selector(buttonClicked)
            buttons.append(button)
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
                    buttons[i].image = NSImage.swatchWithColor(color: NSColor.enabledScreen, size: NSMakeSize(buttons[i].frame.size.width, buttons[i].frame.size.height))
                    
                    CustomView.selectedScreen = i
                }
                else {
                    buttons[i].image = NSImage.swatchWithColor(color: NSColor.disabledScreen, size: NSMakeSize(buttons[i].frame.size.width, buttons[i].frame.size.height))
                }
            }
        }
    }
}
