import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class BrokerDocumentsViewModel: ObservableObject {
    @Published var documents: [DevelopmentDocument] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let devId: String
    private let developmentsRepository: DevelopmentsRepository

    init(
        devId: String,
        developmentsRepository: DevelopmentsRepository = DevelopmentsRepository()
    ) {
        self.devId = devId
        self.developmentsRepository = developmentsRepository
    }

    func loadDocuments() async {
        isLoading = true
        errorMessage = nil

        do {
            documents = try await developmentsRepository.getClientDocuments(developmentId: devId)
        } catch {
            documents = []
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

@MainActor
final class ProposalViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var isSuccess: Bool = false
    @Published var errorMessage: String?

    private let devId: String
    private let unitId: String
    private let originalPrice: Double
    private let typology: String
    private let db = Firestore.firestore()

    init(
        devId: String,
        unitId: String,
        originalPrice: Double,
        typology: String
    ) {
        self.devId = devId
        self.unitId = unitId
        self.originalPrice = originalPrice
        self.typology = typology
    }

    func sendProposal(price: Double, conditions: String) {
        guard !isLoading else { return }
        guard price > 0 else {
            errorMessage = "Introduce un precio propuesto valido."
            return
        }

        isLoading = true
        isSuccess = false
        errorMessage = nil

        let payload: [String: Any] = [
            "developmentId": devId,
            "unitId": unitId,
            "typology": typology,
            "originalPrice": originalPrice,
            "proposedPrice": price,
            "paymentConditions": conditions.trimmingCharacters(in: .whitespacesAndNewlines),
            "brokerUid": Auth.auth().currentUser?.uid ?? "",
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ]

        db.collection("brokerProposals").addDocument(data: payload) { [weak self] error in
            Task { @MainActor in
                self?.isLoading = false

                if let error {
                    self?.errorMessage = error.localizedDescription
                } else {
                    self?.isSuccess = true
                }
            }
        }
    }
}
