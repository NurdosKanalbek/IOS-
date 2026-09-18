// === Easy Tasks ===

// 1. Array Creation and Access:
let fruits: [String] = ["Apple", "Banana", "Cherry", "Mango", "Orange"]
print("1. Third fruit: \(fruits[2])")

// 2. Set Creation and Manipulation:
var favoriteNumbers: Set<Int> = [7, 10, 42]
favoriteNumbers.insert(99)
print("2. Updated favorite numbers set: \(favoriteNumbers)")

// 3. Dictionary Creation and Access:
let programmingLanguages: [String: Int] = ["Swift": 2014, "Python": 1991, "Java": 1995]
// We can use the force unwrap (!) here because we know the key "Swift" definitely exists in the dictionary.
print("3. Release year of Swift: \(programmingLanguages["Swift"]!)")

// 4. Array Element Update:
var colors: [String] = ["Red", "Green", "Blue", "Yellow"]
colors[1] = "Purple"
print("4. Updated colors array: \(colors)")


// === Medium Tasks ===

// 1. Set Intersection:
let set1: Set<Int> = [1, 2, 3, 4]
let set2: Set<Int> = [3, 4, 5, 6]
let intersectionSet = set1.intersection(set2)
print("1. Intersection of sets: \(intersectionSet)")

// 2. Dictionary Update:
var studentScores: [String: Int] = ["Alice": 85, "Bob": 92, "Charlie": 78]
studentScores.updateValue(95, forKey: "Bob") // or studentScores["Bob"] = 95
print("2. Updated student scores: \(studentScores)")

// 3. Array Merge:
let array1: [String] = ["apple", "banana"]
let array2: [String] = ["cherry", "date"]
let mergedArray = array1 + array2
print("3. Merged array: \(mergedArray)")


// === Hard Tasks ===

// 1. Dictionary Key Addition:
var countryPopulations: [String: Int] = ["Kazakhstan": 20_000_000, "Japan": 125_000_000]
countryPopulations["Canada"] = 38_000_000
print("1. Updated country populations: \(countryPopulations)")

// 2. Set Union and Subtract:
let animalSet1: Set<String> = ["cat", "dog"]
let animalSet2: Set<String> = ["dog", "mouse"]
let unionSet = animalSet1.union(animalSet2)
let finalSet = unionSet.subtracting(animalSet2)
print("2. Final set after union and subtraction: \(finalSet)")

// 3. Nested Collection:
let studentGrades: [String: [Int]] = [
    "Nurdos": [88, 92, 85],
    "Emma": [95, 98, 100]
]
let nurdosSecondGrade = studentGrades["Nurdos"]![1]
print("3. Nurdos's second grade: \(nurdosSecondGrade)")
