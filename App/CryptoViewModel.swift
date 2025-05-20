import Foundation
import Combine

class CryptoViewModel: ObservableObject {
    @Published var cryptos: [Crypto] = []
    private var cancellables = Set<AnyCancellable>()

    func fetchCryptoData() {
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1&sparkline=false"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Crypto].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching crypto data: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] cryptos in
                self?.cryptos = cryptos
            })
            .store(in: &cancellables)
    }
}
