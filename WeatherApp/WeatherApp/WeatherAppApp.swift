// xcode: set sdk=iOS

import SwiftUI

/// Ponto de entrada do app.
@main
struct WeatherAppApp: App {
    var body: some Scene {
        WindowGroup {
            // Sem API Key ainda? Troque para: WeatherView(service: MockWeatherService())
            WeatherView()
        }
    }
}
