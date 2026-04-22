import SwiftUI

struct BrokerHomeScreen: View {
    var onLogout: () -> Void
    var onNavigateToLots: () -> Void = {}
    var onNavigateToOpportunities: () -> Void = {}

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color(white: 0.08), Color(white: 0.14)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Broker Home")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("Acceso broker preparado. Aqui conectaremos lotes, oportunidades y siguientes pasos en los proximos bloques.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        VStack(spacing: 16) {
                            placeholderCard(
                                title: "Lotes",
                                subtitle: "Entrada preparada para navegacion futura.",
                                systemImage: "square.grid.2x2.fill",
                                action: onNavigateToLots
                            )

                            placeholderCard(
                                title: "Oportunidades",
                                subtitle: "Placeholder temporal sin logica de negocio.",
                                systemImage: "chart.line.uptrend.xyaxis",
                                action: onNavigateToOpportunities
                            )
                        }

                        Text("Este modulo esta en fase inicial. El acceso por rol ya queda resuelto de forma segura desde el router raiz.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding(20)
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("BROKER")
                        .font(.system(size: 13, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onLogout) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    private func placeholderCard(
        title: String,
        subtitle: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: systemImage)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BrokerHomeScreen(onLogout: {})
}
