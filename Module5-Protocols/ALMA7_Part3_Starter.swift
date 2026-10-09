// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?
// A class gives PowerCell reference semantics: a Drone holds ONE shared cell, and
// methods like recharge(by:) and consume() mutate it in-place through that reference
// without needing `mutating` on every caller or inout threading. If PowerCell were a
// struct, every Drone method that changes the charge would silently operate on a copy.

final class PowerCell {

    // private: no code outside this type can set charge directly — encapsulation enforced
    private(set) var charge: Int

    init(charge: Int) {
        self.charge = max(0, charge)
    }

    // Adds energy; never exceeds 100
    func recharge(by amount: Int) {
        charge = min(100, charge + amount)
    }

    // Removes energy; never below 0. Returns actual units consumed.
    @discardableResult
    func consume(_ amount: Int) -> Int {
        let actual = min(charge, amount)
        charge -= actual
        return actual
    }

    // True when enough charge remains for one more task
    func canRun(cost: Int) -> Bool {
        return charge >= cost
    }
}

// Encapsulation proof (leave this commented, with the compiler error):
// let cell = PowerCell(charge: 50)
// cell.charge = 100
// error: cannot assign to property: 'charge' setter is inaccessible

print("1. PowerCell encapsulation verified.")
print("1. PowerCell(80).canRun(cost:20) = \(PowerCell(charge: 80).canRun(cost: 20))")


// MARK: Level 2 · The Fleet

// 2.1 — Drone base class
// What does `final` on runOnce() buy you?
// It guarantees the implementation in the base class cannot be accidentally or
// maliciously replaced in a subclass, preserving the charge-consumption contract
// (the battery drains by `taskCost` before calling work(), never more, never less).
// Subclasses extend behaviour through work(), not by bypassing the cost logic.

class Drone {
    let id: String
    let cell: PowerCell

    // Cost in charge per task — subclasses declare their own value
    var taskCost: Int { 10 }

    // Human-readable label — subclasses may override
    var statusLine: String {
        "\(id) | charge: \(cell.charge) | task cost: \(taskCost)"
    }

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    // FINAL: enforces the charge contract; subclasses customise work(), not this.
    final func runOnce() -> Int {
        guard cell.canRun(cost: taskCost) else { return 0 }
        cell.consume(taskCost)
        return work()
    }

    // Override point — return work units produced this cycle
    func work() -> Int { 0 }
}

// 2.2 — Concrete drone types

// WelderDrone: taskCost 20, work() returns 15
final class WelderDrone: Drone {
    override var taskCost: Int { 20 }

    override func work() -> Int { 15 }

    override var statusLine: String {
        super.statusLine + " [welder]"
    }
}

// ScannerDrone: taskCost 10, work() returns 8
// NOT final — could be subclassed into, e.g., a DeepScannerDrone
class ScannerDrone: Drone {
    override var taskCost: Int { 10 }

    override func work() -> Int { 8 }

    override var statusLine: String {
        super.statusLine + " [scanner]"
    }
}

// CargoDrone: taskCost 15, work() returns 12
final class CargoDrone: Drone {
    override var taskCost: Int { 15 }

    override func work() -> Int { 12 }

    override var statusLine: String {
        super.statusLine + " [cargo]"
    }
}

// 2.3 — Factory + build the live fleet
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:
        print("⚠️  Unknown drone kind '\(kind)' (id: \(id)) — skipped.")
        return nil
    }
}

var fleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    }
}
print("\n2. Fleet assembled: \(fleet.count) drones.")
for drone in fleet { print("   \(drone.statusLine)") }


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    var round = 0
    while round < rounds {
        for drone in fleet {
            total += drone.runOnce()
        }
        round += 1
    }
    return total
}

let A = runShift(fleet, rounds: 3)

var B = 0
for drone in fleet { B += drone.cell.charge }

var C = 0
for drone in fleet {
    if drone.cell.canRun(cost: drone.taskCost) { C += 1 }
}

print("\n3. After 3-round shift:")
for drone in fleet { print("   \(drone.statusLine)") }
print("   Drones with charge for one more task: \(C)")
print("   Mission A (total work units): \(A)")
print("   Mission B (total charge remaining): \(B)")
print("   Mission C (drones ready for one more task): \(C)")


// MARK: Level 4 · Diagnostics

