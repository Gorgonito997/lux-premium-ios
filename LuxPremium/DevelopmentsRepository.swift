import Foundation
import FirebaseFirestore

final class DevelopmentsRepository {
    private let db = Firestore.firestore()

    func getVisibleDevelopments() async throws -> [Development] {
        let snapshot = try await db.collection("developments")
            .whereField("isVisible", isEqualTo: true)
            .getDocuments()

        return snapshot.documents.map { document in
            Self.development(from: document)
        }
    }

    func getDevelopment(id: String) async throws -> Development {
        let document = try await db.collection("developments").document(id).getDocument()
        return Self.development(from: document)
    }

    func getUnits(developmentId: String) async throws -> [PropertyUnit] {
        let snapshot = try await db.collection("developments")
            .document(developmentId)
            .collection("units")
            .getDocuments()

        return snapshot.documents.map { document in
            let data = document.data()

            return PropertyUnit(
                id: document.documentID,
                typology: data["typology"] as? String ?? "",
                price: Self.intValue(from: data["price"]),
                sqm: Self.doubleValue(from: data["sqm"]),
                bedrooms: Self.intValue(from: data["bedrooms"]),
                availability: data["availability"] as? String ?? "",
                energyCertificate: data["energyCertificate"] as? String ?? ""
            )
        }
    }

    func getClientDocuments(developmentId: String) async throws -> [DevelopmentDocument] {
        let snapshot = try await db.collection("developments")
            .document(developmentId)
            .collection("documents")
            .whereField("isVisible", isEqualTo: true)
            .getDocuments()

        return snapshot.documents
            .map { document in
                let data = document.data()

                return DevelopmentDocument(
                    id: document.documentID,
                    name: data["name"] as? String ?? "",
                    category: data["category"] as? String ?? "",
                    fileType: data["fileType"] as? String ?? "",
                    downloadUrl: data["downloadUrl"] as? String ?? "",
                    isVisible: data["isVisible"] as? Bool ?? false,
                    sortOrder: Self.intValue(from: data["sortOrder"])
                )
            }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private static func development(from document: DocumentSnapshot) -> Development {
        let data = document.data() ?? [:]

        return Development(
            id: document.documentID,
            baseId: data["baseId"] as? String ?? "",
            name: data["name"] as? String ?? "",
            location: data["location"] as? String ?? "",
            status: data["status"] as? String ?? "",
            coverImageUrl: data["coverImageUrl"] as? String ?? "",
            isVisible: data["isVisible"] as? Bool ?? false,
            soldCount: Self.intValue(from: data["soldCount"]),
            driveImagesFolderUrl: data["driveImagesFolderUrl"] as? String ?? "",
            driveWorkImagesFolderUrl: data["driveWorkImagesFolderUrl"] as? String ?? ""
        )
    }

    private static func intValue(from value: Any?) -> Int {
        if let intValue = value as? Int {
            return intValue
        }

        if let numberValue = value as? NSNumber {
            return numberValue.intValue
        }

        return 0
    }

    private static func doubleValue(from value: Any?) -> Double {
        if let doubleValue = value as? Double {
            return doubleValue
        }

        if let numberValue = value as? NSNumber {
            return numberValue.doubleValue
        }

        return 0
    }
}
