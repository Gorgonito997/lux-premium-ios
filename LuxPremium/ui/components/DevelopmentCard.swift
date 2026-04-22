import SwiftUI

struct DevelopmentCard: View {
    var title: String
    var location: String
    var price: String
    var status: String
    var id: String = ""
    var badgeCount: Int = 0
    var onClick: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onClick) {
                VStack(spacing: 0) {

                    // HUECO PARA LA FOTO (Por ahora, un gris oscuro)
                    Rectangle()
                        .fill(Color(white: 0.2))
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipped()

                    VStack(alignment: .leading, spacing: 0) {
                        Text(title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white) // Texto blanco

                        Spacer().frame(height: 6)

                        Text(location)
                            .font(.subheadline)
                            .foregroundColor(.gray) // Texto gris

                        Spacer().frame(height: 20)

                        HStack {
                            Text(price) // El texto que dice "build"
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white) // En Android es blanco

                            Spacer()
                        }
                    }
                    .padding(24)
                }
                .background(Color(white: 0.12)) // Fondo gris oscuro de la carta
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxWidth: .infinity)
    }
}