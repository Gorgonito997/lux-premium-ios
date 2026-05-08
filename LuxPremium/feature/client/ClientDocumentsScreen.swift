import SwiftUI

struct ClientDocumentsScreen: View {
    let devId: String
    let onBack: () -> Void

    @StateObject private var viewModel: ClientDocumentsViewModel

    init(devId: String, onBack: @escaping () -> Void) {
        self.devId = devId
        self.onBack = onBack
        // Asumimos que tienes un ClientDocumentsViewModel para esta vista
        _viewModel = StateObject(wrappedValue: ClientDocumentsViewModel(devId: devId))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // Fondo base oscuro
                Color.black.ignoresSafeArea()

                content

                // Botón flotante de contacto
                PremiumContactFab()
                    .padding(16)
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("DOCUMENTOS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .tracking(1.5)
                        .foregroundColor(.white)
                }
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

        } else if viewModel.documents.isEmpty {
            Text("No hay documentos disponibles.")
                .font(.body)
                .foregroundColor(.white.opacity(0.5))
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else {
            ClientDocumentsContent(documents: viewModel.documents)
        }
    }
}

// MARK: - Contenido Agrupado
struct ClientDocumentsContent: View {
    let documents: [DevelopmentDocument]

    var body: some View {
        // Agrupamos los documentos por categoría (equivalente a groupBy de Kotlin)
        let grouped = Dictionary(grouping: documents, by: { $0.category })

        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                // Iteramos sobre las categorías ordenadas alfabéticamente
                ForEach(Array(grouped.keys.sorted()), id: \.self) { category in

                    Text(category.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue) // Reemplazar por tu MaterialTheme.colorScheme.primary
                        .tracking(0.5)
                        .padding(.top, 8)
                        .padding(.bottom, 8)

                    // Lista de documentos bajo esta categoría
                    ForEach(grouped[category] ?? []) { document in
                        // Reutilizamos el componente que ya creaste en la sección de Broker
                        DocumentItemRow(doc: document)
                    }
                }
            }
            .padding(24)

            Spacer().frame(height: 80) // Espacio para el FAB
        }
    }
}