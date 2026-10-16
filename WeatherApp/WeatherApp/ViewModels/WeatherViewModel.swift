import Foundation
import Combine // ObservableObject e @Published vêm do Combine (o Xcode 26 exige o import explícito)

@MainActor
final class WeatherViewModel: ObservableObject {

    enum ViewState: Equatable {
        case idle
        case loading
        case loaded(Weather)
        case error(String)
    }

    @Published var searchText = ""
    @Published private(set) var state: ViewState = .idle

    private let service: WeatherServiceProtocol

    /// Recebe o service "de fora" (injeção de dependência).
    /// Se nada for passado (`nil`), usa a API real.
    /// O service é criado DENTRO do init, que já roda no MainActor, para evitar o aviso de isolamento.
    init(service: WeatherServiceProtocol? = nil) {
        self.service = service ?? OpenWeatherService()
    }

    /// Chamado quando o usuário confirma a busca.
    func search() async {
        let city = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !city.isEmpty else { return }

        state = .loading

        do {
            let weather = try await service.fetchWeather(for: city)
            state = .loaded(weather)
        } catch {
            // `localizedDescription` usa o `errorDescription` que definimos no WeatherError.
            state = .error(error.localizedDescription)
        }
    }
}
