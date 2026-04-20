import Foundation
import Combine

@MainActor
final class DevelopmentDetailViewModel: ObservableObject {
    @Published var development: Development?
    @Published var units: [PropertyUnit] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let developmentsRepository: DevelopmentsRepository

    init(developmentsRepository: DevelopmentsRepository = DevelopmentsRepository()) {
        self.developmentsRepository = developmentsRepository
    }

    func load(developmentId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            development = try await developmentsRepository.getDevelopment(id: developmentId)
            units = try await developmentsRepository.getUnits(developmentId: developmentId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
