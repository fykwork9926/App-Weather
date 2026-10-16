import SwiftUI

/// Tela principal: barra de busca + conteúdo que muda conforme o estado.
struct WeatherView: View {

    // `@StateObject`: a View CRIA e é DONA da ViewModel.
    // O SwiftUI mantém a mesma instância viva mesmo quando a tela é redesenhada
    // (se fosse `@ObservedObject`, ela poderia ser recriada e perder o estado).
    @StateObject private var viewModel: WeatherViewModel

    init(service: WeatherServiceProtocol = OpenWeatherService()) {
        _viewModel = StateObject(wrappedValue: WeatherViewModel(service: service))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                background

                // O `switch` no estado decide o que aparece na tela.
                Group {
                    switch viewModel.state {
                    case .idle:
                        EmptyStateView()
                    case .loading:
                        ProgressView("Buscando clima...")
                            .tint(.white)
                            .foregroundStyle(.white)
                    case .loaded(let weather):
                        WeatherCardView(weather: weather)
                    case .error(let message):
                        ErrorView(message: message) {
                            Task { await viewModel.search() } // "Tentar de novo"
                        }
                    }
                }
                .padding()
                .animation(.easeInOut, value: viewModel.state) // transição suave entre estados
            }
            .navigationTitle("Clima")
            .toolbarColorScheme(.dark, for: .navigationBar)
            // `$viewModel.searchText` é um Binding: o que o usuário digita
            // vai direto para a propriedade @Published da ViewModel.
            .searchable(text: $viewModel.searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Digite uma cidade")
            // Disparado quando o usuário toca em "Buscar" no teclado.
            .onSubmit(of: .search) {
                // `Task` cria um contexto assíncrono para chamar a função `async`.
                Task { await viewModel.search() }
            }
        }
    }

    /// Fundo em degradê.
    private var background: some View {
        LinearGradient(colors: [.blue, .cyan],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }
}

// MARK: - Previews (usam o Mock, então não precisam de internet nem de API Key)

#Preview("Mock") {
    WeatherView(service: MockWeatherService())
}
