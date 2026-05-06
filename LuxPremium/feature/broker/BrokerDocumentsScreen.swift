import SwiftUI

struct BrokerDocumentsScreen: View {
    let devId: String
    let onBack: () -> Void

    @StateObject private var viewModel: BrokerDocumentsViewModel

    init(devId: String, onBack: @escaping () -> Void) {
        self.devId = devId
        self.onBack = onBack
        _viewModel = StateObject(wrappedValue: BrokerDocumentsViewModel(devId: devId))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // Fondo base oscuro
                Color.black.ignoresSafeArea()

                content

                // Botón flotante
                PremiumContactFab()
                    .padding(16)
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                    }
                }
            }
            .task {
                await viewModel.loadDocuments()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
                .tint(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .foregroundColor(.red)
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else {
            // Filtramos excluyendo los contratos
            let docs = viewModel.documents.filter { $0.category != "Contratos" }

            if docs.isEmpty {
                Text("No hay documentos disponibles.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else {
                // Agrupamos por categoría
                let grouped = Dictionary(grouping: docs, by: { $0.category })

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {

                        Text("Documentos")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.bottom, 8)

                        // Iteramos sobre las categorías ordenadas alfabéticamente
                        ForEach(Array(grouped.keys.sorted()), id: \.self) { category in

                            Text(category.uppercased())
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.blue) // Cambia esto por tu MaterialTheme.colorScheme.primary
                                .tracking(0.5)
                                .padding(.top, 8)

                            // Mostramos los documentos de esta categoría
                            ForEach(grouped[category] ?? []) { doc in
                                DocumentItemRow(doc: doc)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
            }
        }
    }
}

// MARK: - Componente Fila de Documento

struct DocumentItemRow: View {
    let doc: DevelopmentDocument

    var body: some View {
        Button(action: {
            // Lógica del Intent de Android pasada a iOS
            if let url = URL(string: doc.downloadUrl.trimmingCharacters(in: .whitespacesAndNewlines)) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 16) {
                // Icono Description
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 4) {
                    Text(doc.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)

                    Text("TIPO DE ARCHIVO: \(doc.fileType.uppercased())")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }

                Spacer()

                // Icono Download
                Image(systemName: "arrow.down.circle")
                    .foregroundColor(.gray)
                    .font(.system(size: 20))
            }
            .padding(16)
            .background(Color.gray.opacity(0.15)) // Simula el surfaceVariant
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        // Para que la celda entera sea clicable como el Modifier.clickable
        .buttonStyle(PlainButtonStyle())
    }
}