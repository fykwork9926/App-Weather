import SwiftUI

/// Tela inicial, antes de qualquer busca.
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            // Image("logo") procura uma imagem com esse nome no Assets.xcassets
            Image("logo")
                .resizable()                                        // permite redimensionar
                .scaledToFit()                                      // mantém a proporção
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 28))      // cantos arredondados, igual a um ícone
                .shadow(color: .black.opacity(0.2), radius: 10, y: 5)

            Text("Busque uma cidade para ver o clima")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.85))
        }
    }
}

/// Tela de erro com botão de tentar novamente.
struct ErrorView: View {
    let message: String
    let retry: () -> Void // a ação vem de fora: a View pai decide o que "tentar de novo" faz

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
            Button("Tentar novamente", action: retry)
                .buttonStyle(.borderedProminent)
                .tint(.white.opacity(0.25))
        }
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()
        ErrorView(message: "Cidade não encontrada.") {}
    }
}

#Preview("Tela inicial") {
    ZStack {
        Color.blue.ignoresSafeArea()
        EmptyStateView()
    }
}
