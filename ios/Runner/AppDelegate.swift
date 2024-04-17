import UIKit
import Flutter
//Импорт яндекс карт
import YandexMapsMobile

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    //Подключения ключа апи с картами 
    YMKMapKit.setApiKey("b5c9680c-8453-49e4-9dc9-85a0e70c6df2")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

