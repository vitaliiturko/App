import SwiftUI

struct PortfolioView: View {
    @State private var assets: [(name: String, amount: Double, price: Double)] = []
    @State private var selectedAsset: String = "Bitcoin"
    @State private var amount: String = ""
    @State private var cryptoPrices: [String: Double] = [:]
    @State private var showDetailSheet = false
    @State private var currentAsset: (name: String, amount: Double, price: Double)?

    @AppStorage("userBalance") private var portfolioValue: Double = 0.0

    let availableAssets = [
        ("Bitcoin", "bitcoin", "Bitcoin"),
        ("Ethereum", "ethereum", "eth"),
        ("Cardano", "cardano", "cardano_logo"),
        ("Solana", "solana", "sol"),
        ("Dogecoin", "dogecoin", "dogecoin_logo")
    ]

    var totalValue: Double {
        assets.reduce(0) { $0 + $1.amount * $1.price }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                // 🔹 Загальна вартість портфеля
                VStack {
                    Text("Загальна вартість")
                        .font(.headline)
                        .foregroundColor(.gray)

                    Text("$\(String(format: "%.2f", totalValue))")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .shadow(radius: 4)
                .padding(.horizontal)

                // 📌 Форма для додавання активу
                HStack {
                    Picker("Актив", selection: $selectedAsset) {
                        ForEach(availableAssets.map { $0.0 }, id: \.self) { asset in
                            Text(asset)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 120)

                    TextField("Кількість", text: $amount)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 100)
                    
                    Button(action: addAsset) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title)
                            .padding()
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                    .shadow(radius: 4)
                }
                .padding(.horizontal)

                // 📋 Список активів
                List {
                    ForEach(assets, id: \.name) { asset in
                        CryptoAssetCard(name: asset.name, amount: asset.amount, price: asset.price, imageName: getLogoName(for: asset.name))
                            .onTapGesture {
                                self.currentAsset = asset
                                self.showDetailSheet.toggle()
                            }
                            .transition(.slide)
                    }
                    .onDelete(perform: removeAsset)
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Портфель")
                .toolbar {
                    EditButton()
                }
            }
            .onAppear {
                fetchCryptoPrices()
                loadPortfolio()
            }
            .padding(.top)
            .sheet(isPresented: $showDetailSheet) {
                if let currentAsset = currentAsset {
                    // Використання CryptoDetailView
                    CryptoDetailView(
                        asset: (
                            name: currentAsset.name,
                            amount: currentAsset.amount,
                            price: currentAsset.price,
                            purchasePrice: currentAsset.price // Якщо ціна покупки не зберігається окремо
                        )
                    )
                }
            }
        }
    }

    // 🔄 Отримання актуальних цін криптовалют
    private func fetchCryptoPrices() {
        let symbols = availableAssets.map { $0.1 }.joined(separator: ",")
        let urlString = "https://api.coingecko.com/api/v3/simple/price?ids=\(symbols)&vs_currencies=usd"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            
            do {
                let response = try JSONDecoder().decode([String: [String: Double]].self, from: data)
                DispatchQueue.main.async {
                    for asset in self.availableAssets {
                        if let price = response[asset.1]?["usd"] {
                            self.cryptoPrices[asset.0] = price
                        }
                    }
                }
            } catch {
                print("❌ Помилка завантаження цін: \(error.localizedDescription)")
            }
        }.resume()
    }

    // ➕ Додавання активу
    private func addAsset() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        if let assetInfo = availableAssets.first(where: { $0.0 == selectedAsset }),
           let price = cryptoPrices[assetInfo.0] {
            withAnimation {
                assets.append((name: assetInfo.0, amount: amountValue, price: price))
                savePortfolio()
            }
        }
        amount = "" // Очистити поле після додавання
        updatePortfolioValue()
    }

    // 🗑 Видалення активу
    private func removeAsset(at offsets: IndexSet) {
        withAnimation {
            assets.remove(atOffsets: offsets)
            savePortfolio()
            updatePortfolioValue()
        }
    }

    // 🔄 Оновлення загальної вартості портфеля
    private func updatePortfolioValue() {
        portfolioValue = totalValue
        saveBalanceHistory()
    }

    // 💾 Збереження активів у UserDefaults
    private func savePortfolio() {
        let encoded = assets.map { ["name": $0.name, "amount": $0.amount, "price": $0.price] }
        UserDefaults.standard.set(encoded, forKey: "portfolioAssets")
    }

    // 📤 Завантаження активів з UserDefaults
    private func loadPortfolio() {
        if let savedData = UserDefaults.standard.array(forKey: "portfolioAssets") as? [[String: Any]] {
            assets = savedData.compactMap { dict in
                guard let name = dict["name"] as? String,
                      let amount = dict["amount"] as? Double,
                      let price = dict["price"] as? Double else { return nil }
                return (name: name, amount: amount, price: price)
            }
        }
        updatePortfolioValue()
    }

    // 📊 Збереження історії балансу
    private func saveBalanceHistory() {
        var history = UserDefaults.standard.array(forKey: "balanceHistory") as? [Double] ?? []
        if history.count >= 7 {
            history.removeFirst()
        }
        history.append(portfolioValue)
        UserDefaults.standard.set(history, forKey: "balanceHistory")
    }

    // 🔍 Отримання правильного логотипу для активу
    private func getLogoName(for asset: String) -> String {
        return availableAssets.first(where: { $0.0 == asset })?.2 ?? "default_logo"
    }
}

// 📌 Картка активу з іконкою та градієнтом
struct CryptoAssetCard: View {
    var name: String
    var amount: Double
    var price: Double
    var imageName: String

    private var priceChange: Double {
        return (price - price) * amount
    }

    private var percentageChange: Double {
        return (price - price) / price * 100
    }

    private var changeColor: Color {
        return priceChange >= 0 ? .green : .red
    }

    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                .shadow(radius: 3)

            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)

                Text("\(amount, specifier: "%.4f") × $\(price, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()

            VStack(alignment: .trailing) {
                Text("$\(String(format: "%.2f", amount * price))")
                    .fontWeight(.bold)

                Text(String(format: "%.1f%% ($%.2f)", percentageChange, priceChange))
                    .foregroundColor(changeColor)
                    .font(.footnote)
            }
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.white, Color(.systemGray5)]), startPoint: .top, endPoint: .bottom)
        )
        .cornerRadius(15)
        .shadow(radius: 4)
        .padding(.vertical, 5)
    }
}



struct PortfolioView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioView()
    }
}

