import SwiftUI

struct PremiumContactFab: View {
    var phoneNumber: String = "+351 961 500 272"

    var body: some View {
        Button(action: {
            let cleanedNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
            if let phoneURL = URL(string: "tel://\(cleanedNumber)") {
                if UIApplication.shared.canOpenURL(phoneURL) {
                    UIApplication.shared.open(phoneURL)
                }
            }
        }) {
            Image(systemName: "phone.fill")
                .font(.system(size: 24))
                .foregroundColor(.black) // Icono Negro
                .frame(width: 56, height: 56)
                .background(Color.white) // Fondo Blanco
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.5), radius: 6, x: 0, y: 4)
        }
    }
}