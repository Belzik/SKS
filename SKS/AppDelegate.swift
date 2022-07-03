//
//  AppDelegate.swift
//  SKS
//
//  Created by Александр Катрыч on 29/06/2019.
//  Copyright © 2019 Katrych. All rights reserved.
//

//
import UIKit
import CoreData
import IQKeyboardManagerSwift
import Firebase
import UserNotifications
import Messages
import YandexMapsMobile
import CoreLocation
import SwiftyVK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        YMKMapKit.setApiKey("a18da8b1-5ed2-4580-a55b-39f204ca2e19")
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        FirebaseApp.configure()
        TokensManager.shared.startTimer()
        Messaging.messaging().delegate = self
        
        registerForPushNotifications()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        sendFCMToken()

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let app = options[.sourceApplication] as? String
        VK.handle(url: url, sourceApplication: app)
        return true
    }

    func sendFCMToken() {
        if let user = UserData.loadSaved() {
            if let tokens = NotificationsTokens.loadSaved(),
                let notificationToken = tokens.notificationToken,
                let deviceToken = tokens.deviceToken {
                NetworkManager.shared.sendNotificationToken(notificationToken: notificationToken,
                                                            deviceToken: deviceToken,
                                                            accessToken: user.accessToken ?? "") { _ in }
            }
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                
                guard granted else { return }
                self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }

        print("TOKEN", fcmToken)
        
        if let tokens = NotificationsTokens.loadSaved(),
            let isDownload = tokens.isDownload {
            if !isDownload {
                tokens.notificationToken = fcmToken
                tokens.deviceToken = UIDevice.current.identifierForVendor!.uuidString
                tokens.save()
                
                NetworkManager.shared.sendNotificationToken(notificationToken: fcmToken,
                                                            deviceToken: UIDevice.current.identifierForVendor!.uuidString) { response in
                    if let statusCode = response.response?.statusCode,
                        statusCode == 200 {
                        tokens.isDownload = true
                        tokens.save()
                    }
                }
            }
        } else {
            let tokens = NotificationsTokens.init()
            tokens.notificationToken = fcmToken
            tokens.deviceToken = UIDevice.current.identifierForVendor!.uuidString
            tokens.save()
            
            NetworkManager.shared.sendNotificationToken(notificationToken: fcmToken,
                                                        deviceToken: UIDevice.current.identifierForVendor!.uuidString) { response in
                if let statusCode = response.response?.statusCode,
                    statusCode == 200 {
                    tokens.isDownload = true
                    tokens.save()
                }
            }
        }

    }

    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {

    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SKS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            LocationManager.shared.location = location
        }
    }
}
