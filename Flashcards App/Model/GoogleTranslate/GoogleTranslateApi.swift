//
//  GoogleTranslateApi.swift
//  Flashcards App
//
//  Created by Maksim Gaiduk on 11/08/2023.
//

import Foundation

func getSound(for word: String, lang: String) async -> Data?  {
    let url = URL(string: "https://translate.google.com/_/TranslateWebserverUi/data/batchexecute")!
    var request = URLRequest(url: url)
    request.setValue("http://translate.google.com/", forHTTPHeaderField: "Referer")
    request.setValue("Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36", forHTTPHeaderField: "User-Agent")
    request.setValue("application/x-www-form-urlencoded;charset=utf-8", forHTTPHeaderField: "Content-Type")
    let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
    let contentLength = 130 + encodedWord.utf8.count
    print("Content length: ", contentLength)
    request.setValue("\(contentLength)", forHTTPHeaderField: "Content-Length")
    request.httpMethod = "POST"
    let body = Data("f.req=%5B%5B%5B%22jQ1olc%22%2C%22%5B%5C%22\(encodedWord)%5C%22%2C%5C%22\(lang)%5C%22%2Cnull%2C%5C%22null%5C%22%5D%22%2Cnull%2C%22generic%22%5D%5D%5D&".utf8)
    let (data, _) = try! await URLSession.shared.upload(for: request, from: body)
    let str = data.split(separator: Character(",").asciiValue!)[2]
    let str2 = str.subdata(in: str.startIndex + 4 ..< str.endIndex - 4)
    return Data(base64Encoded: str2)
}
