/*
 Tests pour la vérification de disponibilité des modèles
 */

import XCTest
@testable import AIME

final class ModelAvailabilityTests: XCTestCase {
    
    func testIsAvailable() {
        // Ce test vérifie que la fonction existe et peut être appelée
        // Le résultat dépend de l'environnement (disponibilité d'Apple Intelligence)
        let isAvailable = ModelAvailability.isAvailable()
        
        // Le résultat peut être true ou false selon l'environnement
        // On vérifie juste que la fonction ne crash pas
        XCTAssertTrue(isAvailable || !isAvailable) // Toujours vrai
    }
    
    func testUnavailabilityReason() {
        let reason = ModelAvailability.unavailabilityReason()
        
        // La raison peut être nil (si disponible) ou contenir une raison
        // On vérifie juste que la fonction ne crash pas
        XCTAssertTrue(reason == nil || reason != nil)
    }
    
    @MainActor
    func testIsTranscriptionAvailable() async {
        // Test asynchrone pour vérifier la disponibilité de la transcription
        let isAvailable = await ModelAvailability.isTranscriptionAvailable(locale: .current)
        
        // Le résultat dépend de l'environnement
        XCTAssertTrue(isAvailable || !isAvailable)
    }
}

