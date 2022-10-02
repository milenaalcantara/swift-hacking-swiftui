//
//  ContentView.swift
//  WordScramble
//
//  Created by Milena Lima de Alcântara on 02/10/22.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var points = 0
    
    var body: some View {
        NavigationView {
           List {
               Text("Points: \(points)")
               
               Section {
                   TextField("Enter your word", text: $newWord)
                       .textInputAutocapitalization(.never)
               }

               Section {
                   ForEach(usedWords, id: \.self) { word in
                       HStack {
                           Image(systemName: "\(word.count).circle")
                           Text(word)
                       }
                   }
               }
           }
           .navigationTitle(rootWord)
           .onSubmit(addNewWord)
           .onAppear(perform: startGame)
           .toolbar {
               Button("New word", action: startGame)
           }
           .alert(errorTitle, isPresented: $showingError) {
               Button("OK", role: .cancel) { }
           } message: {
               Text(errorMessage)
           }
           
       }
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func isMinimalWord(word: String) -> Bool{
        if word.count < 4 {
            return false
        }
        return true
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func addNewWord() {
        var isValid = 4
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // exit if the remaining string is empty
        guard answer.count > 0 else { return }

        // extra validation to come
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            isValid -= 1
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            isValid -= 1
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            isValid -= 1
            return
        }
        
        guard isMinimalWord(word: answer) else {
            wordError(title: "Word not possible", message: "Words must be longer than 3 letters!")
            isValid -= 1
            return
        }

        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
        
        if isValid == 4 {
            points += answer.count
        }
    }
    
    func startGame() {
        points = 0
        // 1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")

                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"

                // If we are here everything has worked, so we can exit
                return
            }
        }

        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
