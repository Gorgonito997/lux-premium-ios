import Foundation

enum DevelopmentGroupingMapper {
    static func map(_ developments: [Development]) -> [ClientPromotionGroup] {
        let grouped = Dictionary(grouping: developments) { development in
            baseId(for: development)
        }

        return grouped.map { baseId, developments in
            let sortedDevelopments = developments.sorted { $0.name < $1.name }
            let firstDevelopment = sortedDevelopments.first

            return ClientPromotionGroup(
                baseId: baseId,
                displayName: displayName(for: firstDevelopment, baseId: baseId),
                location: firstDevelopment?.location ?? "",
                developments: sortedDevelopments
            )
        }
        .sorted { $0.displayName < $1.displayName }
    }

    private static func baseId(for development: Development) -> String {
        let baseId = development.baseId.trimmingCharacters(in: .whitespacesAndNewlines)

        if !baseId.isEmpty {
            return baseId
        }

        return inferredBaseId(from: development.id)
    }

    private static func inferredBaseId(from id: String) -> String {
        if let separatorIndex = id.lastIndex(of: "_") {
            return String(id[..<separatorIndex])
        }

        if let separatorIndex = id.lastIndex(of: "-") {
            return String(id[..<separatorIndex])
        }

        return id
    }

    private static func displayName(for development: Development?, baseId: String) -> String {
        guard let name = development?.name.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            return baseId
        }

        let displayName = nameWithoutLotSuffix(name)
        return displayName.isEmpty ? name : displayName
    }

    private static func nameWithoutLotSuffix(_ name: String) -> String {
        let patterns = [
            "\\s*[-/]\\s*(lote|lot)\\s*[A-Za-z0-9]+\\s*$",
            "\\s*\\((lote|lot)\\s*[A-Za-z0-9]+\\)\\s*$"
        ]

        return patterns.reduce(name) { currentName, pattern in
            currentName.replacingOccurrences(
                of: pattern,
                with: "",
                options: [.regularExpression, .caseInsensitive]
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
