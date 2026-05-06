import SwiftUI

struct BrokerContractsScreen: View {
    let devId: String
    let onBack: () -> Void

    @StateObject private var viewModel: BrokerDocumentsViewModel

    init(devId: String, onBack: @escaping () -> Void) {
        self.devId = devId
        self.onBack = onBack
        // Inicializamos el ViewModel con el ID de la promoción
        _viewModel = StateObject(wrappedValue: BrokerDocumentsViewModel(devId: devId))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // Fondo oscuro principal
                Color.black.ignoresSafeArea()

                content

                // Botón flotante de contacto (FloatingActionButton)
                PremiumContactFab()
                    .padding(16)
            }
            // Configuración del TopAppBar
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
                // Se ejecuta al abrir la pantalla para cargar los datos
                await viewModel.loadDocuments()
            }
        }
    }

    // El contenido principal que cambia según el estado (Loading, Error, Success)
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
                .tint(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else if let errorMessage = viewModel.errorMessage {
            Text(errorMessage) // En tu stringResource usas "contracts_error"
                .foregroundColor(.red)
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else {
            // Filtramos solo los contratos
            let docs = viewModel.documents.filter { $0.isContractDocument }

            if docs.isEmpty {
                Text("No hay contratos disponibles.")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.5)) // Similar al LocalContentColor.current.copy(alpha = 0.5f)
                    .padding(24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        // Título de la sección
                        Text("Contratos")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.bottom, 8)

                        // Lista de contratos
                        ForEach(docs) { doc in
                            DocumentItemRow(doc: doc)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                }
            }
        }
    }
}
