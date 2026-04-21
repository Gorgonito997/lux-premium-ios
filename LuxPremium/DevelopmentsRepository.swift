import Foundation
import FirebaseFirestore

final class DevelopmentsRepository {
    private let db = Firestore.firestore()

    func getVisibleDevelopments() async throws -> [Development] {
        let snapshot = try await db
            .collection("developments")
            .whereField("isVisible", isEqualTo: true)
            .getDocuments()

        return snapshot.documents
            .map(mapDevelopment)
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func getDevelopment(id: String) async throws -> Development {
        let snapshot = try await db.collection("developments").document(id).getDocument()

        guard snapshot.exists else {
            throw RepositoryError.documentNotFound
        }

        return mapDevelopment(snapshot)
    }

    func getUnits(developmentId: String) async throws -> [PropertyUnit] {
        let snapshot = try await db
            .collection("developments")
            .document(developmentId)
            .collection("units")
            .getDocuments()

        return snapshot.documents
            .map(mapUnit)
            .sorted { $0.price < $1.price }
    }

    func getClientDocuments(developmentId: String) async throws -> [DevelopmentDocument] {
        let snapshot = try await db
            .collection("developments")
            .document(developmentId)
            .collection("documents")
            .whereField("isVisible", isEqualTo: true)
            .getDocuments()

        return snapshot.documents
            .map(mapDocument)
            .sorted { lhs, rhs in
                if lhs.sortOrder == rhs.sortOrder {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }

                return lhs.sortOrder < rhs.sortOrder
            }
    }

    private func mapDevelopment(_ document: DocumentSnapshot) -> Development {
        let data = document.data() ?? [:]

        return Development(
            id: document.documentID,
            baseId: stringValue(data["baseId"]),
            name: stringValue(data["name"]),
            location: stringValue(data["location"]),
            status: stringValue(data["status"]),
            coverImageUrl: stringValue(data["coverImageUrl"]),
            isVisible: boolValue(data["isVisible"]),
            soldCount: intValue(data["soldCount"]),
            driveImagesFolderUrl: stringValue(data["driveImagesFolderUrl"]),
            driveWorkImagesFolderUrl: stringValue(data["driveWorkImagesFolderUrl"])
        )
    }

    private func mapUnit(_ document: QueryDocumentSnapshot) -> PropertyUnit {
        let data = document.data()

        return PropertyUnit(
            id: document.documentID,
            typology: stringValue(data["typology"]),
            price: intValue(data["price"]),
            sqm: doubleValue(data["sqm"]),
            bedrooms: intValue(data["bedrooms"]),
            availability: stringValue(data["availability"]),
            energyCertificate: stringValue(data["energyCertificate"])
        )
    }

    private func mapDocument(_ document: QueryDocumentSnapshot) -> DevelopmentDocument {
        let data = document.data()

        return DevelopmentDocument(
            id: document.documentID,
            name: stringValue(data["name"]),
            category: stringValue(data["category"]),
            fileType: stringValue(data["fileType"]),
            downloadUrl: stringValue(data["downloadUrl"]),
            isVisible: boolValue(data["isVisible"]),
            sortOrder: intValue(data["sortOrder"])
        )
    }

    private func stringValue(_ rawValue: Any?) -> String {
        rawValue as? String ?? ""
    }

    private func boolValue(_ rawValue: Any?) -> Bool {
        rawValue as? Bool ?? false
    }

    private func intValue(_ rawValue: Any?) -> Int {
        if let intValue = rawValue as? Int {
            return intValue
        }

        if let number = rawValue as? NSNumber {
            return number.intValue
        }

        return 0
    }

    private func doubleValue(_ rawValue: Any?) -> Double {
        if let doubleValue = rawValue as? Double {
            return doubleValue
        }

        if let number = rawValue as? NSNumber {
            return number.doubleValue
        }

        return 0
    }
}

enum RepositoryError: LocalizedError {
    case documentNotFound

    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "No se ha encontrado el contenido solicitado."
        }
    }
}
