// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Deck Register

// 1.1 — Deck enum with raw String values and CaseIterable
enum Deck: String, CaseIterable {
    case bridge
    case lab
    case greenhouse
    case cargo
    case medbay
    case engine
}

print("1.1 All decks: \(Deck.allCases.map { $0.rawValue })")
print("1.1 Deck from string 'lab': \(String(describing: Deck(rawValue: "lab")))")

// 1.2 — AlarmLevel enum with raw Int values
enum AlarmLevel: Int {
    case green  = 1
    case yellow = 2
    case orange = 3
    case red    = 4
}

print("1.2 Green alarm raw value: \(AlarmLevel.green.rawValue)")
print("1.2 AlarmLevel from raw 4: \(String(describing: AlarmLevel(rawValue: 4)))")


// MARK: Level 2 · The Manifest

// 2.1 — ManifestEntry enum with associated values
enum ManifestEntry {
    case crate(id: Int, mass: Int)
    case container(code: String, mass: Int)
    case livestock(species: String, count: Int, massEach: Int)
    case corrupted(raw: String)
}

// 2.2 — Parse a raw manifest line into a ManifestEntry
func parseEntry(_ line: String) -> ManifestEntry {
    let f = fields(line)
    guard f.count >= 1, !f[0].isEmpty else { return .corrupted(raw: line) }

    switch f[0] {
    case "crate":
        guard f.count == 3, let id = Int(f[1]), let mass = Int(f[2]) else {
            return .corrupted(raw: line)
        }
        return .crate(id: id, mass: mass)

    case "container":
        guard f.count == 3, let mass = Int(f[2]) else {
            return .corrupted(raw: line)
        }
        return .container(code: f[1], mass: mass)

    case "livestock":
        guard f.count == 4, let count = Int(f[2]), let massEach = Int(f[3]) else {
            return .corrupted(raw: line)
        }
        return .livestock(species: f[1], count: count, massEach: massEach)

    default:
        return .corrupted(raw: line)
    }
}

// 2.3 — Total mass of a ManifestEntry
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let m):
        return m
    case .container(_, let m):
        return m
    case .livestock(_, let count, let massEach):
        return count * massEach
    case .corrupted:
        return 0
    }
}

let parsedManifest: [ManifestEntry] = {
    var result: [ManifestEntry] = []
    for line in rawManifest {
        result.append(parseEntry(line))
    }
    return result
}()

var totalMass = 0
var corruptedCount = 0
for entry in parsedManifest {
    totalMass += mass(of: entry)
    if case .corrupted = entry { corruptedCount += 1 }
}

// Integrity code A = total mass of all valid entries
let A = totalMass
print("2. Total manifest mass: \(A) | Corrupted lines: \(corruptedCount)")
print("2. First parsed entry: \(parsedManifest[0])")


// MARK: Level 3 · Crew Snapshots