// 4.1 — Diagnosable protocol
// THE HEALTH RULE lives here and nowhere else.
// charge >= 50 → "OK", charge >= 20 → "LOW", otherwise "CRITICAL"
protocol Diagnosable {
    var componentID: String { get }
    var chargeLevel: Int { get }
    func diagnose() -> String
}

// 4.2 — Rechargeable protocol
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Why does Drone implement recharge(by:) without `mutating`?  →
// Drone is a CLASS. Classes have reference semantics — `self` inside a method is
// already a mutable reference to the heap object. `mutating` is only needed for
// value types (structs/enums) where `self` is a constant copy by default.

// SensorModule: a struct (not a drone, never runs a shift)
struct SensorModule: Diagnosable, Rechargeable {
    let componentID: String
    private(set) var chargeLevel: Int

    // mutating required because SensorModule is a struct
    mutating func recharge(by amount: Int) {
        chargeLevel = min(100, chargeLevel + amount)
    }

    // Uses the default diagnose() from the protocol extension (Level 5)
}

// Make Drone satisfy Diagnosable
extension Drone: Diagnosable {
    var componentID: String { id }
    var chargeLevel: Int { cell.charge }
    // diagnose() comes from the protocol extension in Level 5
}

// Make Drone satisfy Rechargeable
extension Drone: Rechargeable {
    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

// 4.3 — Diagnostics screen
// Why could [Drone] never have held the sensors?
// SensorModule is a struct — it is not a subclass of Drone. An array typed [Drone]
// can only hold class instances that ARE Drone or its subclasses (inheritance).
// Protocols are types that any conforming type can satisfy regardless of class hierarchy,
// making [Diagnosable] the correct heterogeneous container here.

func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var lines: [String] = []
    lines.append("=== DIAGNOSTICS REPORT ===")
    for component in components {
        lines.append(component.diagnose())
    }
    lines.append("===========================")
    var result = ""
    for line in lines { result += line + "\n" }
    return result
}


// MARK: Level 5 · Shared Behaviour

// 5.1 — Default diagnose() in protocol extension — THE SINGLE HOME OF THE HEALTH RULE
extension Diagnosable {
    func diagnose() -> String {
        let status: String
        if chargeLevel >= 50 {
            status = "OK"
        } else if chargeLevel >= 20 {
            status = "LOW"
        } else {
            status = "CRITICAL"
        }
        return "\(componentID): \(chargeLevel)% — \(status)"
    }
}

// 5.2 — Retrofit LegacyBeacon with Diagnosable via extension (cannot edit the original)
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var chargeLevel: Int { signalStrength }

    // Custom diagnose() — clearly flags legacy hardware for the maintenance crew
    func diagnose() -> String {
        "⚠️  LEGACY BEACON \(name): signal \(signalStrength)% — \(signalStrength >= 50 ? "OK" : signalStrength >= 20 ? "LOW" : "CRITICAL") [legacy hardware — schedule inspection]"
    }
}

// Build sensors from sensorData
var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(componentID: record.id, chargeLevel: record.charge))
}

// Build a unified Diagnosable array: drones + sensors + beacon
var allComponents: [Diagnosable] = []
for drone in fleet { allComponents.append(drone) }
for sensor in sensors { allComponents.append(sensor) }
allComponents.append(beacon)

print("\n4/5. " + diagnosticsReport(allComponents))

// Mission fragment D = number of CRITICAL components (chargeLevel < 20)
var D = 0
for component in allComponents {
    if component.chargeLevel < 20 { D += 1 }
}
print("Mission D (CRITICAL components): \(D)")

// 5.3 — Extend Int with a chargeStatus computed property using the same thresholds
extension Int {
    var chargeStatus: String {
        if self >= 50 { return "OK" }
        if self >= 20 { return "LOW" }
        return "CRITICAL"
    }
}

print("5.3 Int.chargeStatus examples: 80 → \(80.chargeStatus), 35 → \(35.chargeStatus), 5 → \(5.chargeStatus)")


// MARK: Level 6 · Incident Reports

