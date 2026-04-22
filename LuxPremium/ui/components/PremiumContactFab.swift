import SwiftUI

struct PremiumContactFab: View {
    // Parámetro con el valor por defecto igual que en Kotlin
    var phoneNumber: String = "+351 961 500 272"

    var body: some View {
        Button(action: {
            // 1. Limpiamos los espacios en blanco del número para que iOS no falle
            let cleanedNumber = phoneNumber.replacingOccurrences(of: " ", with: "")

            // 2. Creamos la URL con el prefijo "tel://"
            if let phoneURL = URL(string: "tel://\(cleanedNumber)") {
                // 3. Comprobamos si el dispositivo puede hacer llamadas y la abrimos
                if UIApplication.shared.canOpenURL(phoneURL) {
                    UIApplication.shared.open(phoneURL)
                }
            }
        }) {
            Image(systemName: "phone.fill") // Equivale a Icons.Default.Phone
                .font(.system(size: 24))
                .foregroundColor(.white) // Equivale a onPrimary
                .frame(width: 56, height: 56) // Tamaño estándar de un FAB en Android
                .background(Color.accentColor) // Equivale a containerColor = primary
                .cornerRadius(16) // RoundedCornerShape(16.dp)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 4) // defaultElevation
        }
    }
}

#Preview {
    PremiumContactFab()
        .padding()
}