// 3.1 — CrewSnapshot as a struct (value type)
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    // Lowers oxygen but never below 0
    mutating func breathe(_ amount: Int) {
        oxygen = max(0, oxygen - amount)
    }

    // Changes deck
    mutating func move(to newDeck: Deck) {
        deck = newDeck
    }

    // Assigns a brand-new CrewSnapshot value to self (must use whole-self assignment)
    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    // Factory method: a fresh rookie on the bridge
    static func rookie(named name: String) -> CrewSnapshot {
        return CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

print("3.1 Rookie: \(CrewSnapshot.rookie(named: "Nurdos"))")
print("3.1 Snapshot from init: \(CrewSnapshot(name: "Test", deck: .lab, oxygen: 80))")

// 3.2 — Build the roster from crewData
var crewRoster: [CrewSnapshot] = []
for record in crewData {
    guard let deck = Deck(rawValue: record.deck) else {
        print("⚠️  Warning: unknown deck '\(record.deck)' for crew member '\(record.name)' — skipping.")
        continue
    }
    crewRoster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
}
print("3.2 Crew roster built: \(crewRoster.count) members")
for member in crewRoster { print("   → \(member.name) on \(member.deck.rawValue), O2: \(member.oxygen)") }

// 3.3 — Prove value semantics

// Demo 1: copy is independent of original
var original = crewRoster[0]
var copy = original
copy.breathe(20)
print("3.3 [Copy test] Original O2: \(original.oxygen), Copy O2 after breathe: \(copy.oxygen)")

// Demo 2: plain (non-inout) function parameter — original unaffected
func drainOxygen(_ snapshot: CrewSnapshot) {
    var local = snapshot
    local.breathe(50)
    print("3.3 [Param test] Inside function O2: \(local.oxygen)")
}
drainOxygen(original)
print("3.3 [Param test] After function call, original O2: \(original.oxygen)")


// MARK: Level 4 · The Teleport Pod

// 4.1 — TeleportPod as a final class (reference type)
final class TeleportPod {
    let id: String
    var chargeLevel: Int

    // Property observer logs every change
    var lastUsedBy: String = "none" {
        didSet { print("   Pod \(id): lastUsedBy changed from '\(oldValue)' to '\(lastUsedBy)'") }
    }

    // Tracks how many times this pod has fired
    private(set) var fireCount: Int = 0

    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
    }

    // Load charge into the pod
    func load(_ amount: Int) {
        chargeLevel += amount
        print("   Pod \(id) loaded +\(amount) → chargeLevel: \(chargeLevel)")
    }

    // Fire the pod: deducts charge, returns true on success
    @discardableResult
    func fire(crewMember: String) -> Bool {
        guard chargeLevel > 0 else {
            print("   Pod \(id): FIRE FAILED — no charge (member: \(crewMember))")
            return false
        }
        chargeLevel -= 10
        fireCount += 1
        lastUsedBy = crewMember
        print("   Pod \(id) fired for \(crewMember) → chargeLevel: \(chargeLevel)")
        return true
    }

    // Bonus: deinit prints the pod id
    deinit {
        print("   🛸 TeleportPod '\(id)' deallocated.")
    }
}

// 4.2 — Charge ledger: load + fire 3 times, then fire empty pod
print("4.2 Charge ledger:")
let pod = TeleportPod(id: "ALPHA-1", chargeLevel: 0)
pod.load(30)
pod.fire(crewMember: "Timur")
pod.load(20)
pod.fire(crewMember: "Dana")
pod.load(10)
pod.fire(crewMember: "Aigerim")
pod.fire(crewMember: "Nurlan")  // empty — should fail

// Integrity fragment C = charge level after full sequence
let C = pod.chargeLevel
print("4.2 Final chargeLevel (C): \(C)")
print("4.2 Fire count: \(pod.fireCount)")

// 4.3 — Prove reference semantics
let podRef1 = TeleportPod(id: "BETA-1", chargeLevel: 100)
let podRef2 = podRef1             // same object
podRef2.chargeLevel = 0
print("4.3 [Reference test] podRef1.chargeLevel: \(podRef1.chargeLevel), podRef2.chargeLevel: \(podRef2.chargeLevel) — they are the SAME object")

// Same experiment with a struct to contrast:
var snapRef1 = CrewSnapshot.rookie(named: "Timur")
var snapRef2 = snapRef1
snapRef2.breathe(30)
print("4.3 [Struct contrast] snapRef1.oxygen: \(snapRef1.oxygen), snapRef2.oxygen: \(snapRef2.oxygen) — they are DIFFERENT copies")


// MARK: Level 5 · Station Systems

// 5.1 — Station class containing all five property kinds
final class Station {

    // 1. Stored property — live crew roster
    var crew: [CrewSnapshot]

    // 2. Stored constant — the station name never changes
    let stationName: String

    // 3. Lazy property — only computed when first accessed (e.g., expensive DB lookup)
    lazy var emergencyProtocol: String = {
        print("   [lazy] Building emergency protocol string…")
        return "ALMA-7 Emergency Protocol v2: evacuate in priority order."
    }()

    // 4. Computed property — always reflects current state, no storage
    var criticalCrewCount: Int {
        var count = 0
        for member in crew {
            if member.oxygen < 20 { count += 1 }
        }
        return count
    }

    // 5. Property observer — clamps oxygenReserve between 0 and 100
    var oxygenReserve: Int = 100 {
        didSet {
            if oxygenReserve < 0   { oxygenReserve = 0 }
            if oxygenReserve > 100 { oxygenReserve = 100 }
            print("   Station oxygenReserve → \(oxygenReserve)%")
        }
    }

    init(name: String, crew: [CrewSnapshot]) {
        self.stationName = name
        self.crew = crew
    }

    // Type (static) method to create a default station
    static func defaultStation() -> Station {
        return Station(name: "ALMA-7", crew: [])
    }
}

