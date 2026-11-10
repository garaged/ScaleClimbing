import Foundation

/// Presentation-owned lookup boundary. English source text is the safe fallback;
/// iOS resolves Spanish (Mexico) from the app bundle when that language is selected.
public enum AppCopy {
    public static func text(_ key: String) -> String {
        Bundle.main.localizedString(forKey: key, value: key, table: "Localizable")
    }

    /// Translates feedback and generated prompt fragments without changing notes,
    /// chord symbols, Roman numerals, interval values, or other theory notation.
    public static func learnerText(_ source: String, languageCode: String? = Bundle.main.preferredLocalizations.first) -> String {
        guard languageCode?.lowercased().hasPrefix("es") == true else { return source }

        let replacements: [(String, String)] = [
            ("No notes selected yet.", "Aún no hay notas seleccionadas."),
            ("No notes selected.", "No hay notas seleccionadas."),
            ("Round complete. Ready for the next chord.", "Ronda completada. Lista para el siguiente acorde."),
            ("Round still open. Change the selected notes and check again.", "La ronda sigue abierta. Cambia las notas seleccionadas y comprueba de nuevo."),
            ("Select the chord tones for ", "Selecciona las notas del acorde para "),
            ("Find every ", "Encuentra cada "),
            (" on the keyboard.", " en el teclado."),
            ("Correct. ", "Correcto. "),
            ("Not quite. ", "No es correcto. "),
            ("Not yet. ", "Aún no. "),
            ("Try another key.", "Prueba otra tecla."),
            ("Adjust and retry.", "Ajusta e inténtalo de nuevo."),
            ("Clear or continue choosing and retry.", "Limpia o continúa eligiendo e inténtalo de nuevo."),
            ("Clear and retry the pulse.", "Limpia e inténtalo de nuevo con el pulso."),
            ("Round ", "Ronda "),
            (" of ", " de "),
            (" correct", " correctas"),
            ("Accuracy: ", "Precisión: "),
            ("Selected: ", "Seleccionado: "),
            ("Answer: ", "Respuesta: "),
            ("Semitones: ", "Semitonos: "),
            ("Notes: ", "Notas: "),
            ("Key signature: ", "Armadura: "),
            ("Which ", "¿Cuál "),
            ("Build ", "Construye "),
            ("Hear ", "Escucha "),
            ("Listen ", "Escucha "),
            ("Explore", "Explorar"),
            ("Listen", "Escuchar"),
            ("Build", "Construir"),
            ("Beginner", "Principiante"),
            ("All keys", "Todas las tonalidades"),
            ("Major", "Mayor"),
            (" major", " mayor"),
            (" minor", " menor"),
            ("Minor", "Menor"),
            ("Up", "Ascendente"),
            ("Down", "Descendente"),
            ("Same", "Igual"),
            ("Direction", "Dirección"),
            ("Interval distance", "Distancia del intervalo"),
            ("Octave awareness", "Reconocimiento de octava"),
            ("No numerals selected.", "No hay números romanos seleccionados."),
            ("No notes selected.", "No hay notas seleccionadas."),
            ("Check its clef position and accidental.", "Revisa su posición en la clave y su alteración."),
            ("different staff positions.", "distintas posiciones en el pentagrama."),
            ("Practice range", "Rango de práctica")
        ]

        return replacements.reduce(source) { result, replacement in
            result.replacingOccurrences(of: replacement.0, with: replacement.1)
        }
    }
}
