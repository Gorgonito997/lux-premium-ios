import Foundation
import SwiftUI

struct ClientPromotionLotsView: View {
    let group: ClientPromotionGroup

    var body: some View {
        LuxScreen {
            LuxPanel {
                LuxSectionTitle(
                    group.displayName,
                    eyebrow: "Promocion",
                    subtitle: group.location.isEmpty ? "Selecciona un lote para ver el detalle completo." : group.location
                )

                LuxImagePlaceholder(
                    title: "Galeria principal",
                    subtitle: "Este bloque queda listo para conectar la fotografia o render destacado de la promocion.",
                    height: 220
                )
            }

            LuxSectionTitle(
                "Lotes",
                eyebrow: "Disponibilidad",
                subtitle: "Cada tarjeta mantiene espacio preparado para futuras imagenes de unidad o fachada."
            )

            VStack(spacing: 16) {
                ForEach(group.developments) { development in
                    NavigationLink {
                        DevelopmentDetailView(developmentId: development.id)
                    } label: {
                        lotCard(for: development)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private func lotCard(for development: Development) -> some View {
        LuxPanel {
            LuxImagePlaceholder(
                title: displayLotName(for: development),
                subtitle: "Zona reservada para la imagen de portada del lote.",
                height: 160
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(displayLotName(for: development))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(LuxTheme.textPrimary)

                if !development.name.isEmpty {
                    Text(development.name)
                        .font(.subheadline)
                        .foregroundStyle(LuxTheme.textSecondary)
                }

                if !development.location.isEmpty {
                    Label(development.location, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundStyle(LuxTheme.textSecondary)
                }

                Text(development.status)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(LuxTheme.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                    )
            }
        }
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
