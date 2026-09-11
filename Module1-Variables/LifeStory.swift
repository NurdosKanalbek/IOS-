// Step 1: Declare Variables for Personal Information
let firstName: String = "Nurdos"
let lastName: String = "Kanalbek"
let birthYear: Int = 2006

// Bonus Challenge: Create a constant currentYear and calculate age
let currentYear: Int = 2026
let age: Int = currentYear - birthYear 

let isStudent: Bool = true
let height: Double = 1.75
// Additional details
let hometown: String = "Almaty"
let 🌟favoriteEmoji: String = "⚽️" // Bonus: emoji in variable name

// Step 2: Create Variables for Your Hobbies and Interests
let hobby: String = "football"
let numberOfHobbies: Int = 3
let favoriteNumber: Int = 7
let isHobbyCreative: Bool = false
// Additional details
let favoriteSeason: String = "Summer ☀️" // Bonus: emoji as value

// Bonus Task: Additional variable for futureGoals and emoji usage
let 🎯futureGoals: String = "become a professional iOS developer"

// Step 3: Create a Summary of Your Life Story
let lifeStory: String = """
My name is \(firstName) \(lastName). I am \(age) years old, born in \(birthYear) and originally from \(hometown) \(🌟favoriteEmoji). \
I am \(isStudent ? "currently" : "not") a student. I stand at \(height) meters tall. \
I enjoy \(hobby), which is \(isHobbyCreative ? "a creative" : "not a creative") hobby. \
I have \(numberOfHobbies) hobbies in total, my favorite season is \(favoriteSeason), and my favorite number is \(favoriteNumber). \
In the future, I want to \(🎯futureGoals).
"""

// Step 4: Print Your Life Story
print(lifeStory)
