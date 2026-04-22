import SwiftUI

struct PrimaryButton<Content: View>: View {
    var action: () -> Void
    var isEnabled: Bool = true
    var isLoading: Bool = false

    // @ViewBuilder es el equivalente a pasar un @Composable como parámetro
    @ViewBuilder var content: () -> Content

    var body: some View {
        Button(action: {
            // El botón solo ejecuta la acción si no está cargando
            if !isLoading {
                action()
            }
        }) {
            ZStack {
                if isLoading {
                    // CircularProgressIndicator
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2) // Lo hacemos un poco más grande para igualar los 24dp
                } else {
                    // HStack actúa como el RowScope de Compose
                    HStack(spacing: 8) {
                        content()
                    }
                    // Forzamos la fuente para que el texto por defecto se vea premium
                    .font(.system(size: 16, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58) // Altura premium fija
            // Color del texto (Blanco si está activo, gris transparente si está desactivado)
            .foregroundColor(isEnabled ? .white : Color(UIColor.label).opacity(0.3))
        }
        // SwiftUI desactiva los toques automáticamente con este modificador
        .disabled(!isEnabled || isLoading)
        // Color de fondo (Color principal vs gris transparente)
        .background(isEnabled ? Color.accentColor : Color.gray.opacity(0.3))
        .cornerRadius(16) // shape = RoundedCornerShape(16.dp)
        // Añadimos una transición súper suave entre el texto y el spinner
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

// MARK: - Vista Previa para que veas los 3 estados en Xcode
#Preview {
    VStack(spacing: 20) {
        PrimaryButton(action: {}) {
            Text("ENTRAR")
        }

        PrimaryButton(action: {}, isLoading: true) {
            Text("Cargando")
        }

        PrimaryButton(action: {}, isEnabled: false) {
            Text("DESACTIVADO")
        }
    }
    .padding()
}