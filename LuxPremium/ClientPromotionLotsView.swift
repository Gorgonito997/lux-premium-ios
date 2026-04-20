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
                    VStack(alignment: .leading, spacing: 6) {
                        Text(development.name)
                            .font(.headline)

                        Text(development.status)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if !development.location.isEmpty {
                            Text(development.location)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)
        }
        .padding()
        .navigationTitle("Lotes")
        .navigationBarTitleDisplayMode(.inline)
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
