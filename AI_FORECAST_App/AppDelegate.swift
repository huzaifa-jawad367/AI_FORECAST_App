//
//  AppDelegate.swift
//  AI_FORECAST_App
//
//  Created by Huzaifa Jawad on 9/16/24.
//

 import UIKit
 import SwiftUI

 @main
 class AppDelegate: UIResponder, UIApplicationDelegate {

     var window: UIWindow?
     let sessionManager = SessionManager()
 //    @EnvironmentObject var sessionManager: SessionManager
 //    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
 //
 //        // Create the SwiftUI view that provides the window contents.
 //        let contentView = ContentView()
 //
 //        // Use a UIHostingController as window root view controller.
 //        let window = UIWindow(frame: UIScreen.main.bounds)
 //        window.rootViewController = UIHostingController(rootView: contentView)
 //        self.window = window
 //        window.makeKeyAndVisible()
 //        return true
 //    }
     func application(
         _ app: UIApplication,
         open url: URL,
         options: [UIApplication.OpenURLOptionsKey: Any] = [:]
     ) -> Bool {
         // Only handle your reset-password links
         guard url.scheme == "myapp", url.host == "reset-password" else {
             return false
         }

         // Restore the Supabase session from the URL
         Task {
             do {
                 print("Step 0: Attempting to restore session...")
                 print("URL: \(url)")
                 _ = try await sessionManager.supabaseClient.auth.session(from: url)
                 print("Step 1: Session restored successfully!")
                 // Now drive your SwiftUI state onto the main thread:
                 await MainActor.run {
                     print("Step 2: Updating UI state...")
                     sessionManager.authState = .resetPasswordFlow
                     print("Step 3: UI state updated successfully!")
                 }
             } catch {
                 print("❌ Failed to restore session:", error)
             }
         }

         return true
     }

     func application(
         _ application: UIApplication,
         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
     ) -> Bool {
         let contentView = ContentView()
             .environmentObject(sessionManager)  // inject it here

         let window = UIWindow(frame: UIScreen.main.bounds)
         window.rootViewController = UIHostingController(rootView: contentView)
         self.window = window
         window.makeKeyAndVisible()
         return true
     }

     func applicationWillResignActive(_ application: UIApplication) {
         // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
         // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
     }

     func applicationDidEnterBackground(_ application: UIApplication) {
         // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     }

     func applicationWillEnterForeground(_ application: UIApplication) {
         // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
     }

     func applicationDidBecomeActive(_ application: UIApplication) {
         // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     }

 }

//@main
//struct AI_FORECAST_App: App {
//    @StateObject private var sessionManager = SessionManager()
//    
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environmentObject(sessionManager)
//                .onOpenURL { url in
//                    print("🔑 onOpenURL: \(url)")
//                    guard url.host == "reset-password" else { return }
//                    sessionManager.authState = .resetPasswordFlow
//          
//                    Task {
//                        do {
//                            // this is async and will throw on error
//                            print("🔑 Attempting to restore session from URL: \(url)")
//                            _ = try await sessionManager
//                                    .supabaseClient
//                                    .auth
//                                    .session(from: url)
//          
//                            print("✅ Session restored")
//                            sessionManager.authState = .resetPasswordFlow
//          
//                        } catch {
//                            print("❌ Failed to restore session:", error.localizedDescription)
//                        }
//                    }
//                }
//        }
//    }
//}

