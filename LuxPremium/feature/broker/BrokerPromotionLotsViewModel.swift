import Foundation

@MainActor
final class BrokerPromotionLotsViewModel: ObservableObject {
    @Published var developments: [Development] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let developmentsRepository: DevelopmentsRepository

    init(developmentsRepository: DevelopmentsRepository = DevelopmentsRepository()) {
        self.developmentsRepository = developmentsRepository
    }

    func loadLots(baseId: String) async {
        isLoading = true
        errorMessage = nil

        let normalizedBaseId = baseId.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            let visibleDevelopments = try await developmentsRepository.getVisibleDevelopments()
            developments = visibleDevelopments.filter { development in
                DevelopmentGroupingMapper.resolvedBaseId(for: development) == normalizedBaseId
            }
        } catch {
            developments = []
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
