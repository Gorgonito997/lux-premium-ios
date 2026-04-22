import SwiftUI

struct DevelopmentCard: View {
    // Propiedades idénticas a las de Kotlin
    var title: String
    var location: String
    var price: String
    var status: String
    var id: String = ""
    var badgeCount: Int = 0
    var onClick: () -> Void

    var body: some View {
        // ZStack equivale al Box() exterior de Compose para poder poner el Badge encima
        ZStack(alignment: .topTrailing) {

            // --- CARTA PRINCIPAL ---
            // Usamos un Button para replicar el "clickable { onClick() }"
            Button(action: onClick) {
                VStack(spacing: 0) { // Column interior

                    // 1. IMAGEN
                    // Usamos la misma llamada a vuestro mapper de imágenes
                    Image(DevelopmentImageMapper.mapIdToDrawable(id))
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .frame(maxWidth: .infinity)
                        .clipped() // Equivale a ContentScale.Crop

                    // 2. CONTENIDO (Textos)
                    VStack(alignment: .leading, spacing: 0) {
                        // Título
                        Text(title)
                            .font(.title3) // Equivale a titleLarge
                            .fontWeight(.semibold)
                            .foregroundColor(Color(UIColor.label)) // onSurface

                        Spacer().frame(height: 6)

                        // Localización
                        Text(location)
                            .font(.subheadline) // bodyMedium
                            .foregroundColor(Color(UIColor.secondaryLabel)) // onSurfaceVariant

                        Spacer().frame(height: 20)

                        // Fila de Precio y Estado (Equivale al Row(SpaceBetween))
                        HStack {
                            Text(price)
                                .font(.headline) // titleMedium
                                .fontWeight(.semibold)
                                .foregroundColor(.accentColor) // colorScheme.primary

                            Spacer() // Empuja el estado hacia la derecha

                            if !status.isEmpty {
                                Text(status.uppercased())
                                    .font(.caption) // labelSmall
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(UIColor.secondarySystemBackground)) // surfaceVariant
                                    .cornerRadius(8)
                                    .overlay(
                                        // Borde fino para el estado
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1) // outline copy 0.3
                                    )
                            }
                        }
                    }
                    .padding(24) // El padding general de la caja de texto
                }
                .background(Color(UIColor.systemBackground)) // color de la carta (surface)
                .cornerRadius(24) // Redondeo general de la carta
                .overlay(
                    // Borde de la carta (primary copy 0.4f)
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.accentColor.opacity(0.4), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle()) // Evita que la carta se ponga azul/gris entera al pulsarla

            // --- BADGE (Contador de notificaciones) ---
            if badgeCount > 0 {
                ZStack {
                    Circle()
                        // Color RGB exacto: 171, 7, 7
                        .fill(Color(red: 171/255, green: 7/255, blue: 7/255))
                        .frame(width: 40, height: 40)
                        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4) // shadowElevation

                    Text("\(badgeCount)")
                        .font(.system(size: 13, weight: .bold)) // 13.sp bold
                        .foregroundColor(.white)
                }
                .padding(16) // Equivale al Modifier.padding(16.dp) desde el top end
            }
        }
        .frame(maxWidth: .infinity)
    }
}


// MARK: - Dependencias necesarias
// Si Diego ya ha creado el DevelopmentImageMapper en Swift, BORRA este bloque de abajo.
// Si no lo tenéis todavía, déjalo para que Xcode no dé error al compilar.
struct DevelopmentImageMapper {
    static func mapIdToDrawable(_ id: String) -> String {
        // En iOS devolvemos el nombre del Asset como String
        return "propiedad_placeholder" // Cambia esto por la foto por defecto que tengáis
    }
}