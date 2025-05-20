import SwiftUI

struct CryptoDetailView: View {
    var asset: (name: String, amount: Double, price: Double, purchasePrice: Double)

    var body: some View {
        VStack(spacing: 20) {
            Text(asset.name)
                .font(.largeTitle)
                .bold()

            Text("Кількість: \(asset.amount, specifier: "%.4f")")
            Text("Ціна зараз: $\(asset.price, specifier: "%.2f")")
            Text("Ціна купівлі: $\(asset.purchasePrice, specifier: "%.2f")")

            let delta = asset.price - asset.purchasePrice
            let percent = (delta / asset.purchasePrice) * 100

            Text("Зміна: \(String(format: "%+.2f%% ($%+.2f)", percent, delta * asset.amount))")
                .foregroundColor(delta >= 0 ? .green : .red)
                .bold()

            Spacer()
        }
        .padding()
    }
}
