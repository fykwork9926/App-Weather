import Foundation

/// Espelho do JSON que a OpenWeatherMap devolve (só com os campos que usamos).
///
/// `Decodable` permite que o `JSONDecoder` converta o JSON nesta struct
/// automaticamente, desde que os nomes das propriedades batam com as chaves do JSON.
/// (`Codable` = `Decodable` + `Encodable`. Como só LEMOS dados, `Decodable` basta.)
///
/// Exemplo resumido do JSON:
/// {
///   "name": "São Paulo",
///   "main": { "temp": 22.4, "feels_like": 22.9, "humidity": 78 },
///   "weather": [ { "id": 804, "description": "nublado", "icon": "04d" } ]
/// }
struct WeatherResponse: Decodable {
    let name: String
    let main: Main
    let weather: [Condition]

    struct Main: Decodable {
        let temp: Double
        let feelsLike: Double // no JSON é "feels_like" → convertido pelo .convertFromSnakeCase
        let humidity: Int
    }

    struct Condition: Decodable {
        let id: Int              // código da condição (ex: 800 = céu limpo)
        let description: String  // texto já traduzido (usamos lang=pt_br)
        let icon: String         // ex: "01d" (d = dia, n = noite)
    }
}
