import Foundation

@MainActor
final class BrokerHomeViewModel: ObservableObject {
    @Published var promotionGroups: [ClientPromotionGroup] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let developmentsRepository: DevelopmentsRepository

    init(developmentsRepository: DevelopmentsRepository = DevelopmentsRepository()) {
        self.developmentsRepository = developmentsRepository
    }

    func loadPromotions() async {
        isLoading = true
        errorMessage = nil

        do {
            let developments = try await developmentsRepository.getVisibleDevelopments()
            promotionGroups = DevelopmentGroupingMapper.map(developments)
        } catch {
            promotionGroups = []
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
