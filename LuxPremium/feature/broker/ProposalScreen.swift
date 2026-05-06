import SwiftUI

struct ProposalScreen: View {
    let devId: String
    let unitId: String
    let originalPrice: Double // En Swift es más común usar Double para moneda
    let typology: String
    let onBack: () -> Void

    @StateObject private var viewModel: ProposalViewModel

    // Variables de estado para los inputs
    @State private var proposedPrice: String = ""
    @State private var paymentConditions: String = ""

    // Para controlar el teclado y poder ocultarlo al tocar fuera
    @FocusState private var isInputFocused: Bool

    init(
        devId: String,
        unitId: String,
        originalPrice: Double,
        typology: String,
        onBack: @escaping () -> Void
    ) {
        self.devId = devId
        self.unitId = unitId
        self.originalPrice = originalPrice
        self.typology = typology
        self.onBack = onBack

        // Inicializamos el valor por defecto del precio propuesto ya formateado
        _proposedPrice = State(initialValue: Self.formatInitialPrice(originalPrice))

        _viewModel = StateObject(wrappedValue: ProposalViewModel(
            devId: devId,
            unitId: unitId,
            originalPrice: originalPrice,
            typology: typology
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // Fondo oscuro principal
                Color.black.ignoresSafeArea()

                // Usamos un tap gesture en el fondo para ocultar el teclado
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isInputFocused = false
                    }

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {

                        // Título principal
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Propuesta de compra")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 40, height: 1)
                        }

                        // Summary Card (Tarjeta de resumen)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("UNIDAD \(unitId)".uppercased())
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.blue) // Cambiar por primary color
                                .tracking(1)

                            Text(typology)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(formatCurrency(originalPrice))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                Text("Precio de venta actual")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )

                        // Formularios
                        VStack(spacing: 16) {
                            // Input: Precio Propuesto
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Precio propuesto (€)")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                TextField("Ej: 150.000", text: $proposedPrice)
                                    .keyboardType(.numberPad)
                                    .focused($isInputFocused)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(16)
                                    .foregroundColor(.white)
                                    .onChange(of: proposedPrice) { newValue in
                                        // Esto simula tu VisualTransformation
                                        proposedPrice = formatThousands(newValue)
                                    }
                            }

                            // Input: Condiciones de pago
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Condiciones de pago (opcional)")
                                    .font(.caption)
                                    .foregroundColor(.gray)

                                TextField("Añade detalles sobre las condiciones de pago...", text: $paymentConditions, axis: .vertical)
                                    .lineLimit(5...8)
                                    .focused($isInputFocused)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(16)
                                    .foregroundColor(.white)
                            }
                        }

                        // Mensaje de Error
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                        }

                        // Submit Button (Botón Enviar)
                        Button(action: {
                            isInputFocused = false // Oculta el teclado al enviar
                            // Quitamos los puntos para enviar el número limpio al backend
                            let cleanPrice = proposedPrice.replacingOccurrences(of: ".", with: "")
                            let numericPrice = Double(cleanPrice) ?? 0
                            viewModel.sendProposal(price: numericPrice, conditions: paymentConditions)
                        }) {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("ENVIAR PROPUESTA")
                                    .fontWeight(.bold)
                                    .tracking(1)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.blue) // Usa tu MaterialTheme.colorScheme.primary
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.bottom, 32)

                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                }

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
            // Equivalente a LaunchedEffect(uiState) de Android
            .onChange(of: viewModel.isSuccess) { success in
                if success {
                    onBack()
                }
            }
        }
    }

    // MARK: - Funciones de Formateo

    // Simula tu ThousandsSeparatorVisualTransformation
    private func formatThousands(_ value: String) -> String {
        let rawNumbers = value.filter { $0.isNumber }
        guard !rawNumbers.isEmpty, let integerValue = Int(rawNumbers) else { return "" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: integerValue)) ?? value
    }

    private static func formatInitialPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: price)) ?? ""
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value) €"
    }
}