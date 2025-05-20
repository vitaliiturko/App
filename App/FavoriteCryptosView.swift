import SwiftUI

struct FavoriteCryptosView: View {
    var favorites: [Crypto]

    var body: some View {
        List(favorites) { crypto in
            HStack {
                VStack(alignment: .leading) {
                    Text(crypto.name)
                        .font(.headline)
                    Text(crypto.symbol.uppercased())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("$\(crypto.current_price, specifier: "%.2f")")
                        .font(.headline)
                }
            }
            .padding(.vertical, 5)
        }
        .navigationTitle("Улюблені криптовалюти")
    }
}
