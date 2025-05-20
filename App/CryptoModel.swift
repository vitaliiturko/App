import Foundation

struct Crypto: Identifiable, Decodable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let current_price: Double
    let price_change_percentage_24h: Double
    

    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case image
        case current_price
        case price_change_percentage_24h
    }
}
