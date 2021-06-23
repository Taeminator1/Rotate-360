//
//  AppDelegate.swift
//  Rotate 360
//
//  Created by 윤태민 on 6/16/20.
//  Copyright © 2020 Taemin Yun. All rights reserved.
//

import Cocoa
import ServiceManagement
import HotKey

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    let helperBundleName = "com.Taeminator.Rotate-360-Launch"           // for Opeing at Login
    var foundHelper: Bool = true                                        // for Opeing at Login
    @IBOutlet weak var openAtLogin: NSMenuItem!
    
    static var internalDisplayOrder: Int!
    
    let hotKey: HotKey = HotKey(keyCombo: KeyCombo(key: .r, modifiers: [.command, .option]))
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            if let icon = NSImage(named: "menubar_icon") {
                icon.isTemplate = true
                button.image = icon
            }
            button.action = #selector(self.statusBarButtonClicked(sender:))
            button.sendAction(on: [NSEvent.EventTypeMask.leftMouseUp, NSEvent.EventTypeMask.rightMouseUp])
        }
        
        hotKey.keyDownHandler = {
            print(NSEvent.mouseLocation)
        }
        
        // Open at Login
        foundHelper = NSWorkspace.shared.runningApplications.contains { $0.bundleIdentifier == helperBundleName }
        openAtLogin.state = foundHelper ? .on : .off
    }

    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var customView: CustomView!
    
    var menuItem: NSMenuItem!
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == NSEvent.EventType.leftMouseUp {
            AppDelegate.internalDisplayOrder = Int(findInternalDisplay())
            customView.drawKey = false          // to excute draw function in CustomView Class
            
            menuItem = menu.item(withTitle: "CustomView")       // there is no space between Custom and View
            menuItem.view = customView!
            
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            
            statusItem.menu = nil
            
            CustomView.selectedScreen = -1
        }
    }
    
    @IBAction func rotateScreenClockwiseClicked(_ sender: Any) {
        if CustomView.selectedScreen != -1 {
            Screen.rotateByOrientaion(targetDisplayUnit: CustomView.selectedScreen, .CW)
        }
    }
    
    @IBAction func rotateScreenCounterclockwiseClicked(_ sender: Any) {
        if CustomView.selectedScreen != -1 {
            Screen.rotateByOrientaion(targetDisplayUnit: CustomView.selectedScreen, .CCW)
        }
    }
    
    @IBAction func openAtLoginClicked(_ sender: Any) {
        openAtLogin.state = openAtLogin.state == .on ? .off : .on
        SMLoginItemSetEnabled(helperBundleName as CFString, openAtLogin.state == .on)
    }
    
    @IBAction func quitClicked(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
}

