import Foundation

// MARK: - Extensiones para la lógica de filtrado

extension String {
    /// Equivalente al `normalizeClientDocumentValue()` de Kotlin.
    /// Elimina acentos/diacríticos, espacios en blanco y lo convierte a minúsculas.
    func normalizeClientDocumentValue() -> String {
        return self
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }
}

extension DevelopmentDocument {
    /// Equivalente a `isAllowedClientDocument()` de Kotlin.
    func isAllowedClientDocument() -> Bool {
        let allowedKeywords: Set<String> = [
            "brochura",
            "flyer",
            "acabamentos",
            "planta",
            "plantas"
        ]

        let normalizedName = self.name.normalizeClientDocumentValue()

        // Verifica si el nombre normalizado contiene alguna de las palabras clave
        return allowedKeywords.contains { keyword in
            normalizedName.contains(keyword)
        }
    }
}

// MARK: - ViewModel

@MainActor
final class ClientDocumentsViewModel: ObservableObject {

    // Estados adaptados para SwiftUI (sustituyendo el AppResult de Kotlin)
    @Published var documents: [DevelopmentDocument] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let devId: String
    private let repository: DevelopmentsRepository

    init(devId: String, repository: DevelopmentsRepository = DevelopmentsRepository()) {
        self.devId = devId
        self.repository = repository

        // Nota: En la vista de Swift ya pusimos un `.task { await viewModel.loadDocuments() }`,
        // por lo que no hace falta llamarlo directamente en el init como en Kotlin,
        // así evitamos que se ejecute dos veces.
    }

    func loadDocuments() async {
        isLoading = true
        errorMessage = nil

        do {
            // Obtenemos todos los documentos del repositorio
            let allDocuments = try await repository.getDevelopmentDocuments(devId: devId)

            // Filtramos usando la extensión que creamos arriba
            self.documents = allDocuments.filter { $0.isAllowedClientDocument() }

        } catch {
            self.errorMessage = error.localizedDescription
            self.documents = []
        }

        isLoading = false
    }
}
