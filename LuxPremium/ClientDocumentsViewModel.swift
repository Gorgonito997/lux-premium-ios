import Foundation
import Combine

@MainActor
final class ClientDocumentsViewModel: ObservableObject {
    @Published var documents: [DevelopmentDocument] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let developmentsRepository: DevelopmentsRepository

    init(developmentsRepository: DevelopmentsRepository = DevelopmentsRepository()) {
        self.developmentsRepository = developmentsRepository
    }

    func loadDocuments(developmentId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            documents = try await developmentsRepository.getClientDocuments(developmentId: developmentId)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
