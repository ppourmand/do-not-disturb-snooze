//
//  AppDelegate.swift
//  CustomDnd
//
//  Created by Pasha Pourmand on 3/29/18.
//  Copyright © 2018 Pasha Pourmand. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    
    let dnd30Mins = NSMenuItem(title: "Snooze for 30 minutes", action: #selector(enableDnd30Minutes(_:)), keyEquivalent: "")
    let dnd1Hour = NSMenuItem(title: "Snooze for 1 hour", action: #selector(enableDnd1Hour(_:)), keyEquivalent: "")
    let dndDisable = NSMenuItem(title: "Disable DND", action: #selector(disableDnd(_:)), keyEquivalent: "")
    let quit = NSMenuItem(title: "Quit ", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    
    var timer = Timer()
    var currentTime = Date()
    var futureTime = Date()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("Image"))
        }
       constructMenu()
    }
    
    
    func constructMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.addItem(dnd30Mins)
        menu.addItem(dnd1Hour)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(dndDisable)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quit)
        statusItem.menu = menu
        
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options = [checkOptPrompt: true]
        //translate into boolean value
        AXIsProcessTrustedWithOptions(options as CFDictionary?)
    }
    
    @objc func disableDnd(_ : Any?) {
        let theDefaults = UserDefaults(suiteName: "com.apple.notificationcenterui")
        if (theDefaults?.bool(forKey: "doNotDisturb"))! {
            print("DND is enabled, disabling now")
            let url = Bundle.main.url(forResource: "dnd-enable", withExtension:"scpt")
            let path:String = url!.path
            
            let proc = Process()
            proc.launchPath = "/usr/bin/osascript"
            proc.arguments = [path]
            proc.launch()
            
            setMenuItemsState(state: true)
            timer.invalidate()
        }
    }
    
    @objc func enableDnd30Minutes(_ : Any?) {
        currentTime = getCurrentDate()
        let minutesToAdd = 30
        
        var dateComponent = DateComponents()
        dateComponent.minute = minutesToAdd
        
        futureTime = Calendar.current.date(byAdding: dateComponent, to:currentTime)!
        
        optionClickNotificationCenter()
        setMenuItemsState(state: false)

        // this loop keeps checking until time is up
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(checkIfOver), userInfo: nil, repeats: true)
    }
    
    @objc func enableDnd1Hour(_ : Any?) {
        currentTime = getCurrentDate()
        let minutesToAdd = 60
        
        var dateComponent = DateComponents()
        dateComponent.minute = minutesToAdd
        
        futureTime = Calendar.current.date(byAdding: dateComponent, to:currentTime)!
        
        optionClickNotificationCenter()
        setMenuItemsState(state: false)
        
        // this loop keeps checking until time is up
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(checkIfOver), userInfo: nil, repeats: true)
    }
    
    // compares current time to time needed to disable dnd
    // kills the timer when that condition hits
    // also disables dnd
    @objc func checkIfOver() {
        currentTime = getCurrentDate()
        if currentTime == futureTime {
            // when time is up, disable
            self.disableDnd("wtf")
            timer.invalidate()
        }
    }
    
    func optionClickNotificationCenter() {
        // answer from: https://apple.stackexchange.com/a/244130
        let url = Bundle.main.url(forResource: "dnd-enable", withExtension:"scpt")
        let path:String = url!.path
        
        let proc = Process()
        proc.launchPath = "/usr/bin/osascript"
        proc.arguments = [path]
        proc.launch()
    }
    
    func setMenuItemsState(state: Bool) {
        dnd30Mins.isEnabled = state
        dnd1Hour.isEnabled = state
    }
    
    func getCurrentDate()-> Date {
        var now = Date()
        var nowComponents = DateComponents()
        let calendar = Calendar.current
        nowComponents.year = Calendar.current.component(.year, from: now)
        nowComponents.month = Calendar.current.component(.month, from: now)
        nowComponents.day = Calendar.current.component(.day, from: now)
        nowComponents.hour = Calendar.current.component(.hour, from: now)
        nowComponents.minute = Calendar.current.component(.minute, from: now)
        nowComponents.second = Calendar.current.component(.second, from: now)
        nowComponents.timeZone = NSTimeZone.local
        now = calendar.date(from: nowComponents)!
        return now as Date
    }
}

