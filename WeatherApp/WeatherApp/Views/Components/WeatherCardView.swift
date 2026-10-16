import SwiftUI

/// Cartão com o clima da cidade. Recebe só os dados prontos — não conhece a ViewModel.
/// Componentes "burros" assim são fáceis de reutilizar e de testar no Preview.
struct WeatherCardView: View {
    let weather: Weather

    var body: some View {
        VStack(spacing: 16) {
            Text(weather.cityName)
                .font(.largeTitle.bold())

            Image(systemName: weather.symbolName)
                .symbolRenderingMode(.multicolor) // usa as cores oficiais do símbolo (sol amarelo etc.)
                .font(.system(size: 96))

            Text(weather.temperatureText)
                .font(.system(size: 72, weight: .thin))

            Text(weather.description)
                .font(.title3)

            HStack(spacing: 24) {
                Label("Sensação \(Int(weather.feelsLike.rounded()))°", systemImage: "thermometer.medium")
                Label("\(weather.humidity)%", systemImage: "humidity.fill")
            }
            .font(.subheadline)
            .opacity(0.9)
        }
        .foregroundStyle(.white)
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial.opacity(0.4), in: RoundedRectangle(cornerRadius: 28))
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        WeatherCardView(weather: .sample).padding()
    }
}
