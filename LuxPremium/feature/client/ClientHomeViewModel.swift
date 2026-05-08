import Foundation

// MARK: - Modelo de Agrupación para el Cliente
struct ClientPromotionGroup: Identifiable {
    let baseId: String
    let representativeDevelopment: Development
    let developments: [Development]

    // Identificador único requerido por SwiftUI para los bucles ForEach
    var id: String { baseId }
}

// MARK: - ViewModel
@MainActor
final class ClientHomeViewModel: ObservableObject {

    // Variables de estado que lee la Vista
    @Published var promotions: [ClientPromotionGroup] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let repository: DevelopmentsRepository

    init(repository: DevelopmentsRepository = DevelopmentsRepository()) {
        self.repository = repository

        // La carga de datos la iniciamos desde la vista con .task { await viewModel.loadDevelopments() }
    }

    func loadDevelopments() async {
        isLoading = true
        errorMessage = nil

        do {
            // 1. Descargamos todos los desarrollos visibles
            let allDevelopments = try await repository.getVisibleDevelopments()

            // 2. Agrupamos usando el BrokerMapper
            // (Asumimos que tienes BrokerMapper.extractBaseId traducido a Swift)
            let grouped = Dictionary(grouping: allDevelopments) { development in
                BrokerMapper.extractBaseId(id: development.id)
            }

            // 3. Transformamos el diccionario en nuestro modelo ClientPromotionGroup
            var groupedDevelopments = grouped.map { (baseId, group) -> ClientPromotionGroup in
                // Ordenamos los desarrollos dentro del grupo por su ID
                let sortedGroup = group.sorted { $0.id < $1.id }

                return ClientPromotionGroup(
                    baseId: baseId,
                    representativeDevelopment: sortedGroup.first!, // 'first!' es seguro aquí porque el grupo nunca estará vacío
                    developments: sortedGroup
                )
            }

            // 4. Ordenamos la lista final por el nombre de la promoción representativa
            groupedDevelopments.sort { group1, group2 in
                let name1 = group1.representativeDevelopment.name.isEmpty ? group1.baseId : group1.representativeDevelopment.name
                let name2 = group2.representativeDevelopment.name.isEmpty ? group2.baseId : group2.representativeDevelopment.name

                return name1.localizedStandardCompare(name2) == .orderedAscending
            }

            // 5. Asignamos el resultado al estado publicado
            self.promotions = groupedDevelopments

        } catch {
            self.errorMessage = error.localizedDescription
            self.promotions = []
        }

        isLoading = false
    }
}
