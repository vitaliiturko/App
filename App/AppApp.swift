import SwiftUI

@main
struct AppApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn = false  // Збереження стану входу

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ContentView()  // Якщо користувач увійшов → Головний екран
            } else {
                LoginView()  // Якщо не увійшов → Екран входу
            }
        }
    }
}
