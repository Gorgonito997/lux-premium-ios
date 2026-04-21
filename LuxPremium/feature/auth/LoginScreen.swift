import SwiftUI
import UIKit

struct LoginScreen: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var passwordVisible = false
    @State private var selectedRole = "CLIENT"
    @State private var isLoading = false

    var body: some View {
        ZStack {
            // --- FONDO Y CAPA DE CONTRASTE ---
            Image("fondo_login")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.black.opacity(0.10)
                .ignoresSafeArea()

            // --- CONTENIDO PRINCIPAL ---
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Logotipo
                    Image("logotipo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 90)
                        .padding(.horizontal, 20)

                    Spacer().frame(height: 14)

                    Text("ACCESO RESERVADO")
                        .foregroundStyle(Color(hex: "E0E0E0"))
                        .font(.system(size: 13, weight: .light))
                        .tracking(1.2)

                    Spacer().frame(height: 16)

                    // --- FORMULARIO (Surface) ---
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Iniciar sesión")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        Spacer().frame(height: 8)

                        Text("Introduce tus credenciales para continuar")
                            .font(.subheadline)
                            .foregroundStyle(Color(hex: "9E9E9E"))
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer().frame(height: 20)

                        Text("SELECCIONA EL TIPO DE ACCESO")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color(hex: "BDBDBD"))
                            .fixedSize(horizontal: false, vertical: true)
                            .tracking(0.8)

                        Spacer().frame(height: 12)

                        // Selector de Rol
                        HStack(spacing: 12) {
                            RoleBox(text: "Cliente", isSelected: selectedRole == "CLIENT") {
                                selectedRole = "CLIENT"
                            }
                            RoleBox(text: "Broker", isSelected: selectedRole == "BROKER") {
                                selectedRole = "BROKER"
                            }
                        }

                        Spacer().frame(height: 20)

                        // Campos de Texto
                        LuxTextField(value: $email, label: "Correo electrónico", keyboardType: .emailAddress, isPasswordVisible: .constant(false))

                        Spacer().frame(height: 14)

                        LuxTextField(value: $password, label: "Contraseña", isPassword: true, isPasswordVisible: $passwordVisible)

                        // Botón Olvidaste Contraseña
                        HStack {
                            Spacer()
                            Button("¿Olvidaste tu contraseña?") { }
                            .font(.system(size: 12))
                            .foregroundStyle(Color(hex: "CFCFCF"))
                            .padding(.top, 8)
                        }

                        Spacer().frame(height: 18)

                        // Botón ENTRAR
                        Button(action: { }) {
                            Text("ENTRAR")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .cornerRadius(16)
                        }

                        Spacer().frame(height: 12)

                        // Botón Google
                        Button(action: { }) {
                            HStack {
                                Text("G")
                                    .fontWeight(.bold)
                                Text("Continuar con Google")
                                    .fontWeight(.semibold)
                            }
                            .font(.callout)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "181818").opacity(0.8))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: "383838"), lineWidth: 1)
                            )
                        }

                        Spacer().frame(height: 18)

                        Divider().background(Color(hex: "232323"))

                        Spacer().frame(height: 12)

                        // Botón Registro
                        HStack(spacing: 4) {
                            Text("¿No tienes cuenta?")
                                .foregroundStyle(Color(hex: "AFAFAF"))

                            Button("Regístrate") { }
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 22)
                    .background(Color(hex: "111111").opacity(0.55))
                    .cornerRadius(24)

                }
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity)
            }
        }
        // --- BOTÓN DE IDIOMA TOP RIGHT ---
        .overlay(alignment: .topTrailing) {
            Menu {
                Button("English") { }
                Button("Español") { }
                Button("Português") { }
            } label: {
                Image(systemName: "globe")
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(Color(hex: "141414").opacity(0.8))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(hex: "2A2A2A"), lineWidth: 1)
                    )
            }
            .padding(.trailing, 14)
            .padding(.top, 10)
        }
    }
} // <--- AQUÍ SE CIERRA LA PANTALLA PRINCIPAL

// MARK: - Componentes Secundarios

struct RoleBox: View {
    let text: String
    let isSelected: Bool
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? .black : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isSelected ? Color(hex: "EDEDED") : Color(hex: "181818").opacity(0.8))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color(hex: "EDEDED") : Color(hex: "2E2E2E"), lineWidth: 1)
                )
        }
    }
}

struct LuxTextField: View {
    @Binding var value: String
    var label: String
    var keyboardType: UIKeyboardType = .default
    var isPassword: Bool = false
    var isPasswordVisible: Binding<Bool>? = nil

    var body: some View {
        ZStack(alignment: .leading) {
            if value.isEmpty {
                Text(label)
                    .foregroundStyle(Color(hex: "BDBDBD"))
                    .padding(.horizontal, 16)
            }

            HStack {
                if isPassword, let visible = isPasswordVisible {
                    if !visible.wrappedValue {
                        SecureField("", text: $value)
                            .foregroundStyle(.white)
                            .submitLabel(.done)
                    } else {
                        TextField("", text: $value)
                            .foregroundStyle(.white)
                            .keyboardType(keyboardType)
                            .submitLabel(.done)
                    }

                    Button(action: { visible.wrappedValue.toggle() }) {
                        Image(systemName: visible.wrappedValue ? "eye.slash.fill" : "eye.fill")
                            .foregroundStyle(Color(hex: "CCCCCC"))
                    }
                } else {
                    TextField("", text: $value)
                        .foregroundStyle(.white)
                        .keyboardType(keyboardType)
                        .submitLabel(.next)
                }
            }
            .padding()
        }
        .background(Color(hex: "181818").opacity(0.8))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: "383838"), lineWidth: 1)
        )
    }
}

#Preview {
    LoginScreen(viewModel: LoginViewModel())
}
