import Foundation

// MARK: - Modelo de Agrupación para el Cliente
struct ClientPromotionGroup: Identifiable {
    let baseId: String
    let displayName: String
    let location: String
    let developments: [Development]

    // Identificador único requerido por SwiftUI para los bucles ForEach
    var id: String { baseId }
}
