import Foundation

@MainActor
final class ClientHomeViewModel: ObservableObject {

    @Published var promotions: [ClientPromotionGroup] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let repository: DevelopmentsRepository

    init(repository: DevelopmentsRepository = DevelopmentsRepository()) {
        self.repository = repository
    }

    func loadDevelopments() async {
        isLoading = true
        errorMessage = nil

        do {
            let allDevelopments = try await repository.getVisibleDevelopments()
            // Usamos tu mapper directamente
            self.promotions = DevelopmentGroupingMapper.map(allDevelopments)
        } catch {
            self.errorMessage = error.localizedDescription
            self.promotions = []
        }

        isLoading = false
    }
}
