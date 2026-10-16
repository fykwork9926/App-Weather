import Foundation

// MARK: - Contrato

/// Protocolo = "contrato". A ViewModel só conhece ESTE tipo, não a implementação.
/// Assim podemos trocar a API real por um Mock (testes, previews, sem internet)
/// sem mudar nenhuma linha da ViewModel. Isso se chama Injeção de Dependência.
protocol WeatherServiceProtocol {
    func fetchWeather(for city: String) async throws -> Weather
}

// MARK: - Erros possíveis

/// Erros do nosso domínio, com mensagens amigáveis para mostrar ao usuário.
enum WeatherError: LocalizedError {
    case invalidURL
    case cityNotFound
    case invalidAPIKey
    case serverError(statusCode: Int)
    case decodingFailed
    case network

    var errorDescription: String? {
        switch self {
        case .invalidURL:              return "Não foi possível montar a requisição."
        case .cityNotFound:            return "Cidade não encontrada. Confira o nome e tente de novo."
        case .invalidAPIKey:           return "API Key inválida ou ainda não ativada."
        case .serverError(let code):   return "O servidor respondeu com erro (\(code))."
        case .decodingFailed:          return "Não conseguimos ler os dados do clima."
        case .network:                 return "Sem conexão. Verifique sua internet."
        }
    }
}

// MARK: - Implementação real (OpenWeatherMap)

struct OpenWeatherService: WeatherServiceProtocol {

    private let apiKey: String
    private let session: URLSession

    /// `URLSession.shared` é a sessão HTTP padrão do sistema, pronta para uso.
    init(apiKey: String = Secrets.openWeatherAPIKey, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func fetchWeather(for city: String) async throws -> Weather {
        // 1) Montar a URL com segurança.
        //    URLComponents cuida de codificar espaços e acentos ("São Paulo" → "S%C3%A3o%20Paulo").
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        components?.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric"), // Celsius
            URLQueryItem(name: "lang", value: "pt_br")    // descrições em português
        ]
        guard let url = components?.url else { throw WeatherError.invalidURL }

        // 2) Fazer a requisição.
        //    `await` pausa esta função SEM travar a tela até a resposta chegar.
        //    `data` = corpo da resposta (o JSON em bytes); `response` = metadados (status code etc.).
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw WeatherError.network
        }

        // 3) Conferir o status HTTP antes de tentar ler o JSON.
        guard let http = response as? HTTPURLResponse else {
            throw WeatherError.serverError(statusCode: -1)
        }
        switch http.statusCode {
        case 200...299: break                         // Sucesso → segue
        case 401:       throw WeatherError.invalidAPIKey
        case 404:       throw WeatherError.cityNotFound
        default:        throw WeatherError.serverError(statusCode: http.statusCode)
        }

        // 4) Converter JSON → struct com `Codable`.
        //    `.convertFromSnakeCase` transforma "feels_like" em `feelsLike` automaticamente.
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let apiResponse = try decoder.decode(WeatherResponse.self, from: data)
            return Weather(from: apiResponse)
        } catch {
            throw WeatherError.decodingFailed
        }
    }
}

// MARK: - Implementação falsa (Mock)

/// Devolve dados locais com um pequeno atraso, simulando a rede.
/// Útil para desenvolver a interface antes de ter a API Key, e para os Previews.
struct MockWeatherService: WeatherServiceProtocol {
    func fetchWeather(for city: String) async throws -> Weather {
        try await Task.sleep(nanoseconds: 800_000_000) // 0,8 s (API compatível com iOS 16)

        // Digite "erro" na busca para testar a tela de erro.
        if city.lowercased() == "erro" { throw WeatherError.cityNotFound }

        return Weather(
            cityName: city.capitalized,
            temperature: .random(in: 12...34),
            feelsLike: .random(in: 12...34),
            humidity: .random(in: 40...90),
            description: "Céu Limpo",
            conditionCode: 800,
            isNight: false
        )
    }
}
