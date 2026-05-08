import SwiftUI

struct ClientDevelopmentDetailScreen: View {
    let devId: String
    let onBack: () -> Void
    let onNavigateToDocuments: () -> Void
    let onNavigateToAssistant: () -> Void

    @StateObject private var viewModel: ClientDevelopmentDetailViewModel

    init(devId: String, onBack: @escaping () -> Void, onNavigateToDocuments: @escaping () -> Void, onNavigateToAssistant: @escaping () -> Void) {
        self.devId = devId
        self.onBack = onBack
        self.onNavigateToDocuments = onNavigateToDocuments
        self.onNavigateToAssistant = onNavigateToAssistant
        _viewModel = StateObject(wrappedValue: ClientDevelopmentDetailViewModel(devId: devId))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView().tint(.white)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Botón Volver
                        Button(action: onBack) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Volver")
                            }
                            .foregroundColor(.white)
                        }
                        .padding(.top, 10)

                        if let dev = viewModel.development {
                            // Título y Ubicación
                            VStack(alignment: .leading, spacing: 4) {
                                Text(dev.name)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                Text(dev.location)
                                    .font(.title3)
                                    .foregroundColor(.gray)
                            }

                            // Imagen Principal
                            // Nota: Asegúrate de tener DevelopmentImageMapper o usa AsyncImage
                            Image(systemName: "house.fill") // Placeholder
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                                .cornerRadius(20)

                            // Botones de Acción
                            VStack(spacing: 12) {
                                Button(action: onNavigateToDocuments) {
                                    HStack {
                                        Image(systemName: "doc.text")
                                        Text("Ver documentos de la promoción")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(12)
                                }

                                if let folderUrl = viewModel.user?.personalDriveFolderUrl, !folderUrl.isEmpty {
                                    Link(destination: URL(string: folderUrl)!) {
                                        HStack {
                                            Image(systemName: "folder.badge.person.crop")
                                            Text("Mi carpeta personal (Drive)")
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                    }
                    .padding(24)
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}