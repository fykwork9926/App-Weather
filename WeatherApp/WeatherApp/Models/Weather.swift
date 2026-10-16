import Foundation

/// Modelo "limpo" que a interface usa.
///
/// Por que não usar o `WeatherResponse` direto na View?
/// Porque ele é o formato da API (pode mudar, tem campos aninhados).
/// O `Weather` é o formato do NOSSO app: simples e pronto para exibir.
/// Se um dia trocarmos de API, só o mapeamento muda — a View continua igual.
struct Weather: Equatable {
    let cityName: String
    let temperature: Double
    let feelsLike: Double
    let humidity: Int
    let description: String
    let conditionCode: Int
    let isNight: Bool

    /// Temperatura já formatada: "22°C"
    var temperatureText: String {
        "\(Int(temperature.rounded()))°C"
    }

    /// Ícone do SF Symbols (vem grátis no iOS) de acordo com o código da condição.
    /// Tabela de códigos: https://openweathermap.org/weather-conditions
    var symbolName: String {
        switch conditionCode {
        case 200...299: return "cloud.bolt.rain.fill"           // Tempestade
        case 300...399: return "cloud.drizzle.fill"             // Garoa
        case 500...599: return "cloud.rain.fill"                // Chuva
        case 600...699: return "cloud.snow.fill"                // Neve
        case 700...799: return "cloud.fog.fill"                 // Névoa / neblina
        case 800:       return isNight ? "moon.stars.fill" : "sun.max.fill" // Céu limpo
        case 801...802: return isNight ? "cloud.moon.fill" : "cloud.sun.fill" // Poucas nuvens
        default:        return "cloud.fill"                     // Nublado
        }
    }
}

// MARK: - Conversão API → App

extension Weather {
    /// Converte a resposta da API no nosso modelo.
    init(from response: WeatherResponse) {
        let condition = response.weather.first // a API manda uma lista; usamos a principal

        self.init(
            cityName: response.name,
            temperature: response.main.temp,
            feelsLike: response.main.feelsLike,
            humidity: response.main.humidity,
            description: condition?.description.capitalized ?? "—",
            conditionCode: condition?.id ?? 803,
            isNight: condition?.icon.hasSuffix("n") ?? false
        )
    }
}

// MARK: - Dados de exemplo (usados no Mock e nos Previews)

extension Weather {
    static let sample = Weather(
        cityName: "São Paulo",
        temperature: 24.3,
        feelsLike: 25.1,
        humidity: 68,
        description: "Parcialmente Nublado",
        conditionCode: 802,
        isNight: false
    )
}
