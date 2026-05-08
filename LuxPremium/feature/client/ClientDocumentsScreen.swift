import SwiftUI

struct ClientDocumentsScreen: View {
    let devId: String
    let onBack: () -> Void

    @StateObject private var viewModel: ClientDocumentsViewModel

    init(devId: String, onBack: @escaping () -> Void) {
        self.devId = devId
        self.onBack = onBack
        _viewModel = StateObject(wrappedValue: ClientDocumentsViewModel(devId: devId))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading) {
                // Cabecera
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }

                    Text("Documentos")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                if viewModel.isLoading {
                    Spacer()
                    HStack { Spacer(); ProgressView().tint(.white); Spacer() }
                    Spacer()
                } else if viewModel.documents.isEmpty {
                    Spacer()
                    Text("No hay documentos disponibles para esta promoción.")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    List(viewModel.documents) { doc in
                        DocumentRow(document: doc)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }
        }
        .task {
            await viewModel.loadDocuments()
        }
    }
}

// Componente pequeño para cada fila de documento
struct DocumentRow: View {
    let document: DevelopmentDocument

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "filemenu.and.selection")
                .font(.title2)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(document.name)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(document.category)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            if let url = URL(string: document.downloadUrl) {
                Link(destination: url) {
                    Image(systemName: "arrow.down.circle")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .padding(.vertical, 4)
    }
}