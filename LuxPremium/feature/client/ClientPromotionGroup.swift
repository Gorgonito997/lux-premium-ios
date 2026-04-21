import Foundation

struct ClientPromotionGroup: Identifiable {
    var id: String { baseId }
    let baseId: String
    let displayName: String
    let location: String
    let developments: [Development]
}
