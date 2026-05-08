import Foundation

@MainActor
final class ClientDevelopmentDetailViewModel: ObservableObject {

    // Estados expuestos a la vista (sustituyen a ClientDetailUiState y AppResult)
    @Published var development: Development?
    @Published var user: AppUser?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let devId: String
    private let repository: DevelopmentsRepository
    private let authRepository: AuthRepository

    init(
        devId: String,
        repository: DevelopmentsRepository = DevelopmentsRepository(),
        authRepository: AuthRepository = AuthRepository() // Asume que Firebase ya se inyecta por defecto en su init
    ) {
        self.devId = devId
        self.repository = repository
        self.authRepository = authRepository

        // La llamada a loadData() la hacemos desde el .task {} en la vista de SwiftUI
        // para aprovechar el ciclo de vida nativo de iOS.
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil

        // 1. Cargar la promoción (Development)
        do {
            let fetchedDevelopment = try await repository.getDevelopmentById(devId)
            if let fetchedDevelopment = fetchedDevelopment {
                self.development = fetchedDevelopment
            } else {
                self.errorMessage = "Development not found"
            }
        } catch {
            self.errorMessage = error.localizedDescription
            self.development = nil
        }

        // 2. Cargar el usuario (AppUser)
        // Lo hacemos en un bloque do-catch separado al igual que en Kotlin,
        // para que si falla el usuario, no bloquee la carga de la promoción.
        do {
            self.user = try await authRepository.getCurrentUserProfile()
        } catch {
            self.user = nil
            // En Kotlin guardas el error del usuario, pero generalmente si la promo
            // cargó bien, no queremos mostrar pantalla de error total.
            // Dejamos el user a nil y la vista no mostrará el botón de "Mi carpeta".
            print("Error cargando perfil de usuario: \(error.localizedDescription)")
        }

        isLoading = false
    }
}