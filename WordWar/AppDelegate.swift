//
//  AppDelegate.swift
//  WordWar
//
//  Created by Valentin Radu on 05/07/16.
//  Copyright © 2016 Valentin Radu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let rootViewController = GameViewController(nibName: nil, bundle: nil)
        
        
        guard
            let url = NSBundle.mainBundle().URLForResource("words", withExtension: "json"),
            let data = NSData(contentsOfURL:url),
            let arr = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [[String:String]]
            else {assertionFailure(); return false}
        
        let items:[(String, String)] = arr.flatMap {
            item in
            guard let langA = item["text_eng"] else {assertionFailure();return nil}
            guard let langB = item["text_spa"] else {assertionFailure();return nil}
            return (langA, langB)
        }
        
        rootViewController.dictionary = Dictionary(items)
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.rootViewController = rootViewController
        self.window?.backgroundColor = UIColor.whiteColor()
        self.window?.makeKeyAndVisible()
        return self.window != nil
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

