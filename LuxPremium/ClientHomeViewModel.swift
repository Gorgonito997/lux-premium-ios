import Foundation
import Combine

@MainActor
final class ClientHomeViewModel: ObservableObject {
    @Published var developments: [Development] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let developmentsRepository: DevelopmentsRepository

    init(developmentsRepository: DevelopmentsRepository = DevelopmentsRepository()) {
        self.developmentsRepository = developmentsRepository
    }

    func loadDevelopments() async {
        isLoading = true
        errorMessage = nil

        do {
            developments = try await developmentsRepository.getVisibleDevelopments()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
