// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let (sensor, valStr) = splitOnce(raw, by: ":"),
          !sensor.isEmpty,
          let value = Int(valStr),
          value >= 0 || sensor == "TEMP" else {
        return nil
    }
    return (sensor, value)
}

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalid = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalid += 1
        }
    }
    return (valid, invalid)
}

let parsed = parseLog(rawLog)
let A = parsed.invalidCount


// MARK: Level 2 · Analysis

// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }
    var minVal = first
    var maxVal = first
    var sum = 0
    for val in values {
        if val < minVal { minVal = val }
        if val > maxVal { maxVal = val }
        sum += val
    }
    return (minVal, maxVal, Double(sum) / Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

let o2Readings = select(parsed.valid) { $0.sensor == "O2" }
let o2Values = values(of: o2Readings)
let B = Int(stats(of: o2Values)?.average ?? 0)

// 2.3 · The Closure Ladder (5 sorts, then compare results in code)
let sorted1 = parsed.valid.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})
let sorted2 = parsed.valid.sorted(by: { a, b in
    return a.value > b.value
})
let sorted3 = parsed.valid.sorted(by: { a, b in a.value > b.value })
let sorted4 = parsed.valid.sorted(by: { $0.value > $1.value })
let sorted5 = parsed.valid.sorted { $0.value > $1.value }

func areEqual(_ a: [Reading], _ b: [Reading]) -> Bool {
    guard a.count == b.count else { return false }
    for i in 0..<a.count {
        if a[i].sensor != b[i].sensor || a[i].value != b[i].value { return false }
    }
    return true
}
let allMatch = areEqual(sorted1, sorted2) && areEqual(sorted2, sorted3) && areEqual(sorted3, sorted4) && areEqual(sorted4, sorted5)
print("Do all 5 sorts match? \(allMatch)")


// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int { t + 5 }
func coolDown(_ t: Int) -> Int { t - 3 }
func hold(_ t: Int) -> Int { t }

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 { return heatUp }
    if temp > 24 { return coolDown }
    return hold
}

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temp = start
    var steps = 0
    while steps < maxSteps && (temp < 18 || temp > 24) {
        let protocolFunc = chooseProtocol(for: temp)
        temp = protocolFunc(temp)
        steps += 1
    }
    return (temp, steps, temp >= 18 && temp <= 24)
}

let tempReadings = select(parsed.valid) { $0.sensor == "TEMP" }
let tempMin = stats(of: values(of: tempReadings))?.min ?? 0
let C = runUntilStable(from: tempMin).steps


// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

// 4.2
func status(of member: CrewMember) -> String {
    guard let module = member.module else {
        return "\(member.name): no data (open space)"
    }
    let levelString = oxygenLevel(of: member).map { "\($0)%" } ?? "no data"
    let statusSuffix = (oxygenLevel(of: member) ?? 100) < 20 ? " CRITICAL" : " OK"
    let finalSuffix = levelString == "no data" ? " (\(module.name))" : statusSuffix
    return "\(member.name): \(levelString)\(finalSuffix)"
}
for member in crew { print(status(of: member)) }

// 4.3
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    let availableToTake = min(source, amount)
    let availableSpace = max(0, 100 - target)
    let actualTransfer = min(availableToTake, availableSpace)
    
    source -= actualTransfer
    target += actualTransfer
    return actualTransfer
}

if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
}
let D = hab.oxygenTank?.level ?? 0

// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var validMembers: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        validMembers.append(member)
    }
    validMembers.sort { $0.priority < $1.priority }
    
    var result: [String] = []
    for m in validMembers { result.append(m.name) }
    return result
}
print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))


// MARK: Level 5 · The Saboteur's Logbook

/*
1. Find all problems:
   - Problem 1: `member.module!` crashes if the member has no module (e.g. Nurlan is in open space).
   - Problem 2: `oxygenTank!` crashes if the module exists but doesn't have an oxygen tank (e.g. Dock).
   - Problem 3: `oxygenLevel(of: member)!` crashes if the member's oxygen level evaluates to nil.
   - Problem 4: `result!` in `firstCritical` crashes if the crew array is empty or if no one is in critical condition.
   - Problem 5 (Logic Bug): `firstCritical` doesn't stop iterating when it finds the first critical member; it overwrites `result` and actually returns the LAST critical member found.

2. Rewrite both functions without `!`. `firstCritical` must return `String?`.
*/

func reportOxygen(for member: CrewMember) -> String {
    guard let module = member.module else { return "\(member.name): no module" }
    guard let tank = module.oxygenTank else { return "\(member.name): no tank" }
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}

// 4. Test that proves the logic bug is fixed.
let testCrew = [
    CrewMember(name: "Victim1", role: "A", priority: 1, module: Module(name: "M1", oxygenTank: Tank(level: 10))),
    CrewMember(name: "Victim2", role: "B", priority: 2, module: Module(name: "M2", oxygenTank: Tank(level: 15)))
]
print("First critical should be Victim1: \(firstCritical(in: testCrew) ?? "None")")


// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("\nLAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var count = 0
    return { level in
        if level < threshold {
            count += 1
            print("Alarm #\(count)")
            return true
        }
        return false
    }
}
let alarm = makeAlarm(threshold: 20)
_ = alarm(12)
_ = alarm(40)
_ = alarm(5)

// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
    `guard let` requires an early exit (like `return` or `break`) if the condition is false, and importantly, it binds the unwrapped variable to the *outer* scope, making it available for the rest of the function. `if let` only binds the variable inside its own curly braces. If you have many optional variables to unwrap sequentially, using `if let` causes a deeply indented "pyramid of doom", whereas `guard let` keeps the code flat and readable.

 2. Why can't you pass [Int] to stats(_ values: Int...)?
    Variadic parameters (`Int...`) are syntactic sugar that allows passing a comma-separated list of individual values (e.g., `stats(1, 2, 3)`), which the compiler automatically bundles into an array. However, Swift's compiler does not allow you to directly pass an already-constructed array `[Int]` into a variadic parameter; they are strictly for comma-separated inputs at the call site.

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?
    It violates Swift's memory safety rules (specifically, the Law of Exclusivity). You cannot have two simultaneous overlapping accesses to the same memory location (like passing `&x` to two `inout` parameters) if at least one of them is a write. This prevents unpredictable bugs where the variable is mutated in overlapping operations causing undefined state.

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
    The function `oxygenLevel(of:)` returns an `Int?` (an optional Integer), whereas `"no data"` is a `String`. The nil-coalescing operator `??` requires both the left side and the right side default value to be of compatible types. You cannot provide a String default fallback for an Int variable.

 5. Full type of chooseProtocol and how to read it:
    The full type is `(Int) -> ((Int) -> Int)`.
    You read it as: A function that takes an `Int` as its parameter, and returns *another function*. That returned function itself takes an `Int` parameter and returns an `Int`.

 Bonus. Where does the alarm counter live after makeAlarm returns?
    The `count` variable physically lives on the heap. Even though it is originally declared as a local variable inside `makeAlarm` (which normally lives and dies on the stack), the closure returned by the function *captures* it. Swift recognizes this capture and automatically promotes/moves the variable to the heap, extending its lifetime so that the closure can continue to read and write to it long after `makeAlarm` has returned.
*/
