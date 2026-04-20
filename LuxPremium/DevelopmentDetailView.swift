import SwiftUI

struct DevelopmentDetailView: View {
    let developmentId: String

    @StateObject private var viewModel = DevelopmentDetailViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.isLoading {
                Spacer()
                ProgressView("Cargando promocion")
                    .frame(maxWidth: .infinity)
                Spacer()
            } else if let errorMessage = viewModel.errorMessage {
                Spacer()
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                content
            }
        }
        .padding()
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: developmentId) {
            await viewModel.load(developmentId: developmentId)
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let development = viewModel.development {
                VStack(alignment: .leading, spacing: 8) {
                    Text(development.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(development.location)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(development.status)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Text("Unidades")
                .font(.title2)
                .fontWeight(.semibold)

            if viewModel.units.isEmpty {
                Spacer()
                Text("No hay unidades disponibles.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                List(viewModel.units) { unit in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(unit.typology)
                            .font(.headline)

                        Text("Precio: \(unit.price)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("Metros: \(unit.sqm, specifier: "%.2f") m2")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Text("Dormitorios: \(unit.bedrooms)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Text("Disponibilidad: \(unit.availability)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)

                        Text("Certificado energetico: \(unit.energyCertificate)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DevelopmentDetailView(developmentId: "preview-development")
    }
}
