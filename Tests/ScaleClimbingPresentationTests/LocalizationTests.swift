import Testing
@testable import ScaleClimbingPresentation

@Test func learnerCopyKeepsEnglishAsTheFallback() {
    #expect(AppCopy.learnerText("Correct. Build C major scale.", languageCode: "en") == "Correct. Build C major scale.")
}

@Test func learnerCopyTranslatesFeedbackWithoutChangingTheorySymbols() {
    let localized = AppCopy.learnerText("Correct. Build C major scale.", languageCode: "es-MX")
    #expect(localized.contains("Correcto."))
    #expect(localized.contains("C"))
    #expect(localized.contains("major") == false)
}
