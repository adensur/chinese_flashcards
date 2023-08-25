//
//  Metainfo.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 24/08/2023.
//

import Foundation
import FirebaseStorage

struct VocabMetadata: Codable {
    var languageTo: String
    var languageFrom: String
    var version: Int
    var path: String
}

func updateVocabs(decks: Decks) {
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
                    decks.updateVocabs(newVocabMetadata: infos)
                }
            }
        } catch {
            print("failed to fetch metadata")
        }
    }
}

