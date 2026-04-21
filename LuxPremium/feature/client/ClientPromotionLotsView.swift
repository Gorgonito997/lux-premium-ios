import Foundation
import SwiftUI

struct ClientPromotionLotsView: View {
    let group: ClientPromotionGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(group.displayName)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if !group.location.isEmpty {
                    Text(group.location)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Lotes")
                .font(.title2)
                .fontWeight(.semibold)

            List(group.developments) { development in
                NavigationLink {
                    DevelopmentDetailView(developmentId: development.id)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(displayLotName(for: development))
                            .font(.headline)

                        Text(development.name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(development.location)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(development.status)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 6)
                }
            }
            .listStyle(.plain)
        }
        .padding()
        .navigationTitle("Lotes")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func displayLotName(for development: Development) -> String {
        let trimmedName = development.name.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.lowercased().contains("lote") {
            return trimmedName
        }

        let lower = development.id.lowercased()
        if let range = lower.range(of: "_lote") {
            let suffix = development.id[range.upperBound...]
            return "Lote \(suffix)"
        }

        return trimmedName.isEmpty ? development.id : trimmedName
    }
}

#Preview {
    NavigationStack {
        ClientPromotionLotsView(
            group: ClientPromotionGroup(
                baseId: "preview",
                displayName: "Promocion preview",
                location: "Madrid",
                developments: [
                    Development(id: "preview-lot", baseId: "preview", name: "Lote A", location: "Madrid", status: "Disponible")
                ]
            )
        )
    }
}