let station = Station(name: "ALMA-7", crew: crewRoster)
print("5.1 Station: \(station.stationName), crew: \(station.crew.count), critical: \(station.criticalCrewCount)")
print("5.1 Emergency protocol: \(station.emergencyProtocol)")

// 5.2 — The clamp trap: test property observer with 130, -40, 55
print("5.2 Clamp sequence:")
station.oxygenReserve = 130   // should clamp to 100
station.oxygenReserve = -40   // should clamp to 0
station.oxygenReserve = 55    // normal value

// Integrity fragment B = oxygenReserve after the clamp sequence
let B = station.oxygenReserve
print("5.2 Final oxygenReserve (B): \(B)")


// MARK: Level 6 · Incident Reports

/*
// ─────────────────────────────────────────────────────────────────
// REPORT 1
// ─────────────────────────────────────────────────────────────────
var roster = crewRoster
for var member in roster {
    member.oxygen -= 10
}
print(roster[0].oxygen)   // author expected the crew to have lost oxygen

// EXPECTATION: The author expected `roster[0].oxygen` to be 10 less after the loop.
// WHAT HAPPENS: The loop iterates with `var member` — this creates a LOCAL COPY of each
//               element. Mutations to `member` inside the loop do NOT write back into
//               the array. `roster[0].oxygen` remains unchanged.
// LANGUAGE RULE: CrewSnapshot is a STRUCT (value type). `for var member in roster`
//               gives you an independent mutable copy, not a reference into the array.
// FIX:
var roster1 = crewRoster
for i in 0..<roster1.count {
    roster1[i].oxygen -= 10
}
print("Report 1 (fixed): \(roster1[0].oxygen)")   // ✅ now 10 less

// ─────────────────────────────────────────────────────────────────
// REPORT 2
// ─────────────────────────────────────────────────────────────────
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 0
print(podA.chargeLevel)   // author expected 100

// EXPECTATION: The author expected `podA` to be unaffected by the change to `podB`.
// WHAT HAPPENS: `podA.chargeLevel` prints 0, NOT 100. TeleportPod is a CLASS (reference
//               type). `podB = podA` copies the REFERENCE, not the object. Both variables
//               point to the exact same TeleportPod in memory.
// LANGUAGE RULE: Classes have reference semantics. Assignment copies the pointer.
// NOTE:  This code actually COMPILES AND RUNS — but produces the "wrong" result (0).
//        Because `pod` is a `let`, you cannot reassign the reference, but you CAN mutate
//        the object it points to.
// FIX: If you truly want an independent copy, give TeleportPod a copy mechanism:
let podC = TeleportPod(id: podA.id, chargeLevel: podA.chargeLevel)  // manual "copy"
podC.chargeLevel = 0
print("Report 2 (fixed): podA.chargeLevel = \(podA.chargeLevel), podC.chargeLevel = \(podC.chargeLevel)")  // ✅ 100, 0

// ─────────────────────────────────────────────────────────────────
// REPORT 3
// ─────────────────────────────────────────────────────────────────
struct Logbook {
    var entries: [String] = []
    func add(_ entry: String) {   // ← DOES NOT COMPILE if you call it on a `var`
        entries.append(entry)     //   error: cannot use mutating member on immutable value
    }
}

// EXPECTATION: The author expected `add` to append to the logbook's entries array.
// WHAT HAPPENS: This code does NOT compile. A plain func in a struct cannot mutate
//               stored properties — only a `mutating func` can.
// LANGUAGE RULE: Structs are value types. `self` inside a non-mutating method is
//               immutable. You must mark the method `mutating` to signal that a new
//               copy of `self` should be written back.
// FIX:
struct FixedLogbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}
var logbook = FixedLogbook()
logbook.add("Day 10 — transfer initiated")
logbook.add("Day 10 — transfer complete")
print("Report 3 (fixed): \(logbook.entries)")  // ✅

// ─────────────────────────────────────────────────────────────────
// REPORT 4
// ─────────────────────────────────────────────────────────────────
let snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40       // ← DOES NOT COMPILE
                           //   error: cannot assign to property: 'snapshot' is a 'let' constant

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10       // ← COMPILES FINE ✅

// EXPECTATION: The author expected that both `let` declarations would behave identically.
// WHAT ACTUALLY HAPPENS:
//   • `snapshot.oxygen = 40` is a COMPILER ERROR.
//   • `pod.chargeLevel = 10` compiles and runs successfully.
// LANGUAGE RULE — what `let` freezes:
//   • For a STRUCT (CrewSnapshot): `let` freezes the ENTIRE VALUE. Every stored property
//     inside it becomes immutable. You cannot change `oxygen`, `deck`, or `name`.
//   • For a CLASS (TeleportPod): `let` freezes the REFERENCE (the pointer). You cannot
//     make `pod` point to a different TeleportPod object, but you CAN mutate the object's
//     stored properties because the object itself lives on the heap and is not frozen.
// FIX for snapshot:
var mutableSnapshot = CrewSnapshot.rookie(named: "Dana")
mutableSnapshot.oxygen = 40
print("Report 4 (fixed): snapshot.oxygen = \(mutableSnapshot.oxygen)")  // ✅
*/


