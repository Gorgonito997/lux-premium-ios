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

                    // Llama al Mapper para saber qué foto de Assets debe cargar
                    Image(DevelopmentImageMapper.mapIdToDrawable(id))
                        .resizable()        // Permite que la imagen cambie de tamaño
                        .scaledToFill()     // Rellena todo el hueco sin deformarse
                        .frame(height: 220) // La altura exacta que tenías en Android
                        .frame(maxWidth: .infinity)
                        .clipped()          // Corta lo que sobre por los lados

                    // --- TEXTOS (Se mantienen oscuros y premium) ---
                    VStack(alignment: .leading, spacing: 0) {
                        Text(title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer().frame(height: 6)

                        Text(location)
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Spacer().frame(height: 20)

                        HStack {
                            Text(price)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Spacer()
                        }
                    }
                    .padding(24)
                }
                .background(Color(white: 0.12))
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