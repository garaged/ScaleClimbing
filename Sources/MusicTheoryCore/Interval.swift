public struct Interval: Codable, Hashable, Sendable, CustomStringConvertible {
    public let semitones: Int
    public let name: String
    public let shortName: String

    public init(semitones: Int, name: String, shortName: String) {
        self.semitones = semitones
        self.name = name
        self.shortName = shortName
    }

    public var description: String { name }

    public static let unison = Interval(semitones: 0, name: "Perfect unison", shortName: "P1")
    public static let minorSecond = Interval(semitones: 1, name: "Minor second", shortName: "m2")
    public static let majorSecond = Interval(semitones: 2, name: "Major second", shortName: "M2")
    public static let minorThird = Interval(semitones: 3, name: "Minor third", shortName: "m3")
    public static let majorThird = Interval(semitones: 4, name: "Major third", shortName: "M3")
    public static let perfectFourth = Interval(semitones: 5, name: "Perfect fourth", shortName: "P4")
    public static let tritone = Interval(semitones: 6, name: "Tritone", shortName: "TT")
    public static let perfectFifth = Interval(semitones: 7, name: "Perfect fifth", shortName: "P5")
    public static let minorSixth = Interval(semitones: 8, name: "Minor sixth", shortName: "m6")
    public static let majorSixth = Interval(semitones: 9, name: "Major sixth", shortName: "M6")
    public static let minorSeventh = Interval(semitones: 10, name: "Minor seventh", shortName: "m7")
    public static let majorSeventh = Interval(semitones: 11, name: "Major seventh", shortName: "M7")
    public static let octave = Interval(semitones: 12, name: "Perfect octave", shortName: "P8")

    public static let basicAscending: [Interval] = [
        .unison, .minorSecond, .majorSecond, .minorThird, .majorThird,
        .perfectFourth, .tritone, .perfectFifth, .minorSixth, .majorSixth,
        .minorSeventh, .majorSeventh, .octave
    ]
}
