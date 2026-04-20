import Foundation

struct DevelopmentDocument: Identifiable, Codable {
    var id: String = ""
    var name: String = ""
    var category: String = ""
    var fileType: String = ""
    var downloadUrl: String = ""
    var isVisible: Bool = false
    var sortOrder: Int = 0
}
