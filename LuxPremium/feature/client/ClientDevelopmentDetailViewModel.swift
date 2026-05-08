import Foundation

@MainActor
final class ClientDevelopmentDetailViewModel: ObservableObject {

    // Estados expuestos a la vista
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
        authRepository: AuthRepository = AuthRepository()
    ) {
        self.devId = devId
        self.repository = repository
        self.authRepository = authRepository
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil

        // 1. Cargar la promoción (Development)
        do {
            //  AQUÍ ESTÁ EL CAMBIO: getDevelopment(id:)
            let fetchedDevelopment = try await repository.getDevelopment(id: devId)
            self.development = fetchedDevelopment
        } catch {
            self.errorMessage = error.localizedDescription
            self.development = nil
        }

        // 2. Cargar el usuario (AppUser)
        do {
            self.user = try await authRepository.getCurrentUserProfile()
        } catch {
            self.user = nil
            print("Error cargando perfil de usuario: \(error.localizedDescription)")
        }

        isLoading = false
    }
}