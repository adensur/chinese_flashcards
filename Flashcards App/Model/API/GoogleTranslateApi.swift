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
    do {
        let (data, _) = try await URLSession.shared.upload(for: request, from: body)
        let values = data.split(separator: UInt8(ascii: ","))
        if values.count <= 2 {
            print("transient error in getSound")
            return nil
        }
        let str = values[2]
        if str.count < 10 {
            print("transient error in getSound")
            return nil
        }
        //    doesn't work for some reason:
        //    let str2 = str[4..<str.count - 4]
        let str2 = str.subdata(in: str.startIndex + 4 ..< str.endIndex - 4)
        return Data(base64Encoded: str2)
    } catch {
        return nil
    }
}

struct Detail: Identifiable {
    let word: String
    let freq: Int?
    let type: EWordType?
    let pinyin: String?
    let decomposition: String?
    let etymology: Etymology?
    let subId: String
    
    init(word: String, freq: Int?, type: EWordType?, pinyin: String? = nil, decomposition: String? = nil, etymology: Etymology? = nil, subId: String = "") {
        self.word = word
        self.freq = freq
        self.type = type
        self.pinyin = pinyin
        self.decomposition = decomposition
        self.etymology = etymology
        self.subId = subId
    }
    
    var id: String {
        return word + subId
    }
}

enum EWordType: Int {
    case noun = 1
    case verb = 2
    case adjective = 3
    case adverb = 4
    case preposition = 5
    case abbreviation = 6
    case conjuction = 7
    case pronoun = 8
    case phrase = 10
    case prefix = 11
    case suffix = 12
    case article = 13
    case numeral = 15
    case auxiliaryVerb = 16
    case exclamation = 17
    case particle = 19
    case unknown = 20
    
    static func fromString(_ s: String) -> EWordType {
        switch s {
        case "noun":
            return .noun
        case "verb":
            return .verb
        case "adjective":
            return .adjective
        case "adverb":
            return .adverb
        case "preposition":
            return .preposition
        case "abbreviation":
            return .abbreviation
        case "conjunction":
            return .conjuction
        case "pronoun":
            return .pronoun
        case "phrase":
            return .phrase
        case "suffix":
            return .suffix
        case "prefix":
            return .prefix
        case "article":
            return .article
        case "numeral":
            return .numeral
        case "auxiliaryVerb":
            return .auxiliaryVerb
        case "exclamation":
            return .exclamation
        case "particle":
            return .particle
        default:
            return .unknown
        }
    }
    
    static func allValues() -> [EWordType] {
        return [
            .unknown,
            .noun,
            .verb,
            .adjective,
            .adverb,
            .preposition,
            .abbreviation,
            .conjuction,
            .pronoun,
            .phrase,
            .prefix,
            .suffix,
            .article,
            .numeral,
            .auxiliaryVerb,
            .exclamation,
            .particle,
        ]
    }
    
    func toString() -> String {
        switch self {
        case .noun:
            return "noun"
        case .verb:
            return "verb"
        case .adjective:
            return "adjective"
        case .adverb:
            return "adverb"
        case .preposition:
            return "preposition"
        case .abbreviation:
            return "abbreviation"
        case .conjuction:
            return "conjuction"
        case .pronoun:
            return "pronoun"
        case .phrase:
            return "phrase"
        case .prefix:
            return "prefix"
        case .suffix:
            return "suffix"
        case .article:
            return "article"
        case .numeral:
            return "numeral"
        case .auxiliaryVerb:
            return "auxiliary verb"
        case .exclamation:
            return "exclamation"
        case .particle:
            return "particle"
        case .unknown:
            return ""
        }
    }
}

func getTranslation(for word: String, langFrom: String, langTo: String) async -> [Detail]? {
    async let vocabTranslations = getVocabTranslations(for: word, langFrom: langFrom, langTo: langTo)
    async let translateTranslations = getTranslationTranslations(for: word, langFrom: langFrom, langTo: langTo)
    async let translateTranslations2 = getTranslationTranslations2(for: word, langFrom: langFrom, langTo: langTo)

    let vocabResult = await vocabTranslations
    var translateResult = await translateTranslations
    let translateResult2 = await translateTranslations2

    translateResult?.append(contentsOf: translateResult2 ?? [])
    translateResult?.append(contentsOf: vocabResult ?? [])
    
    return translateResult
}

