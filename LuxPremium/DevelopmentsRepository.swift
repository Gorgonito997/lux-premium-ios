import Foundation
import FirebaseFirestore

final class DevelopmentsRepository {
    private let db = Firestore.firestore()

    func getVisibleDevelopments() async throws -> [Development] {
        let snapshot = try await db.collection("developments")
            .whereField("isVisible", isEqualTo: true)
            .getDocuments()

        return snapshot.documents.map { document in
            let data = document.data()

            return Development(
                id: document.documentID,
                name: data["name"] as? String ?? "",
                location: data["location"] as? String ?? "",
                status: data["status"] as? String ?? "",
                coverImageUrl: data["coverImageUrl"] as? String ?? "",
                isVisible: data["isVisible"] as? Bool ?? false,
                soldCount: Self.intValue(from: data["soldCount"])
            )
        }
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
}
