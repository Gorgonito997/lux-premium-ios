import Foundation
import Combine

// 1. Equivalente a la "data class ClientPromotionGroup"
struct ClientPromotionGroup: Identifiable {
    let baseId: String
    let representativeDevelopment: Development
    let developments: [Development]

    // Identifiable en Swift necesita una variable 'id'
    var id: String { baseId }
}

// 2. Equivalente a "class ClientHomeViewModel: ViewModel()"
@MainActor
final class ClientHomeViewModel: ObservableObject {

    // En iOS usamos @Published en lugar de MutableStateFlow / AppResult.
    // SwiftUI prefiere tener el estado desglosado así para reaccionar más rápido:
    @Published var promotionGroups: [ClientPromotionGroup] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let repository: DevelopmentsRepository

    // init(private val repository: DevelopmentsRepository = DevelopmentsRepository())
    init(repository: DevelopmentsRepository = DevelopmentsRepository()) {
        self.repository = repository

        // NOTA: En Kotlin llamas a loadDevelopments() dentro del init{}.
        // En Swift, llamar a funciones 'async' desde el init es problemático.
        // Es mucho mejor práctica dejar que la Vista llame a la función
        // usando el modificador `.task { await viewModel.loadDevelopments() }`
        // tal y como te configuré en el script anterior de la vista.
    }

    // fun loadDevelopments() { viewModelScope.launch { ... } }
    func loadDevelopments() async {
        isLoading = true
        errorMessage = nil

        do {
            // val developments = repository.getVisibleDevelopments()
            let developments = try await repository.getVisibleDevelopments()

            // --- TRADUCCIÓN DE LA LÓGICA DE AGRUPACIÓN DE KOTLIN A SWIFT ---

            // 1. .groupBy { BrokerMapper.extractBaseId(it.id) }
            let groupedDictionary = Dictionary(grouping: developments) { development in
                BrokerMapper.extractBaseId(from: development.id)
            }

            // 2. .map { (baseId, group) -> ... }
            let groupedDevelopments = groupedDictionary.compactMap { (baseId, group) -> ClientPromotionGroup? in
                // val sortedGroup = group.sortedBy { it.id }
                let sortedGroup = group.sorted { $0.id < $1.id }

                // representativeDevelopment = sortedGroup.first()
                guard let firstDevelopment = sortedGroup.first else { return nil }

                return ClientPromotionGroup(
                    baseId: baseId,
                    representativeDevelopment: firstDevelopment,
                    developments: sortedGroup
                )
            }

            // 3. .sortedBy { it.representativeDevelopment.name.ifBlank { it.baseId } }
            let finalSortedGroups = groupedDevelopments.sorted { group1, group2 in
                let name1 = group1.representativeDevelopment.name.isEmpty ? group1.baseId : group1.representativeDevelopment.name
                let name2 = group2.representativeDevelopment.name.isEmpty ? group2.baseId : group2.representativeDevelopment.name

                return name1 < name2
            }

            // _uiState.value = AppResult.Success(groupedDevelopments)
            self.promotionGroups = finalSortedGroups

        } catch {
            // _uiState.value = AppResult.Error(e)
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
