# 💼 CryptoPortfolio — iOS App for Tracking Crypto Investments

📱 **CryptoPortfolio** is a SwiftUI-based iOS application designed to help users manage and monitor their cryptocurrency portfolio with ease. The app offers real-time insights, visual analytics, and secure local storage.

## 🔧 Technologies Used

- **SwiftUI** – Modern declarative UI framework for building iOS apps.
- **Realm** – Local database for storing portfolio data offline.
- **Google BigQuery** – Cloud-based analytics platform for fetching crypto-related data.
- **Swift Concurrency** – Uses `async/await` for clean asynchronous programming.
- **Charts** – Built-in chart rendering for data visualization.
- **MVVM Architecture** – Separates UI from business logic for scalability and maintainability.

## ✨ Features

- 📊 Track the balance and profitability (P/L) of your crypto portfolio.
- 📈 Pie charts displaying asset allocation.
- 🔎 Tap to view detailed info about each cryptocurrency.
- 💾 Add, update, and persist assets using Realm.
- ☁️ Retrieve analytics data from BigQuery.
- 📄 Export portfolio data to PDF.
- 🌍 Localized UI for international support.



## 🧠 Project Structure

├── Models/ # Realm data models
├── ViewModels/ # Logic and data transformation for the views
├── Views/ # SwiftUI user interfaces
├── Services/ # BigQuery integration
├── Resources/ # Localization, styles, icons



## 🔐 Security

- Service account credentials for BigQuery are **not hardcoded** in the app.
- Realm encrypts local user data for enhanced security.

## 🚀 Getting Started

1. Clone this repository:
   ```bash
   git clone https://github.com/vitaliiturko/App.git
