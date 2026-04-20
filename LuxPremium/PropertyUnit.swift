import Foundation

struct PropertyUnit: Identifiable, Codable {
    var id: String = ""
    var typology: String = ""
    var price: Int = 0
    var sqm: Double = 0
    var bedrooms: Int = 0
    var availability: String = ""
    var energyCertificate: String = ""
}
