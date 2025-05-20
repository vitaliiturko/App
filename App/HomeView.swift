import SwiftUI
import Charts

// 🔹 Модель для криптовалют
struct CryptoAsset: Identifiable, Codable {
    let id: String
    let symbol: String
    let current_price: Double
}

// 📌 Головний екран
struct HomeView: View {
    @State private var cryptoData: [CryptoAsset] = []
    @State private var balanceHistory: [Double] = []
    @AppStorage("userBalance") private var portfolioValue: Double = 0.0
    @State private var marqueeText: String = "🚀 Bitcoin досяг $70,000! | Ethereum зростає на 5% | 📉 Dogecoin падає | 🔔 Слідкуйте за оновленнями | 📰 Більше новин — у додатку!"

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // 🟦 Бігуча стрічка
                    MarqueeView(text: marqueeText)

                    VStack(alignment: .leading, spacing: 20) {
                        // 💰 Баланс
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Загальний баланс")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text("$\(String(format: "%.2f", portfolioValue))")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            NavigationLink(destination: ProfileView()) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()

                        // 📈 Графік балансу
                        ChartView(balanceHistory: balanceHistory)

                        // 🔥 Популярні криптовалюти
                        Text("Популярні активи")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        if cryptoData.isEmpty {
                            Text("Завантаження...")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(cryptoData) { crypto in
                                CryptoCard(name: crypto.symbol.uppercased(), price: crypto.current_price)
                            }
                        }

                        // 🔵 Кнопки дій
                        HStack {
                            ActionButton(title: "Купити", color: .green)
                            ActionButton(title: "Продати", color: .red)
                            ActionButton(title: "Поповнити", color: .blue)
                        }
                        .padding()
                    }
                    .padding(.top, 20)
                }
            }
            .onAppear {
                fetchCryptoData()
                loadBalanceHistory()
            }
        }
    }

    func fetchCryptoData() {
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=bitcoin,ethereum,tether,binancecoin,solana"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let fetchedData = try JSONDecoder().decode([CryptoAsset].self, from: data)
                    DispatchQueue.main.async {
                        self.cryptoData = fetchedData
                    }
                } catch {
                    print("❌ Помилка парсингу JSON: \(error)")
                }
            }
        }.resume()
    }

    func loadBalanceHistory() {
        if let savedData = UserDefaults.standard.array(forKey: "balanceHistory") as? [Double] {
            balanceHistory = savedData
        }
    }
}

// 📊 Графік балансу
struct ChartView: View {
    var balanceHistory: [Double]

    var body: some View {
        VStack {
            Text("Зміна балансу (7 днів)")
                .font(.headline)
                .padding(.bottom, 5)
            Chart {
                ForEach(Array(balanceHistory.enumerated()), id: \.0) { index, value in
                    LineMark(
                        x: .value("День", index),
                        y: .value("Баланс", value)
                    )
                    .foregroundStyle(.blue)
                }
            }
            .frame(height: 150)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

// 📌 Карточка криптовалюти
struct CryptoCard: View {
    var name: String
    var price: Double

    var body: some View {
        HStack {
            Image(systemName: "bitcoinsign.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.orange)
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                Text("$\(String(format: "%.2f", price))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

// 🟢 Кнопки дій
struct ActionButton: View {
    var title: String
    var color: Color

    var body: some View {
        Button(action: {}) {
            Text(title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(15)
        }
    }
}

struct MarqueeView: View {
    var text: String
    @State private var offset: CGFloat = 0
    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var isAnimating = false

    let spacing: CGFloat = 60
    let speed: CGFloat = 30 // швидкість (більше = повільніше)
    let delayBetweenAnimations: TimeInterval = 3.0 // ⏱ затримка між проходами

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.blue
                    .frame(height: 30)
                    .cornerRadius(8)

                HStack(spacing: spacing) {
                    marqueeText
                }
                .offset(x: offset)
                .onAppear {
                    containerWidth = geo.size.width
                }
                .onChange(of: textWidth) { _ in
                    if !isAnimating && textWidth > 0 {
                        startAnimation()
                    }
                }
            }
        }
        .frame(height: 30)
        .padding(.horizontal)
    }

    var marqueeText: some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            textWidth = geo.size.width
                        }
                }
            )
    }

    func startAnimation() {
        isAnimating = true
        let totalDistance = textWidth + containerWidth + spacing
        let duration = Double(totalDistance) / Double(speed)

        offset = containerWidth
        withAnimation(.linear(duration: duration)) {
            offset = -textWidth - spacing
        }

        // 🕒 Після завершення — запуск з паузою
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + delayBetweenAnimations) {
            isAnimating = false
            startAnimation()
        }
    }
}

// 🖥 Попередній перегляд
#Preview {
    HomeView()
}