// MARK: Level 7 · Sealing the Black Box

final class FlightRecorder {

    // private: blocks access from outside this TYPE definition entirely
    private var entries: [String] = []

    // private: blocks external code from knowing how many entries exist directly
    private var isSealed: Bool = false

    // internal (default): accessible anywhere in the module; no keyword needed here
    // We mark it explicitly for clarity
    // Blocks: nothing within the module — but blocks other modules
    internal let recorderID: String

    init(id: String) {
        self.recorderID = id
    }

    // public-ish interface: record a new log entry unless sealed
    // internal: accessible anywhere in this file / module
    func record(_ entry: String) {
        guard !isSealed else {
            print("FlightRecorder \(recorderID): SEALED — cannot record '\(entry)'")
            return
        }
        entries.append(entry)
        print("FlightRecorder \(recorderID): logged → '\(entry)'")
    }

    // Seals the recorder permanently
    func seal() {
        isSealed = true
        print("FlightRecorder \(recorderID): recorder sealed.")
    }

    // fileprivate: blocks code from OTHER files, but allows free functions
    //              in THIS FILE to call it (e.g., auditTranscript)
    fileprivate func allEntries() -> [String] {
        return entries
    }
}

// A free function elsewhere in the file uses the fileprivate helper
func auditTranscript(of recorder: FlightRecorder) -> String {
    let lines = recorder.allEntries()   // ✅ fileprivate — accessible within the same file
    var result = "=== Audit: \(recorder.recorderID) (\(lines.count) entries) ===\n"
    for line in lines {
        result += "  • \(line)\n"
    }
    return result
}

let recorder = FlightRecorder(id: "BR-10")
recorder.record("Transfer initiated at 08:14")
recorder.record("Crew manifest: 4 members")
recorder.record("Cargo manifest: OK")
recorder.seal()
recorder.record("Post-seal attempt")   // should be blocked

print(auditTranscript(of: recorder))

// ── Attempt to break from outside the type: ──
// recorder.entries.append("Injected entry")
// ↑ error: 'entries' is inaccessible due to 'private' protection level
// recorder.isSealed = false
// ↑ error: 'isSealed' is inaccessible due to 'private' protection level


// MARK: Finale · Integrity Code

// D = number of valid crew members in roster (skipped invalid-deck members)
let D = crewRoster.count

let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("\nINTEGRITY CODE: \(integrityCode)")


// MARK: Bonus · Deinit, Reference Counting, and ===

// Bonus 1 & 2: deinit + do-block lifetime experiment
print("\n--- Bonus: deinit & reference counting ---")
var outerRef: TeleportPod?   // a second reference kept alive outside the block

do {
    let innerPod = TeleportPod(id: "GAMMA-1", chargeLevel: 50)
    outerRef = innerPod   // retain count = 2 (innerPod + outerRef)
    print("Inside do-block: innerPod chargeLevel = \(innerPod.chargeLevel)")
    // When do-block ends, `innerPod` (the local reference) is released.
    // retain count drops to 1 — deinit does NOT fire yet because outerRef still holds it.
}
print("After do-block: outerRef?.chargeLevel = \(String(describing: outerRef?.chargeLevel))")
// deinit fires HERE when outerRef is set to nil and retain count drops to 0:
outerRef = nil
// ↑ TeleportPod 'GAMMA-1' deallocated message will appear on the line above

// Bonus 3: === identity vs. equal-contents check
func comparePods(_ p1: TeleportPod, _ p2: TeleportPod) {
    if p1 === p2 {
        print("=== Same object in memory (identical reference)")
    } else {
        print("=== Different objects (may have equal content)")
    }
}

