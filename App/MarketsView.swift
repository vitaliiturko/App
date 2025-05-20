import SwiftUI

struct MarketsView: View {
    @StateObject private var viewModel = CryptoViewModel()
    @State private var searchText: String = ""
    @State private var isSortedAscending: Bool = true

    var filteredCryptos: [Crypto] {
        if searchText.isEmpty {
            return viewModel.cryptos
        } else {
            return viewModel.cryptos.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.symbol.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var sortedCryptos: [Crypto] {
        filteredCryptos.sorted {
            isSortedAscending ? $0.current_price < $1.current_price : $0.current_price > $1.current_price
        }
    }

    var body: some View {
        NavigationView {
            List(sortedCryptos) { crypto in
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
                        Text("\(crypto.price_change_percentage_24h, specifier: "%.2f")%")
                            .foregroundColor(crypto.price_change_percentage_24h >= 0 ? .green : .red)
                            .bold()
                    }
                }
                .padding(.vertical, 5)
                .background(crypto.price_change_percentage_24h >= 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                .cornerRadius(8)
                .shadow(radius: 5)
            }
            .searchable(text: $searchText)
            .navigationTitle("Курси криптовалют")
            .navigationBarItems(trailing: Button(action: {
                isSortedAscending.toggle()
            }) {
                Image(systemName: isSortedAscending ? "arrow.up" : "arrow.down")
            })
            .onAppear {
                viewModel.fetchCryptoData()
            }
        }
    }
}
