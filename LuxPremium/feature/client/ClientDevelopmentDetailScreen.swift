import SwiftUI

// MARK: - Modelo Auxiliar para las acciones
struct ClientDetailAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let onClick: () -> Void
}

// MARK: - Pantalla Principal
struct ClientDevelopmentDetailScreen: View {
    let devId: String
    let onBack: () -> Void
    let onNavigateToDocuments: () -> Void
    let onNavigateToAssistant: () -> Void

    @StateObject private var viewModel: ClientDevelopmentDetailViewModel

    init(
        devId: String,
        onBack: @escaping () -> Void,
        onNavigateToDocuments: @escaping () -> Void,
        onNavigateToAssistant: @escaping () -> Void
    ) {
        self.devId = devId
        self.onBack = onBack
        self.onNavigateToDocuments = onNavigateToDocuments
        self.onNavigateToAssistant = onNavigateToAssistant

        // Asumimos que tu ViewModel carga tanto la promoción como el usuario
        _viewModel = StateObject(wrappedValue: ClientDevelopmentDetailViewModel(devId: devId))
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                    }
                }
            }
            .task {
                await viewModel.loadData()
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        } else if let development = viewModel.development {
            // Pasamos el development y el posible enlace a la carpeta personal del usuario
            ClientDevelopmentDetailContent(
                development: development,
                personalDriveFolderUrl: viewModel.user?.personalDriveFolderUrl,
                onNavigateToDocuments: onNavigateToDocuments,
                onNavigateToAssistant: onNavigateToAssistant
            )
        }
    }
}

// MARK: - Contenido de la Pantalla
struct ClientDevelopmentDetailContent: View {
    let development: Development
    let personalDriveFolderUrl: String?
    let onNavigateToDocuments: () -> Void
    let onNavigateToAssistant: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Imagen de Cabecera
                if !development.coverImageUrl.isEmpty {
                    AsyncImage(url: URL(string: development.coverImageUrl.trimmingCharacters(in: .whitespacesAndNewlines))) { phase in
                        if let image = phase.image {
                            image.resizable().aspectRatio(2.0, contentMode: .fill)
                        } else {
                            Color.gray.opacity(0.3).aspectRatio(2.0, contentMode: .fill)
                        }
                    }
                    .clipped()
                }

                VStack(alignment: .leading, spacing: 16) {

                    // Fila de Título, Ubicación y Estado
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(development.name)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text(development.location)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }

                        Spacer()

                        if !development.status.isEmpty {
                            Text(development.status.uppercased())
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.15))
                                .foregroundColor(.white.opacity(0.8)) // onSurfaceVariant aproximado
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }

                    Spacer().frame(height: 8)

                    // Botón Asistente IA (Destacado)
                    Button(action: onNavigateToAssistant) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Asistente IA")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue.opacity(0.15)) // Ajustar al color primary
                        .foregroundColor(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue.opacity(0.6), lineWidth: 1)
                        )
                    }

                    Spacer().frame(height: 24)

                    // Título Documentos
                    Text("DOCUMENTOS")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .tracking(1.2)
                        .foregroundColor(.white)

                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 32, height: 1)

                    Spacer().frame(height: 8)

                    // Cuadrícula de Acciones (Botones secundarios)
                    ClientDetailActionsGrid(
                        development: development,
                        personalDriveFolderUrl: personalDriveFolderUrl,
                        onNavigateToDocuments: onNavigateToDocuments
                    )
                }
                .padding(24)

                Spacer().frame(height: 80) // Espacio para el FAB
            }
        }
    }
}

// MARK: - Cuadrícula de Acciones (Grid)
struct ClientDetailActionsGrid: View {
    let development: Development
    let personalDriveFolderUrl: String?
    let onNavigateToDocuments: () -> Void

    // Lógica dinámica para mostrar botones solo si existen las URLs
    private var gridActions: [ClientDetailAction] {
        var actions: [ClientDetailAction] = []

        actions.append(ClientDetailAction(title: "Ver documentos", icon: "doc.text.fill", onClick: onNavigateToDocuments))

        let driveImagesUrl = development.driveImagesFolderUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        if !driveImagesUrl.isEmpty {
            actions.append(ClientDetailAction(title: "Imágenes 3D", icon: "photo.fill") {
                if let url = URL(string: driveImagesUrl) { UIApplication.shared.open(url) }
            })
        }

        let driveWorkUrl = development.driveWorkImagesFolderUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        if !driveWorkUrl.isEmpty {
            actions.append(ClientDetailAction(title: "Imágenes de obra", icon: "photo.on.rectangle.angled") {
                if let url = URL(string: driveWorkUrl) { UIApplication.shared.open(url) }
            })
        }

        if let myFolder = personalDriveFolderUrl?.trimmingCharacters(in: .whitespacesAndNewlines), !myFolder.isEmpty {
            actions.append(ClientDetailAction(title: "Mi carpeta", icon: "folder.fill") {
                if let url = URL(string: myFolder) { UIApplication.shared.open(url) }
            })
        }

        return actions
    }

    var body: some View {
        VStack(spacing: 12) {
            // Usamos la extensión chunked(into: 2) para separar en filas de 2
            let rows = gridActions.chunked(into: 2)
            ForEach(0..<rows.count, id: \.self) { rowIndex in
                let rowActions = rows[rowIndex]

                HStack(spacing: 12) {
                    ForEach(rowActions) { action in
                        PremiumCompactActionCard(
                            title: action.title,
                            icon: action.icon,
                            onClick: action.onClick
                        )
                    }
                    // Si la fila solo tiene 1 elemento, rellenamos el espacio para que no se estire
                    if rowActions.count == 1 {
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - Tarjeta Compacta (Botón Cuadrícula)
struct PremiumCompactActionCard: View {
    let title: String
    let icon: String
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.blue) // Ajustar al color primary
                    .font(.system(size: 24))

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            // Para que ocupe la mitad de la pantalla disponible equitativamente
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Extensiones
// Esta extensión nos permite agrupar el array de 2 en 2, igual que `chunked(2)` en Kotlin
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}