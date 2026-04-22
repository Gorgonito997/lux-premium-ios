import Foundation
import Combine

@MainActor
final class DevelopmentDetailViewModel: ObservableObject {
    @Published var development: Development?
    @Published var units: [PropertyUnit] = []
    @Published var documents: [DevelopmentDocument] = []
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
        } catch {
            development = nil
            units = []
            documents = []
            errorMessage = error.localizedDescription
            isLoading = false
            return
        }

        async let unitsResult = loadUnits(developmentId: developmentId)
        async let documentsResult = loadDocuments(developmentId: developmentId)

        let loadedUnits = await unitsResult
        let loadedDocuments = await documentsResult

        units = loadedUnits.value
        documents = loadedDocuments.value

        let partialErrors = [loadedUnits.errorMessage, loadedDocuments.errorMessage]
            .compactMap { $0 }

        errorMessage = partialErrors.isEmpty ? nil : partialErrors.joined(separator: "\n")
        isLoading = false
    }

    private func loadUnits(developmentId: String) async -> ResourceLoadResult<[PropertyUnit]> {
        do {
            return ResourceLoadResult(value: try await developmentsRepository.getUnits(developmentId: developmentId))
        } catch {
            return ResourceLoadResult(
                value: [],
                errorMessage: "No se pudieron cargar las unidades: \(error.localizedDescription)"
            )
        }
    }

    private func loadDocuments(developmentId: String) async -> ResourceLoadResult<[DevelopmentDocument]> {
        do {
            return ResourceLoadResult(value: try await developmentsRepository.getClientDocuments(developmentId: developmentId))
        } catch {
            return ResourceLoadResult(
                value: [],
                errorMessage: "No se pudieron cargar los documentos: \(error.localizedDescription)"
            )
        }
    }
}

private struct ResourceLoadResult<Value> {
    let value: Value
    let errorMessage: String?

    init(value: Value, errorMessage: String? = nil) {
        self.value = value
        self.errorMessage = errorMessage
    }
}
