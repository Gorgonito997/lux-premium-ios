//
//  ContentView.swift
//  LuxPremium
//
//  Created by admin on 4/14/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.state.isLoggedIn, let uid = viewModel.state.uid {
                VStack(spacing: 12) {
                    Text("Login correcto")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("UID: \(uid)")
                        .font(.footnote)
                        .multilineTextAlignment(.center)

                    if let role = viewModel.state.role {
                        Text("Role: \(role)")
                            .font(.footnote)
                    }

                    Button("Cerrar sesion") {
                        viewModel.signOut()
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("LuxPremium")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Inicia sesion")
                        .font(.headline)

                    TextField("Email", text: $viewModel.state.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                        .disabled(viewModel.state.isLoading)

                    SecureField("Contrasena", text: $viewModel.state.password)
                        .textFieldStyle(.roundedBorder)
                        .disabled(viewModel.state.isLoading)

                    if let errorMessage = viewModel.state.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }

                    Button {
                        Task {
                            await viewModel.signIn()
                        }
                    } label: {
                        if viewModel.state.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Entrar")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.state.isLoading)
                }
                .frame(maxWidth: 420)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
