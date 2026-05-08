import Foundation

// MARK: - Extensiones para la lógica de filtrado

extension String {
    /// Elimina acentos/diacríticos, espacios en blanco y lo convierte a minúsculas.
    func normalizeClientDocumentValue() -> String {
        return self
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }
}

extension DevelopmentDocument {
    /// Verifica si el documento está permitido para la vista de clientes
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

    @Published var documents: [DevelopmentDocument] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let devId: String
    private let repository: DevelopmentsRepository

    init(devId: String, repository: DevelopmentsRepository = DevelopmentsRepository()) {
        self.devId = devId
        self.repository = repository
    }

    func loadDocuments() async {
        isLoading = true
        errorMessage = nil

        do {
            //  AQUÍ ESTÁ EL CAMBIO: Llamamos a getClientDocuments y le pasamos developmentId
            let allDocuments = try await repository.getClientDocuments(developmentId: devId)

            // Filtramos usando la extensión que creamos arriba
            self.documents = allDocuments.filter { $0.isAllowedClientDocument() }

        } catch {
            self.errorMessage = error.localizedDescription
            self.documents = []
        }

        isLoading = false
    }
}
