//
//  Vocabs.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 25/08/2023.
//

import Foundation
import FirebaseStorage

fileprivate func getVocabMetadataPath() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("vocab_metadata.json")
}

// Singleton class that deals with loading vocabs from disk and providing cached access to all loaded vocabs
let vocabs = Vocabs()

class Vocabs {
    // languageFrom -> languageTo -> Vocab, like hi -> en -> Vocab
    // nil when we checked the file and it was not there
    // no entry when we haven't checked
    var vocabs: [String: [String: Vocab?]] = [:]
    
    func getVocab(languageFrom: String, languageTo: String) -> Vocab? {
        if let dic = vocabs[languageFrom] {
            if let vocab = dic[languageTo] {
                return vocab
            }
        }
        let vocab = Vocab.loadV2(languageFrom: languageFrom, languageTo: languageTo)
        if vocabs[languageFrom] == nil {
            vocabs[languageFrom] = [:]
        }
        vocabs[languageFrom]![languageTo] = vocab
        return vocab
    }
    
    func updateVocab(languageFrom: String, languageTo: String) {
        let vocab = Vocab.loadV2(languageFrom: languageFrom, languageTo: languageTo)
        if vocabs[languageFrom] == nil {
            vocabs[languageFrom] = [:]
        }
        vocabs[languageFrom]![languageTo] = vocab
    }
}

struct VocabMetadata: Codable {
    var languageTo: String
    var languageFrom: String
    var version: Int
    var path: String
}

var vocabUpdater = VocabUpdater.load()

// Singleton class that deals with Firebase Storage vocab updates only.
class VocabUpdater: Codable {
    var vocabVersions: [VocabMetadata] = []
    
    static func load() -> VocabUpdater {
        do {
            if let jsonData = try? Data(contentsOf: getVocabMetadataPath()) {
                let decoder = JSONDecoder()
                let decks = try decoder.decode(VocabUpdater.self, from: jsonData)
                return decks
            }
        } catch {
            print("Failed loading vocab updater... Initialising from scratch")
        }
        return VocabUpdater()
    }
    
    func save() {
        print("saving vocabs metadata!", Date())
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(self)

        // Write the JSON data to a file
        let fileURL = getVocabMetadataPath()
        try! jsonData.write(to: fileURL)
    }
    
    // Gets fresh metadata from firbase storage, triggers update of local vocabs on version change
    // We are only interested in vocabs for existing decks, so we receive deck information as input
    func updateVocabs(decks: [DeckMetadata]) {
        let storage = Storage.storage()
        let pathReference = storage.reference(withPath: "metainfo.json")
        pathReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            do {
                if let error = error {
                    // Uh-oh, an error occurred!
                    print("Error downloading metainfo: ", error)
                } else {
                    // Data for "images/island.jpg" is returned
                    if let data = data {
                        let decoder = JSONDecoder()
                        let infos = try decoder.decode([VocabMetadata].self, from: data)
                        self.updateVocabsInner(newVocabMetadata: infos, decks: decks)
                    }
                }
            } catch {
                print("failed to fetch metadata")
            }
        }
    }

    func updateVocabsInner(newVocabMetadata: [VocabMetadata], decks: [DeckMetadata]) {
        for newVocabVersion in newVocabMetadata {
            let m = decks.first {deck in
                deck.frontLanguage.rawValue == newVocabVersion.languageFrom && deck.backLanguage.rawValue == newVocabVersion.languageTo
            }
            if m == nil {
                // no decks with this language pair
                continue
            }
            let v = vocabVersions.first {vocabVersion in
                newVocabVersion.languageTo == vocabVersion.languageTo && newVocabVersion.languageFrom == vocabVersion.languageFrom
            }
            if let vocabVersion = v {
                if vocabVersion.version == newVocabVersion.version {
                    // already updated to this version
                    print("Skipping updating vocabs for \(newVocabMetadata), already up to date")
                    continue
                }
            }
            // no previous versions of this vocab, or current version is old
            updateVocab(newVocabVersion: newVocabVersion)
        }
    }
    
    func updateVocab(newVocabVersion: VocabMetadata) {
        let languageFrom = newVocabVersion.languageFrom
        let languageTo = newVocabVersion.languageTo
        let path = newVocabVersion.path
        print("Downloading vocab for languages: \(languageFrom)-\(languageTo) from path: \(path)")
        let storage = Storage.storage()
        let pathReference = storage.reference(withPath: path)
        pathReference.write(toFile: getVocabPath(languageFrom: languageFrom, languageTo: languageTo)) { [self] url, error in
            if let error = error {
                print("Error downloaded vocab for languages: \(languageFrom)-\(languageTo) from path: \(path), ", error)
            } else {
                print("Successfully downloading vocab for languages: \(languageFrom)-\(languageTo) from path: \(path)")
                // update global Vocabs singleton with new version
                // update vocab metadata and save
                let serialQueue = DispatchQueue(label: "queuename")
                serialQueue.sync {
                    // update vocab holder singleton
                    vocabs.updateVocab(languageFrom: languageFrom, languageTo: languageTo)
                    // update stored versions
                    self.vocabVersions.removeAll {vocabVersion in
                        newVocabVersion.languageTo == vocabVersion.languageTo && newVocabVersion.languageFrom == vocabVersion.languageFrom
                    }
                    self.vocabVersions.append(newVocabVersion)
                    save()
                }
                print("Successfully updated vocab for languages: \(languageFrom)-\(languageTo) from path: \(path)")
            }
        }
    }
}
