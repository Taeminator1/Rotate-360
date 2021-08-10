//
//  AppDelegate.swift
//  Rotate 360
//
//  Created by 윤태민 on 6/16/20.
//  Copyright © 2020 Taemin Yun. All rights reserved.
//

//  Initialize for the Application:
//  - Status item for menu
//  - Hotkey
//  - Open at Login
//  - Buttons in menubar, including initialization of CustomView

import Cocoa
import ServiceManagement
import HotKey

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    // For Open at Login
    private let helperBundleName = "com.Taeminator.Rotate-360-Launch"
    private var foundHelper: Bool = true
    @IBOutlet weak var openAtLogin: NSMenuItem!
    
    private var rotatingHotKeys: [Orientaion: HotKey] = [:]
    
    static var internalDisplayOrder: Int!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        // MARK:- Create status item for menu
        if let button = statusItem.button {
            if let icon = NSImage(named: "menubar_icon") {
                icon.isTemplate = true
                button.image = icon
            }
            button.action = #selector(self.statusItemButtonClicked(sender:))
            button.sendAction(on: [NSEvent.EventTypeMask.leftMouseUp, NSEvent.EventTypeMask.rightMouseUp])
        }
        
        // MARK:- Create hotkey
        // Set keys for hotkeys
        rotatingHotKeys.updateValue(HotKey(keyCombo: KeyCombo(key: .x, modifiers: [.control, .option, .command])), forKey: .CW)
        rotatingHotKeys.updateValue(HotKey(keyCombo: KeyCombo(key: .z, modifiers: [.control, .option, .command])), forKey: .CCW)
        
        // Set handler of the each hotkey
        rotatingHotKeys.forEach { hotKey in
            hotKey.value.keyDownHandler = {
                AppDelegate.internalDisplayOrder = Int(findInternalDisplay())

                let mouseLocation: NSPoint = NSEvent.mouseLocation
                let screens: [NSScreen] = NSScreen.screens

                for i in 0 ..< screens.count {      // find display where the mouse in except internal display
                    if AppDelegate.internalDisplayOrder != i && mouseLocation.isInTheScreen(screens[i]) {
                        Screen.rotateByOrientaion(targetDisplayUnit: i, hotKey.key)
                    }
                }
            }
        }
        
        // MARK:- Set Open at Login
        foundHelper = NSWorkspace.shared.runningApplications.contains { $0.bundleIdentifier == helperBundleName }
        openAtLogin.state = foundHelper ? .on : .off
    }

    @IBOutlet weak var menu: NSMenu!
    @IBOutlet weak var customView: CustomView!
    
    private var menuItem: NSMenuItem!
    
    @objc func statusItemButtonClicked(sender: NSStatusBarButton) {
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