let bPod1 = TeleportPod(id: "D-1", chargeLevel: 50)
let bPod2 = bPod1                            // same reference
let bPod3 = TeleportPod(id: "D-1", chargeLevel: 50)  // equal content, different object

print("Bonus ===: bPod1 vs bPod2 (same ref):", terminator: " ")
comparePods(bPod1, bPod2)
print("Bonus ===: bPod1 vs bPod3 (diff ref):", terminator: " ")
comparePods(bPod1, bPod3)

// Why === cannot be used on CrewSnapshot (a struct):
// === is the identity operator for ARC-managed reference types (classes). Structs live on
// the stack (or inline in other types); they have no stable identity address. Two struct
// values that look the same may live at two completely unrelated memory locations, and
// Swift offers no language-level notion of struct identity — only value equality (==),
// which you implement via Equatable.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free while TeleportPod did not?

    Structs automatically receive a MEMBERWISE INITIALIZER synthesized by the compiler,
    which accepts one argument per stored property in declaration order. Classes do NOT
    get this for free — you must write your own designated initializer. This is because
    class inheritance makes automatic synthesis unsafe: the compiler cannot know which
    properties a subclass might add.

    struct CrewSnapshot -> init(name:deck:oxygen:) generated automatically ✅
    class TeleportPod   -> you must write init(id:chargeLevel:) yourself ✅


 2. What does `mutating` do to self, and why do classes never need it?

    For a struct method, `self` is normally a constant (immutable) copy. `mutating`
    tells the compiler to treat `self` as an `inout` parameter: at the end of the method
    a new copy of `self` is written back to the original storage location. This is how
    structs can appear to modify themselves while still being value types.

    Classes never need `mutating` because a class instance is always referenced through a
    pointer. Methods receive that pointer (not a copy), so they can freely mutate
    properties on the heap-allocated object without any copy-back mechanism.


 3. In Report 4 both values are `let`. What exactly does `let` freeze for a struct and
    for a class?

    • Struct (CrewSnapshot): `let` makes the ENTIRE VALUE immutable. Every bit of the
      struct, including all stored properties, is frozen in place. You cannot write to
      any property. Error: "cannot assign to property: 'snapshot' is a 'let' constant."

    • Class (TeleportPod): `let` freezes the REFERENCE (the pointer). You cannot make
      `pod` point at a different TeleportPod object. But the object on the heap is NOT
      frozen — you can still mutate its stored properties freely (e.g., pod.chargeLevel = 10).


 4. Why must a lazy property be var? When does lazy change behaviour, not just performance?

    A `lazy` property is not set at init time; it is computed on first access and then
    stored. This means its value is mutated (from "not yet computed" to "computed") at that
    first access — mutation is only allowed on `var`. If it were `let`, the compiler would
    have no place to store the cached result.

    Behaviour change (not just performance):
    If the lazy closure captures state that later changes before first access, the lazy
    version captures the LATER state, while an eager property would have captured the
    EARLIER state. Example:

      var counter = 0
      lazy var snapshot = "Count is \(counter)"
      counter = 99
      print(snapshot) // lazy → "Count is 99"  (captured at access time)
                      // eager → "Count is 0"  (captured at init time)


 5. private vs fileprivate: where in your FlightRecorder would private be too strict?

    `allEntries()` is marked `fileprivate`. If it were `private`, the free function
    `auditTranscript(of:)` — which lives OUTSIDE the FlightRecorder type body but in
    the SAME FILE — would not be able to call it, breaking the auditing feature.
    `fileprivate` is exactly the right level: it blocks all access from other files while
    still allowing same-file free functions to use it.


 Bonus. On which line does deinit fire, and why can't === be used on CrewSnapshot?

    deinit fires on the line `outerRef = nil`. Inside the `do` block, both `innerPod`
    (the local constant) and `outerRef` hold a reference. When the block ends, `innerPod`
    is released and the retain count drops from 2 to 1 — deinit does NOT fire. Only when
    `outerRef = nil` sets the last reference to nil does the count reach 0 and ARC
    immediately calls deinit.

    === cannot be used on CrewSnapshot because === is defined only for ARC reference types
    (classes). Structs are value types; they have no stable memory identity. Two struct
    values can be bitwise-identical yet stored at completely unrelated addresses, and Swift
    makes no guarantee about where a struct lives. There is no pointer to compare.
    Struct equality is expressed through the Equatable protocol (==), not identity (===).
*/