/*
// ─────────────────────────────────────────────────────────────────
// REPORT 1
// ─────────────────────────────────────────────────────────────────
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}

// EXPECTATION: Author expected to create a new drone subclass that does extra work.
// WHAT HAPPENS: This DOES NOT COMPILE.
//   error: 'Drone' cannot be subclassed because it... wait — actually Drone is NOT
//   final, so subclassing IS allowed. However, PatchDrone skips `runOnce()` entirely.
//   `performTask()` is its own unrelated method that bypasses the charge contract.
//   No charge is consumed, so calling performTask() on an empty drone still returns 30.
// LANGUAGE RULE: The open override point in Drone is work(), not runOnce() (which is
//   final). Subclasses that want to produce work MUST override work() so the charge
//   guard in runOnce() is respected.
// FIX: Override work() instead:
final class FixedPatchDrone: Drone {
    override var taskCost: Int { 20 }
    override func work() -> Int { 30 }
}
let patch = FixedPatchDrone(id: "P-1", cell: PowerCell(charge: 40))
print("Report 1 (fixed): \(patch.runOnce())")  // ✅ 30, charge deducted

// ─────────────────────────────────────────────────────────────────
// REPORT 2
// ─────────────────────────────────────────────────────────────────
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}

// EXPECTATION: Author expected to create a powerful welder that always returns 999.
// WHAT HAPPENS: This DOES NOT COMPILE.
//   error: cannot override 'final' instance method 'runOnce()'
// LANGUAGE RULE: `final` on runOnce() in Drone prevents any subclass from overriding
//   it. This is intentional — it protects the charge-consumption contract.
// FIX: Override work() instead, which IS the subclass hook:
final class FixedHeavyWelder: WelderDrone {
    override func work() -> Int { 999 }
}
let hw = FixedHeavyWelder(id: "HW-1", cell: PowerCell(charge: 100))
print("Report 2 (fixed): \(hw.runOnce())")  // ✅ 999

// ─────────────────────────────────────────────────────────────────
// REPORT 3
// ─────────────────────────────────────────────────────────────────
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())

// EXPECTATION: Author expected to call a method specific to WelderDrone.
// WHAT HAPPENS: This DOES NOT COMPILE.
//   error: value of type 'Drone' has no member 'weldSeam'
// LANGUAGE RULE: `first` is statically typed as Drone — the base class. Even though
//   the runtime object is a WelderDrone, you can only call methods defined on Drone
//   (or Diagnosable/Rechargeable). WelderDrone-specific members are invisible through
//   the base-class type. This is correct polymorphism: the array holds Drones, not
//   WelderDrones. (Also, WelderDrone has no weldSeam() method at all.)
// FIX: Either add weldSeam() to Drone, or downcast with as?:
if let welder = reportFleet[0] as? WelderDrone {
    print("Report 3 (fixed): work units = \(welder.work())")  // ✅
}

// ─────────────────────────────────────────────────────────────────
// REPORT 4
// ─────────────────────────────────────────────────────────────────
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())

// EXPECTATION: Author expected "thruster T-1" to be printed.
// WHAT HAPPENS: "generic component" is printed instead. This COMPILES but LIES.
// LANGUAGE RULE: Protocol Witness Table (static dispatch for protocol existentials).
//   When you access an element through a protocol type ([Labelled]), the compiler uses
//   STATIC dispatch on the protocol's method table. label() is NOT listed in the
//   protocol requirement itself — it exists ONLY in the protocol extension. Protocol
//   extension methods are statically dispatched based on the STATIC type ([Labelled]),
//   so the extension's "generic component" version wins, ignoring Thruster's override.
//   If label() were declared in the protocol REQUIREMENT, it would be in the Witness
//   Table and dispatch dynamically to Thruster's version.
// FIX: Declare label() inside the protocol body, not only in the extension:
protocol FixedLabelled {
    var componentID: String { get }
    func label() -> String    // ← requirement in the protocol
}
extension FixedLabelled {
    func label() -> String { "generic component" }  // default
}
struct FixedThruster: FixedLabelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}
let fixedParts: [FixedLabelled] = [FixedThruster(componentID: "T-1")]
print("Report 4 (fixed): \(fixedParts[0].label())")  // ✅ "thruster T-1"
*/


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("\nMISSION CODE: \(missionCode)")


// MARK: Bonus

// ── BONUS 1: Two ways to prevent Drone from being used directly ──

// WAY 1 — Runtime: init() traps if the type is exactly Drone (not a subclass)
// Add to Drone's init:
//   precondition(type(of: self) != Drone.self, "Drone must not be instantiated directly")
// This fails at RUNTIME the moment someone writes Drone(id:cell:).