func getTranslationTranslations2(for word: String, langFrom: String, langTo: String) async -> [Detail]? {
    let url = URL(string: "https://translate.google.com/_/TranslateWebserverUi/data/batchexecute?rpcids=MkEWBc&source-path=%2F&f.sid=4406102408556538576&bl=boq_translate-webserver_20240624.07_p1&hl=en-US&soc-app=1&soc-platform=1&soc-device=1&_reqid=259185&rt=c")!
    var request = URLRequest(url: url)
    request.setValue("https://translate.google.com/", forHTTPHeaderField: "Referer")
    request.setValue("""
"Not/A)Brand";v="99", "Google Chrome";v="115", "Chromium";v="115"
"""
, forHTTPHeaderField: "sec-ch-ua")
    request.setValue("1", forHTTPHeaderField: "X-Same-Domain")
    request.setValue("?0", forHTTPHeaderField: "sec-ch-ua-mobile")
    request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:126.0) Gecko/20100101 Firefox/126.0", forHTTPHeaderField: "User-Agent")
    request.setValue("""
"arm"
""", forHTTPHeaderField: "sec-ch-ua-arch")
    request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
    request.setValue("""
"115.0.5790.170"
""", forHTTPHeaderField: "sec-ch-ua-full-version")
    request.setValue("""
[";PCK4InrQAAYTe_VmM3tf6_RgVjAxldsmADQBEArZ1N9IKmV5KEzUgcakO3qPHRjpSPsSDK2FV2lnFOHWVBdnqqQfY8ILk_iYhChoa_4XHwAAACBPAAAAAXUBB2MANh-w0KjB4lF5EGdSB8QefFYnJXO0SSnfkgVhMvK3sLbLYZZaSH4FaqLQtp0p0h062_UekORnYxcAO4v0V_w9XcDKQEfjQefi1m8RF3dh1Cgw_i2uza8yX1v7TRPfoWSNugdqlL4y7ALCOui7-HbH_RXcQhfWhAKUdsfnNhKbGr4gJ1HKUJUVfuwgrtM7Hm34H89tZ0jz53YEBx_lutQ9tl4eTvB8TC-P5sbdu_EzfXLbc7dGVczPxLgK1h7V6dptV_nE_HpWEHUJmESTGwYVLEwrEaYOrR-yV1rhDv3SNccawByUqImnpUsZHXiTcx0LK0wgjCNhWHyGICnmpY_nqjSvTt8KkCBYROAeo_QWF9k1Ul3iXa_exw6ZGZ_la5f2QGw781w8rOkOkAtY3lTDDe1LTzUIFhNUjZjBDUSB3GrHkeB0LE6dTrrDkTXYHcgCZ1QNkL-nNBy1J5T_SNVZX86lMMyPbf9VKDcHgq6DQvfXeMTRdQbk0zpp9wBYKieNWyoy_ylwnUtpkSCeNr_kvoNw_4ZjaJ4Q3fyjyxndf0Y49H9cU8VqvduMETNF669ONi7nU_1dO52bfsY-O-QEhcm_ZOiVGxO05pc5Vkdj4zJeYTu9744emsvn3d9YJp1bKZmT5_bcq4hwtlYXSdOF_FQ_ShcbELMhSyK8sCujH67xqvEnnKytlPQK1ulZcA6HtCiPx1r7cls7bU8F3tX1f02phMoxa0ZlOx7TnKxjXMoPvC65qdOBilXzFuMOclKEXgUAuM1J-dj5HKGWf8ew3VW0JXiLqfIdNNkDY6SecZ7m_TuSIs4dl06c0KFw-kSq8vOV7IlMZqkCK50n9AA9wSu0z2KgB_czz975Q4EG284jpn0_53q6vLBAFX-aUBhOY6avHbR-aUJff370Hx5ot_wShbzOn5_N7bhNvsGiZ1RJ0cfh6WBvWH9hSuhwRRXPAWSFcfWNhCE1_K3r0ORRdvXTO6gTCQwdtm8oDDJdfme5uPFpbNTmdXNph97u44rtxDFgCXctFrIKJ5Fn",null,null,11,null,null,null,0,"2"]
""", forHTTPHeaderField: "X-Goog-BatchExecute-Bgr")
    request.setValue("""
"13.4.1"
""", forHTTPHeaderField: "sec-ch-ua-platform-version")
    request.setValue("""
"Not/A)Brand";v="99.0.0.0", "Google Chrome";v="115.0.5790.170", "Chromium";v="115.0.5790.170"
""", forHTTPHeaderField: "sec-ch-ua-full-version-list")
    request.setValue("""
"64"
""", forHTTPHeaderField: "sec-ch-ua-bitness")
    request.setValue("""
""
""", forHTTPHeaderField: "sec-ch-ua-model")
    request.setValue("?0", forHTTPHeaderField: "sec-ch-ua-wow64")
    request.setValue("""
"macOS"
""", forHTTPHeaderField: "sec-ch-ua-platform")
    request.httpMethod = "POST"
    
    let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
    let bodyStr = "f.req=%5B%5B%5B%22MkEWBc%22%2C%22%5B%5B%5C%22\(encodedWord)%5C%22%2C%5C%22\(langFrom)%5C%22%2C%5C%22\(langTo)%5C%22%2C1%5D%2C%5B1%5D%5D%22%2Cnull%2C%22generic%22%5D%5D%5D&at=AFS6QygGp77veKmTKcM4ysAOd1C0%3A1719415584493&"
    let body = Data(bodyStr.utf8)
    guard let (data, _) = try? await URLSession.shared.upload(for: request, from: body) else {
        print("translate api http request failed")
        return nil
    }
    var result: [Detail] = []
    do {
        for line in data.split(separator: UInt8(ascii: "\n")) {
            if !line.contains("MkEWBc".utf8) {
                continue
            }
            guard let js = try? JSONSerialization.jsonObject(with: line, options: []) else {
                print("Transient erorr #1 in google translate api")
                return nil
            }
            print("MkEWBc js: ", js)
            guard let jsonObject = js as? [[Any]] else {
                print("non-transient error in parsing translate details response #0")
                return result
            }
            if jsonObject.isEmpty || jsonObject[0].count <= 2 {
                print("non-transient error in parsing translate details response #1")
                return result
            }
            guard let str = jsonObject[0][2] as? String else {
                print("non-transient error in parsing translate details response #2")
                return result
            }
            guard let subobj = try JSONSerialization.jsonObject(with: str.data(using: .utf8)!, options: []) as? [Any] else {
                print("non-transient error in parsing translate details response #3")
                return result
            }
            if subobj.isEmpty {
                print("non-transient error in parsing translate details response #4")
                return result
            }
            guard let subobj2 = subobj[1] as? [Any] else {
                print("non-transient error in parsing translate details response #5")
                return result
            }
            if subobj2.count < 1 {
                print("transient error in parsing translate details response #2")
                return nil
            }
            guard let subobj3 = subobj2[0] as? [[Any]] else {
                print("non-transient error in parsing translate details response #6")
                return result
            }
            if subobj3.count < 1 {
                print("transient error in parsing translate details response #2")
                return nil
            }
            guard let subobj4 = subobj3[0][5] as? [[Any]] else {
                print("non-transient error in parsing translate details response #7")
                return result
            }
            var translation: String? = nil
            if let p = subobj4[0][0] as? String {
                translation = p.lowercased()
            }
            let detail = Detail(word: translation ?? "", freq: -2, type: nil, subId: "£T")
            result.append(detail)
        }
    } catch {
        print("caught: \(error)")
        print("non-transient error in google translate api parsing")
    }
    return result
}

