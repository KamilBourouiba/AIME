/*
 Vue pour afficher les logs de tokens
 */

import SwiftUI
import AIME

struct TokenLogsView: View {
    @State private var tokenUsage: TokenUsage = TokenUsage(inputTokens: 0, outputTokens: 0)
    @State private var usageHistory: [TokenUsage] = []
    @State private var timer: Timer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("📊 Logs de Tokens")
                .font(.headline)
            
            // Statistiques totales
            VStack(alignment: .leading, spacing: 8) {
                Text("Statistiques Totales")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Input")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(tokenUsage.inputTokens)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Output")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(tokenUsage.outputTokens)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(tokenUsage.totalTokens)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                    }
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            
            // Historique
            if !usageHistory.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Historique")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Button("Réinitialiser") {
                            TokenTracker.shared.reset()
                            updateStats()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 5) {
                            ForEach(Array(usageHistory.enumerated()), id: \.offset) { index, usage in
                                HStack {
                                    Text("\(index + 1).")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Input: \(usage.inputTokens)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    
                                    Text("Output: \(usage.outputTokens)")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                    
                                    Spacer()
                                    
                                    Text("Total: \(usage.totalTokens)")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    
                                    Text(formatTime(usage.timestamp))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(5)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(10)
            } else {
                Text("Aucun historique disponible")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .onAppear {
            updateStats()
            // Mettre à jour toutes les secondes
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                updateStats()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func updateStats() {
        tokenUsage = TokenTracker.shared.getTotalUsage()
        usageHistory = TokenTracker.shared.getUsageHistory()
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    TokenLogsView()
        .padding()
}