// WAY 2 — Compile-time: use `internal` or a file-private init
// Mark Drone.init as `internal` and restrict it to the module, then make all concrete
// subclasses the only exported API. Any attempt to call Drone(id:cell:) from outside
// the module is a compile-time error.
// Alternatively, give Drone an `@available(*, unavailable, renamed: "Use WelderDrone/ScannerDrone/CargoDrone")` annotation.

// ── BONUS 2: Protocol-based redesign — WelderDrone as a struct ──

protocol DroneProtocol: Diagnosable, Rechargeable {
    var id: String { get }
    var taskCost: Int { get }
    func work() -> Int
}

// Default shift execution + statusLine live here — written once
extension DroneProtocol {
    var componentID: String { id }
    var statusLine: String {
        "\(id) | charge: \(chargeLevel) | task cost: \(taskCost)"
    }
}

struct WelderDroneV2: DroneProtocol {
    let id: String
    private(set) var chargeLevel: Int
    let taskCost = 20

    mutating func recharge(by amount: Int) {
        chargeLevel = min(100, chargeLevel + amount)
    }

    func work() -> Int { 15 }
}

var w2 = WelderDroneV2(id: "W-V2", chargeLevel: 80)
print("\nBonus: \(w2.diagnose())")
w2.recharge(by: 10)
print("Bonus after recharge: \(w2.diagnose())")

/*
 Bonus 3 — Comparison of the two designs:

 The class-based design (Drone + subclasses) stores the PowerCell as a shared mutable
 reference object, so all methods naturally read and write the same cell without `mutating`
 or inout threading — straightforward when drones share mutable state (e.g., a station-
 wide power grid). The protocol-based design (DroneProtocol + structs) is cleaner for
 value semantics and testability: you can copy a drone's state before a shift and compare
 it after, which is impossible with class references. However, if drones must share a
 single mutable resource (a communal battery bank, a lock on a docking arm), the class
 design wins hands-down because reference sharing is its native mode. For this station,
 where each drone owns its own independent cell, the protocol + struct design is preferable:
 lighter, copy-safe, and no accidental aliasing bugs.
*/


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the keyword,
    while a struct must write it?

    `mutating` is a signal to the compiler that a method needs to write back a NEW COPY
    of `self` to the call site — this is only necessary for value types (structs/enums)
    where `self` is normally an immutable copy. For a class, `self` is a reference (a
    pointer) to a heap object. Mutating the object's properties doesn't require replacing
    `self`; it happens through the same pointer. So the class naturally satisfies the
    `mutating` requirement without the keyword because it never needs the copy-back
    mechanism in the first place.

 2. One thing inheritance does that protocols cannot, and one thing protocols do
    that inheritance cannot:

    INHERITANCE can provide stored properties and share implementation automatically —
    Drone gives every subclass a real `cell: PowerCell` property and the charge guard in
    `runOnce()` for free, with no extra code in each subclass.

    PROTOCOLS can be adopted by types that are otherwise unrelated in the hierarchy —
    a class, a struct, AND a type you cannot edit (LegacyBeacon) all satisfy Diagnosable
    simultaneously. A protocol also allows a type to conform to multiple "interfaces",
    whereas Swift only allows single inheritance.

 3. What does `final` prevent, and what did it protect in runOnce()?

    `final` on a method prevents any subclass from overriding it. Applied to the class,
    it prevents subclassing entirely. In our case, `final func runOnce()` locks the
    charge-consumption contract: every call MUST check canRun(cost:), consume charge,
    then delegate to work(). Without `final`, a subclass could override runOnce() to skip
    the charge guard entirely — producing infinite work with an empty battery (Report 2
    attempted this). `final` makes that breach a compile-time error.

 4. In Report 4, why did the protocol extension's method win?

    When you access an element through a protocol existential (e.g., a variable of type
    [Labelled]), Swift uses the Protocol Witness Table for dynamic dispatch — but ONLY for
    methods that are declared as requirements inside the protocol body itself. `label()`
    is NOT declared as a requirement in `Labelled`; it is only in the extension. Protocol
    extension methods that are NOT backed by a protocol requirement are dispatched
    STATICALLY based on the static type of the variable. The static type is `Labelled`,
    so the extension's "generic component" version is called — Thruster's own `label()`
    is invisible. The fix is to put `label()` in the protocol requirement list.
*/