func getTranslationTranslations(for word: String, langFrom: String, langTo: String) async -> [Detail]? {
    let url = URL(string: "https://translate.google.com/_/TranslateWebserverUi/data/batchexecute?rpcids=AVdN8&source-path=%2F&f.sid=-8211867706543863077&bl=boq_translate-webserver_20240623.08_p0&hl=en-US&soc-app=1&soc-platform=1&soc-device=1&_reqid=567103&rt=c")!
    var request = URLRequest(url: url)
    request.setValue("https://translate.google.com/", forHTTPHeaderField: "Referer")
    request.setValue("""
"Not/A)Brand";v="99", "Google Chrome";v="115", "Chromium";v="115"
"""
, forHTTPHeaderField: "sec-ch-ua")
    request.setValue("1", forHTTPHeaderField: "X-Same-Domain")
    request.setValue("?0", forHTTPHeaderField: "sec-ch-ua-mobile")
    request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
    request.setValue("""
"arm"
""", forHTTPHeaderField: "sec-ch-ua-arch")
    request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
    request.setValue("""
"115.0.5790.170"
""", forHTTPHeaderField: "sec-ch-ua-full-version")
    request.setValue("""
[";Vki4SBXQAAZiAW6_QgFfSVI0DapWBfwmADkAIwj8RrOLzrt4bCMldZXoxUquFKB-XAEGEL-RzfCskTGh7LP1S03dxmk6LhNMLSHQDGqkg7CvFDwfAAAAPU8AAAAFdQEHhALmL8GPnO1zsDgBGpUU66A5zBIK5Om-4UOSipzifYxX9GHqfC5LvGrEe_Cxz3-y0PqBRN_mCfLNmW_ULuZfNTG4KnGyGQ67mvTh7eyCttJpxsIloU7M4hMNQ2N_600sNLh8gKkxUjEBViOEL4g1oYfNzRKmUBhVv1r9PzzItly8wxGQj_PaxhD8cnfJNv44A5EzNIbUjii4OtihNOWnktEcC2udTIRnVUv_UYJuLECwCKyoliakFAIgINk3yMSLW4ft9pBW9Aa4CgTlwfNGfeymPOHEvfX4jLt3fS6jkrPvevnesQ6jvVK50-tZxXEMd5i4u5ArgvCFc4A_CnQCgRL9FIL_pnXWa4WhblG7jgSy-3JvnxIBo2ZAu1sWVuaNF-7j9cO_t4Wz8PiCZOOdGR6tSOOidaGNQxjSjjWgsZPoindkpQKCL3PkMa6OYZ8TVMfIv2G7dEQpbYxrnJglhuQwNOT_vqeiQdpV_G2Vnka6UbYWJ01y9z44tx7IhYTpNh5mF6KiHPk_4nkBB70VghY82bUQ_C6EyrjljH_qwglN_fdxph-zw1y6zeIIlu8HlTceNut08T8eCxrNDVfK2g1K5dqdP44-PuLAsdN3uVbnZlEzoLCyT4i3Qv70YS29I7Z9MmjPe2oezsjIZh0xXNnfwa6DkaAwyo9RXIQKNrQcz0MkCd-Oz1IQOEgGJvmN2R2dXDH9M1NYKaQtkWiPBbcSD6uC2Ra58k8IK-qYZaKrwEOwTGaSl5UEOivX_LdMv6sXbCfBIIptVpvxEmqCrivQMKcZS0bA4UgVlMNL_z6fC7L-ny51KC29wMIjIFRiS7-17jdLUgSsFiu-4U-0piA2HBob4UjLjb6_85EzbOccAK54WHGc-ttJnFm_-r4XVUBxonFc8I6ePYt_yppd4menBdG-sR83c0ziUgH3PiLuRmXlCBvM6NUix52E1LAMpo-bzVSvh9vppVsE8oUSBCV9h1tYgIOtRg",null,null,17,null,null,null,0,"2"
""", forHTTPHeaderField: "X-Goog-BatchExecute-Bgr")
    request.setValue("""
"13.4.1"
""", forHTTPHeaderField: "sec-ch-ua-platform-version")
    request.setValue("""
"Not/A)Brand";v="99.0.0.0", "Google Chrome";v="115.0.5790.170", "Chromium";v="115.0.5790.170"
""", forHTTPHeaderField: "sec-ch-ua-full-version-list")
    request.setValue("""
"64"
""", forHTTPHeaderField: "sec-ch-ua-bitness")
    request.setValue("""
""
""", forHTTPHeaderField: "sec-ch-ua-model")
    request.setValue("?0", forHTTPHeaderField: "sec-ch-ua-wow64")
    request.setValue("""
"macOS"
""", forHTTPHeaderField: "sec-ch-ua-platform")
    request.httpMethod = "POST"
    
    let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
    let bodyStr = "f.req=%5B%5B%5B%22AVdN8%22%2C%22%5B%5C%22\(encodedWord)%5C%22%2C%5C%22\(langFrom)%5C%22%2C%5C%22\(langTo)%5C%22%5D%22%2Cnull%2C%22generic%22%5D%5D%5D&at=AFS6QyjBFZM1NnSgNqAcOFuOelsi%3A1719337102197&"
    let body = Data(bodyStr.utf8)
    guard let (data, _) = try? await URLSession.shared.upload(for: request, from: body) else {
        print("translate api http request failed")
        return nil
    }
    var result: [Detail] = []
    do {
        for line in data.split(separator: UInt8(ascii: "\n")) {
            if !line.contains("AVdN8".utf8) {
                continue
            }
            guard let js = try? JSONSerialization.jsonObject(with: line, options: []) else {
                print("Transient erorr #1 in google translate api")
                return nil
            }
            print("js: ", js)
            guard let jsonObject = js as? [[Any]] else {
                print("non-transient error in parsing translate details response #0")
                return result
            }
            if jsonObject.isEmpty || jsonObject[0].count <= 2 {
                print("non-transient error in parsing translate details response #1")
                return result
            }
            guard let str = jsonObject[0][2] as? String else {
                print("non-transient error in parsing translate details response #2")
                return result
            }
            guard let subobj = try JSONSerialization.jsonObject(with: str.data(using: .utf8)!, options: []) as? [Any] else {
                print("non-transient error in parsing translate details response #3")
                return result
            }
            if subobj.isEmpty {
                print("non-transient error in parsing translate details response #4")
                return result
            }
            guard let subobj2 = subobj[0] as? [Any] else {
                print("non-transient error in parsing translate details response #5")
                return result
            }
            if subobj2.count < 1 {
                print("transient error in parsing translate details response #2")
                return nil
            }
            guard let subobj3 = subobj2[0] as? [Any] else {
                print("non-transient error in parsing translate details response #6")
                return result
            }
            if subobj3.count < 2 {
                print("transient error in parsing translate details response #2")
                return nil
            }
            var translation: String? = nil
            if let p = subobj3[1] as? String {
                translation = p.lowercased()
            }
            let detail = Detail(word: translation ?? "", freq: -1, type: nil, subId: "£t")
            result.append(detail)
        }
    } catch {
        print("caught: \(error)")
        print("non-transient error in google translate api parsing")
    }
    return result
}

