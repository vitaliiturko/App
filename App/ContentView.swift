import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Головна")
                }
            
            MarketsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Курси")
                }
            
            PortfolioView()
                .tabItem {
                    Image(systemName: "briefcase.fill")
                    Text("Портфель")
                }
            
            NewsView() // 🆕 Додано екран новин
                .tabItem {
                    Image(systemName: "newspaper.fill")
                    Text("Новини")
                }
            
            MapView() // 🆕 Додано екран новин
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Карта")
                }
        }
    }
}

// Тимчасові заглушки для екранів



struct SettingsView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage = "Українська"
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    let languages = ["Українська", "English"]
    
    var body: some View {
        NavigationView {
            Form {
                // Вибір мови
                Section(header: Text("Мова")) {
                    Picker("Оберіть мову", selection: $selectedLanguage) {
                        ForEach(languages, id: \.self) { language in
                            Text(language).tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Вибір теми
                Section(header: Text("Тема")) {
                    Toggle("Темний режим", isOn: $isDarkMode)
                        .onChange(of: isDarkMode) { newValue in
                            UIApplication.shared.windows.first?.overrideUserInterfaceStyle = newValue ? .dark : .light
                        }
                }
            }
            .navigationTitle("Налаштування")
        }
    }
}

// Попередній перегляд
#Preview {
    ContentView()
}

