import Foundation

struct Development: Identifiable, Codable {
    var id: String = ""
    var name: String = ""
    var location: String = ""
    var status: String = ""
    var coverImageUrl: String = ""
    var isVisible: Bool = false
    var soldCount: Int = 0
}
