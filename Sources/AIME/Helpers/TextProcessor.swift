/*
 Helpers pour le traitement de texte
 */

import Foundation
import NaturalLanguage

/// Processeur de texte pour AIME
public struct TextProcessor {
    
    /// Diviser un texte en chunks pour traitement
    /// - Parameters:
    ///   - text: Le texte à diviser
    ///   - unit: Unité de tokenisation (par défaut: .paragraph)
    /// - Returns: Tableau de chunks de texte
    public static func chunkText(
        _ text: String,
        unit: NLTokenUnit = .paragraph
    ) -> [String] {
        let tokenizer = NLTokenizer(unit: unit)
        tokenizer.string = text
        let ranges = tokenizer.tokens(for: text.startIndex ..< text.endIndex)
        
        var chunks: [String] = []
        for range in ranges {
            let chunk = text[range].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !chunk.isEmpty else { continue }
            chunks.append(chunk)
        }
        
        return chunks
    }
    
    /// Vérifier si un texte est vide ou ne contient que des espaces
    /// - Parameter text: Le texte à vérifier
    /// - Returns: True si le texte est vide
    public static func isEmpty(_ text: String) -> Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Estimer le nombre de tokens approximatif
    /// - Parameter text: Le texte à analyser
    /// - Returns: Nombre approximatif de tokens
    public static func estimateTokenCount(_ text: String) -> Int {
        // Estimation approximative: 1 token ≈ 4 caractères
        return text.count / 4
    }
    
    /// Tronquer un texte à une longueur maximale
    /// - Parameters:
    ///   - text: Le texte à tronquer
    ///   - maxLength: Longueur maximale
    ///   - suffix: Suffixe à ajouter si tronqué (par défaut: "...")
    /// - Returns: Texte tronqué
    public static func truncate(
        _ text: String,
        maxLength: Int,
        suffix: String = "..."
    ) -> String {
        guard text.count > maxLength else {
            return text
        }
        
        let index = text.index(text.startIndex, offsetBy: maxLength - suffix.count)
        return String(text[..<index]) + suffix
    }
}