func getVocabTranslations(for word: String, langFrom: String, langTo: String) async -> [Detail]? {
    let url = URL(string: "https://translate.google.com/_/TranslateWebserverUi/data/batchexecute?rpcids=rPsWke%2CHGRyXb%2CV11VDb&source-path=%2Fdetails&f.sid=94628587805217822&bl=boq_translate-webserver_20230813.08_p0&hl=en&soc-app=1&soc-platform=1&soc-device=1&_reqid=1262696&rt=c")!
    var request = URLRequest(url: url)
    request.setValue("http://translate.google.com/", forHTTPHeaderField: "Referer")
    request.setValue("""
"Not/A)Brand";v="99", "Google Chrome";v="115", "Chromium";v="115"
"""
, forHTTPHeaderField: "sec-ch-ua")
    request.setValue("1", forHTTPHeaderField: "X-Same-Domain")
    request.setValue("?0", forHTTPHeaderField: "sec-ch-ua-mobile")
    request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
    request.setValue("""
"arm"
""", forHTTPHeaderField: "sec-ch-ua-arch")
    request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
    request.setValue("""
"115.0.5790.170"
""", forHTTPHeaderField: "sec-ch-ua-full-version")
    request.setValue("""
[";Vki4SBXQAAZiAW6_QgFfSVI0DapWBfwmADkAIwj8RrOLzrt4bCMldZXoxUquFKB-XAEGEL-RzfCskTGh7LP1S03dxmk6LhNMLSHQDGqkg7CvFDwfAAAAPU8AAAAFdQEHhALmL8GPnO1zsDgBGpUU66A5zBIK5Om-4UOSipzifYxX9GHqfC5LvGrEe_Cxz3-y0PqBRN_mCfLNmW_ULuZfNTG4KnGyGQ67mvTh7eyCttJpxsIloU7M4hMNQ2N_600sNLh8gKkxUjEBViOEL4g1oYfNzRKmUBhVv1r9PzzItly8wxGQj_PaxhD8cnfJNv44A5EzNIbUjii4OtihNOWnktEcC2udTIRnVUv_UYJuLECwCKyoliakFAIgINk3yMSLW4ft9pBW9Aa4CgTlwfNGfeymPOHEvfX4jLt3fS6jkrPvevnesQ6jvVK50-tZxXEMd5i4u5ArgvCFc4A_CnQCgRL9FIL_pnXWa4WhblG7jgSy-3JvnxIBo2ZAu1sWVuaNF-7j9cO_t4Wz8PiCZOOdGR6tSOOidaGNQxjSjjWgsZPoindkpQKCL3PkMa6OYZ8TVMfIv2G7dEQpbYxrnJglhuQwNOT_vqeiQdpV_G2Vnka6UbYWJ01y9z44tx7IhYTpNh5mF6KiHPk_4nkBB70VghY82bUQ_C6EyrjljH_qwglN_fdxph-zw1y6zeIIlu8HlTceNut08T8eCxrNDVfK2g1K5dqdP44-PuLAsdN3uVbnZlEzoLCyT4i3Qv70YS29I7Z9MmjPe2oezsjIZh0xXNnfwa6DkaAwyo9RXIQKNrQcz0MkCd-Oz1IQOEgGJvmN2R2dXDH9M1NYKaQtkWiPBbcSD6uC2Ra58k8IK-qYZaKrwEOwTGaSl5UEOivX_LdMv6sXbCfBIIptVpvxEmqCrivQMKcZS0bA4UgVlMNL_z6fC7L-ny51KC29wMIjIFRiS7-17jdLUgSsFiu-4U-0piA2HBob4UjLjb6_85EzbOccAK54WHGc-ttJnFm_-r4XVUBxonFc8I6ePYt_yppd4menBdG-sR83c0ziUgH3PiLuRmXlCBvM6NUix52E1LAMpo-bzVSvh9vppVsE8oUSBCV9h1tYgIOtRg",null,null,17,null,null,null,0,"2"
""", forHTTPHeaderField: "X-Goog-BatchExecute-Bgr")
    request.setValue("""
"13.4.1"
""", forHTTPHeaderField: "sec-ch-ua-platform-version")
    request.setValue("""
"Not/A)Brand";v="99.0.0.0", "Google Chrome";v="115.0.5790.170", "Chromium";v="115.0.5790.170"
""", forHTTPHeaderField: "sec-ch-ua-full-version-list")
    request.setValue("""
"64"
""", forHTTPHeaderField: "sec-ch-ua-bitness")
    request.setValue("""
""
""", forHTTPHeaderField: "sec-ch-ua-model")
    request.setValue("?0", forHTTPHeaderField: "sec-ch-ua-wow64")
    request.setValue("""
"macOS"
""", forHTTPHeaderField: "sec-ch-ua-platform")
    request.httpMethod = "POST"
    let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
    let bodyStr = "f.req=%5B%5B%5B%22rPsWke%22%2C%22%5B%5B%5C%22\(encodedWord)%5C%22%2C%5C%22\(langFrom)%5C%22%2C%5C%22\(langTo)%5C%22%5D%2C1%5D%22%2Cnull%2C%221%22%5D%2C%5B%22HGRyXb%22%2C%22%5B%5C%22\(langFrom)%5C%22%2C%5C%22\(langTo)%5C%22%5D%22%2Cnull%2C%229%22%5D%2C%5B%22V11VDb%22%2C%22%5B%5C%22\(langFrom)%5C%22%2C%5C%22\(langTo)%5C%22%5D%22%2Cnull%2C%2212%22%5D%5D%5D&at=AFS6QyhTMeUWg72pSEGCg2YaZYOw%3A1692203095521&"
    let body = Data(bodyStr.utf8)
    guard let (data, _) = try? await URLSession.shared.upload(for: request, from: body) else {
        print("translate api http request failed")
        return nil
    }
    var result: [Detail] = []
    do {
        for line in data.split(separator: UInt8(ascii: "\n")) {
            if line.contains("rPsWke".utf8) {
                guard let js = try? JSONSerialization.jsonObject(with: line, options: []) else {
                    print("Transient erorr #1 in google translate api")
                    return nil
                }
                guard let jsonObject = js as? [[Any]] else {
                    print("non-transient error in parsing translate details response #0")
                    return result
                }
                if jsonObject.isEmpty || jsonObject[0].count <= 2 {
                    print("non-transient error in parsing translate details response #1")
                    return result
                }
                guard let str = jsonObject[0][2] as? String else {
                    print("non-transient error in parsing translate details response #2")
                    return result
                }
                guard let subobj = try JSONSerialization.jsonObject(with: str.data(using: .utf8)!, options: []) as? [Any] else {
                    print("non-transient error in parsing translate details response #3")
                    return result
                }
                if subobj.isEmpty {
                    print("non-transient error in parsing translate details response #4")
                    return result
                }
                guard let subobj2 = subobj[0] as? [Any] else {
                    print("non-transient error in parsing translate details response #5")
                    return result
                }
                if subobj2.count <= 5 {
                    print("transient error in parsing translate details response #2")
                    return nil
                }
                var pinyin: String? = nil
                if subobj2.count > 6 {
                    if let p = subobj2[6] as? String {
                        pinyin = p.lowercased()
                    }
                }
                guard let subobj3 = subobj2[5] as? [Any] else {
                    print("non-transient error in parsing translate details response #6")
                    return result
                }
                if subobj3.isEmpty {
                    print("non-transient error in parsing translate details response #7")
                    return result
                }
                guard let subobj4 = subobj3[0] as? [Any] else {
                    print("non-transient error in parsing translate details response #8")
                    return result
                }
                for component in subobj4 {
                    guard let subobj5 = component as? [Any] else {
                        print("non-transient error in parsing translate details response #9")
                        return result
                    }
                    if subobj5.count <= 4 {
                        print("non-transient error in parsing translate details response #10")
                        return result
                    }
                    guard let wordType = subobj5[4] as? Int else {
                        print("non-transient error in parsing translate details response #11")
                        return result
                    }
                    print("wordType: ", wordType)
                    if subobj5.count <= 1 {
                        print("non-transient error in parsing translate details response #12")
                        return result
                    }
                    guard let subobj6 = subobj5[1] as? [[Any]] else {
                        print("non-transient error in parsing translate details response #13")
                        return result
                    }
                    for subcomponent in subobj6 {
                        if subcomponent.isEmpty {
                            print("non-transient error in parsing translate details response #14")
                            return result
                        }
                        guard let translation = subcomponent[0] as? String else {
                            print("non-transient error in parsing translate details response #15")
                            return result
                        }
                        if subcomponent.count <= 3 {
                            print("non-transient error in parsing translate details response #16")
                            return result
                        }
                        guard let freq = subcomponent[3] as? Int else {
                            print("non-transient error in parsing translate details response #17")
                            return result
                        }
                        guard let wType = EWordType(rawValue: wordType) else {
                            print("non-transient error in parsing translate details response #18")
                            return result
                        }
                        let detail = Detail(word: translation, freq: freq, type: wType, pinyin: pinyin, subId: "£v")
                        if !result.contains(where: { existingDetail in
                            existingDetail.word == detail.word
                        }) {
                            result.append(detail)
                        }
                    }
                    
                }
            }
        }
    } catch {
        print("caught: \(error)")
        print("non-transient error in google translate api parsing")
    }
    return result
}
