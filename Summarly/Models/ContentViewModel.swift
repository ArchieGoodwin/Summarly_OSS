//
//  ContentViewModel.swift
//  strAI
//
//  Created by Sergey Dikarev on 10.12.2022.
//

import Foundation
import SwiftSoup
import SwiftUI
import PDFKit
import PineconeSwift

class ContentViewModel: ObservableObject
{
    @Published var navigationStack: [String] = ["ChatListView", "ContentView"]
    @Published var navigationIndex: Int = 0
    @Published var resultText: String?
    @Published var resultUrl: URL?
    @Published var working: Bool = false
    @Published var imageLoading: Bool = false

    @Published var showAlert: Bool = false
    @Published var errorText: String?
    
    @Published var chats: [ChatModel] = []
    @Published var currentChat: ChatModel?
    @Published var messages: [ChatMessage] = []
    
   

    func chatChunked(chunks: [String], summary: [String]) async throws -> String? {
        do {
            var messages: [Message] = [Message(role: "system", content: "You are very smart and careful reviewer writing summaries for texts")]

            let assistanMessages = chunks.map { chunk in
                return Message(role: "assistant", content: chunk)
            }
            messages.append(contentsOf: assistanMessages)
            messages.append(Message(role: "user", content: "Create please long summary"))
            
            let ai = AISwift(authToken: Constants.aiToken())
            let result = try await ai.chatGenerate(with: messages)
            print("result: ", result?.choices.first?.message.content)
            return result?.choices.first?.message.content
        }
        catch {
            throw error
        }
       
    }
    
    func loadChats() {
        do {
            let path = URL(fileURLWithPath: NSTemporaryDirectory())
            let disk = DiskStorage(path: path)
            let storage = CodableStorage(storage: disk)

            let cached: Chats = try storage.fetch(for: "chats")
            self.chats = cached.chats
        }
        catch {
            Log(error)
        }
       
    }
    
    func saveChats() {
        do {
            let path = URL(fileURLWithPath: NSTemporaryDirectory())
            let disk = DiskStorage(path: path)
            let storage = CodableStorage(storage: disk)

            let cached = Chats(chats: self.chats)
            try storage.save(cached, for: "chats")
         
        }
        catch {
            Log(error)
        }
    }
    
    func summuriseChunked(chunks: [String], summary: [String]) async throws -> String? {
        do {
            var messages: [Message] = [Message(role: "system", content: "You are very smart and careful reviewer writing summaries for texts")]

            let assistanMessages = chunks.map { chunk in
                return Message(role: "assistant", content: chunk)
            }
            messages.append(contentsOf: assistanMessages)
            messages.append(Message(role: "user", content: "Create please long summary"))
            
            let ai = AISwift(authToken: Constants.aiToken())
            let result = try await ai.chatGenerate(with: messages)
            print("result: ", result?.choices.first?.message.content)
            return result?.choices.first?.message.content
        }
        catch {
            throw error
        }
       
    }
    
    func answerQuestion(matches: [PineconeVector], question: String) async throws -> String? {
        do {
            var messages: [Message] = [Message(role: "system", content: "You are very smart specialist for the theme below and can answer questions")]

            let assistanMessages = matches.map { chunk in
                return Message(role: "assistant", content: chunk.metadata["text"] ?? "")
            }
            messages.append(contentsOf: assistanMessages)
            messages.append(Message(role: "user", content: "Answer please question: \(question)"))
            
            let ai = AISwift(authToken: Constants.aiToken())
            let result = try await ai.chatGenerate(with: messages)
            print("result for question: ", result?.choices.first?.message.content)
            return result?.choices.first?.message.content
        }
        catch {
            throw error
        }
       
    }
    
    func startQueringEmbedding(question: String, namespace: String) async throws -> Bool {
        
        DispatchQueue.main.async {
            self.messages.insert(ChatMessage(isUser: true, tag: "link", header: "Your question", message: question, messageImage: nil, actionImage: "square.and.arrow.up.on.square"), at: 0)
            self.messages.insert(ChatMessage(isUser: true, tag: "loading", header: "", message: question, messageImage: nil, actionImage: nil), at: 0)
        }
       
        
        let ai = AISwift(authToken: Constants.aiToken())
        if let embeddings = try await ai.fetchEmbeddings(with: [question]).first {
            let pai = PineconeSwift(apikey: PineconeAPI_KEY, baseURL: pinecone_api_baseurl)
            let result = try await pai.queryVectors(with: embeddings, namespace: namespace, topK: 5, includeMetadata: true)
            Log(result)
            
            let answer = try await self.answerQuestion(matches: result, question: question) ?? "Can't answer, sorry"
            
            DispatchQueue.main.async {
                self.messages.removeFirst()
                self.messages.insert(ChatMessage(isUser: false, tag: "answer", header: "Answer", message: answer, messageImage: nil, actionImage: "square.and.arrow.up.on.square"), at: 0)
            }
            
            return true
        }
        DispatchQueue.main.async {
            self.messages.removeFirst()
        }
        return false

    }
    
    func startEmbedding(link: String, text: String) async throws -> Bool {
        do {
            let ai = AISwift(authToken: Constants.aiToken())
            let chunks = splitTextIntoChunks(text: text, maxLetters: 1000, overlapSentences: 1)
            let embeddings = try await ai.fetchEmbeddings(with: chunks)
            
            let pai = PineconeSwift(apikey: PineconeAPI_KEY, baseURL: pinecone_api_baseurl)
            let result = try await pai.upsertVectors(with: embeddings, namespace: link)
            return result
        }
        catch {
            Log(error)
            return false
        }
    }
    
    @MainActor
    func generateAnswer(question: String, namespace: String) async throws {
        Task.detached { @MainActor in
            self.messages.insert(ChatMessage(isUser: true, tag: "link", header: "Your request", message: question, messageImage: nil, actionImage: "square.and.arrow.up.on.square"), at: 0)
            self.messages.insert(ChatMessage(isUser: true, tag: "loading", header: "", message: question, messageImage: nil, actionImage: nil), at: 0)
            
            _ = try await self.startQueringEmbedding(question: question, namespace: namespace)
            
            
        }
        
    }
        
    @MainActor
    func generateChat(link: String) async throws {
        
        do {
            self.working = true
            self.messages = []
            let ai = AISwift(authToken: Constants.aiToken())

            var contents: String = ""
            if let url = URL(string: link), UIApplication.shared.canOpenURL(url) {
                
                if let url = URL(string: link), url.conforms(to: .pdf) {
                    
                    let filename = "\(Date().timeIntervalSince1970)"
                    if let path = self.savePdf(urlString: link, fileName: filename) {
                        if let pdf = self.loadPDFText(fileName: path) {
                            contents = pdf
                        }
                    }
                    
                }
                else {
                    contents = try await ai.loadLink(with: link)
                }
            }
            else {
                contents = link
            }
            
            
            currentChat = ChatModel()
            currentChat?.link = link
            Task.detached { @MainActor in
                self.messages.insert(ChatMessage(isUser: true, tag: "loading", header: "", message: link, messageImage: nil, actionImage: nil), at: 0)
                self.messages.removeFirst()
                self.messages.insert(ChatMessage(isUser: true, tag: "link", header: "Your request", message: link, messageImage: nil, actionImage: "square.and.arrow.up.on.square"), at: 0)
                self.messages.insert(ChatMessage(isUser: true, tag: "loading", header: "", message: link, messageImage: nil, actionImage: nil), at: 0)
            }
            
     
            let text = try await extractText(text: contents)
            
            let text2embed = text
            Task.detached {
                let vectorResult = try await self.startEmbedding(link: link, text: text2embed)
                Log("embedding done", vectorResult)
            }
            
            let chunks = splitTextIntoChunks(text: text, maxLetters: 600, overlapSentences: 1)
            
            if chunks.count > 15 {
                let chunked = chunks.chunked(into: 15)
                
                var result: [String] = []
                
                for chunk in chunked {
                    if let summary = try await chatChunked(chunks: chunk, summary: result) {
                        guard self.working else {
                            return
                        }
                        result.append(summary)
                        currentChat?.results.append(summary)
                        self.messages.removeFirst()
                        self.messages.insert(ChatMessage(isUser: false, tag: "summary", header: "Part summary", message: summary, messageImage: nil, actionImage: "square.and.arrow.up.on.square"), at: 0)
                        self.messages.insert(ChatMessage(isUser: true, tag: "loading", header: "", message: link, messageImage: nil, actionImage: nil), at: 0)

                    }
                }
                
                
                if result.count > 10 {
                    let chunkedResult = result.chunked(into: 5)
                    var newresult: [String] = []
                    
                    currentChat?.results = []
                    
                    for chunk in chunkedResult {
                        if let summary = try await summuriseChunked(chunks: chunk, summary: result) {
                            guard self.working else {
                                return
                            }
                            newresult.append(summary)
                            currentChat?.results.append(summary)
                            self.messages.removeFirst()
                            self.messages.insert(ChatMessage(isUser: false, tag: "summary", header: "Part summary of summaries", message: summary, messageImage: nil, actionImage: "square.and.arrow.up.on.square"), at: 0)
                            self.messages.insert(ChatMessage(isUser: true, tag: "loading", header: "", message: link, messageImage: nil, actionImage: nil), at: 0)


                        }
                    }
                    
                    var messages: [Message] = [Message(role: "system", content: "You are making summaries for provided texts")]
                    for s in newresult {
                        messages.append(Message(role: "assistant", content: "Previous part: \(s)"))
                    }
                    messages.insert(Message(role: "user", content: "Consolidate the summaries of text parts in one long summary. These parts are not separate articles. It is one text dividided in parts."), at: 0)
                    
                    let finalResult = try await ai.chatGenerate(with: messages)
                    
                    guard self.working else {
                        return
                    }
                    
                    currentChat?.response = finalResult
                    currentChat?.summary = finalResult?.choices.first?.message.content
                    
                    self.messages.removeFirst()
                    self.messages.insert(ChatMessage(isUser: false, tag: "finalsummary", header: "Final summary", message: currentChat?.summary ?? "", messageImage: nil, actionImage: "square.and.arrow.up.on.square"), at: 0)

                    print("final result 2: ", finalResult?.choices.first?.message.content)
                    
                    currentChat?.messages = self.messages
                    let chat = currentChat!
                    self.chats.append(chat)
                    self.saveChats()
                    //currentChat = nil
                    self.working = false

                }
                else {
                    var messages: [Message] = [Message(role: "system", content: "You are making summaries for provided texts")]
                    for s in result {
                        messages.append(Message(role: "assistant", content: "Previous part: \(s)"))
                    }
                    messages.append(Message(role: "user", content: "Consolidate the summaries of text parts in one long summary. These parts are not separate articles. It is one text dividided in parts."))
                    
                    let finalResult = try await ai.chatGenerate(with: messages)
                    
                    guard self.working else {
                        return
                    }
                    
                    currentChat?.response = finalResult
                    currentChat?.summary = finalResult?.choices.first?.message.content
                    
                    self.messages.removeFirst()
                    self.messages.insert(ChatMessage(isUser: false, tag: "finalsummary", header: "Final summary", message: currentChat?.summary ?? "", messageImage: nil, actionImage: "square.and.arrow.up.on.square"), at: 0)
                    
                    print("final result: ", finalResult?.choices.first?.message.content)
                    
                    currentChat?.messages = self.messages
                    let chat = currentChat!
                    self.chats.append(chat)
                    self.saveChats()
                    //currentChat = nil
                    self.working = false

                }
                
                
                
            }
            else {
                let assistanMessages = chunks.map { chunk in
                    return Message(role: "assistant", content: chunk)
                }
                var messages: [Message] = [Message(role: "system", content: "You are making summaries for provided texts")]
                messages.append(contentsOf: assistanMessages)
                messages.append(Message(role: "user", content: "Create please long summary"))
                
                let result = try await ai.chatGenerate(with: messages)
                
                guard self.working else {
                    return
                }
                
                currentChat?.response = result
                currentChat?.summary = result?.choices.first?.message.content
                
                self.messages.removeFirst()
                self.messages.insert(ChatMessage(isUser: false, tag: "finalsummary", header: "Summary", message: currentChat?.summary ?? "", messageImage: nil, actionImage: "square.and.arrow.up.on.square"), at: 0)

                print("final result: ", result?.choices.first?.message.content)
                
                currentChat?.messages = self.messages
                let chat = currentChat!
                self.chats.append(chat)
                self.saveChats()
                //currentChat = nil
                self.working = false

                
            }
            
        }
        catch {
            Log(error)
        }

    }
    
    
    func extractText(text: String) async throws -> String {
        let doc: Document = try SwiftSoup.parse(text)
        let text = try doc.text()
        return text
    }

    
    func splitTextIntoChunks(text: String, maxLetters: Int, overlapSentences: Int) -> [String] {
        let regexPattern = "[^.!?]+[.!?]"
        let regex = try? NSRegularExpression(pattern: regexPattern, options: [])

        var sentences: [String] = []
        var searchRange = NSRange(location: 0, length: text.utf16.count)

        while let match = regex?.firstMatch(in: text, options: [], range: searchRange) {
            if let range = Range(match.range, in: text) {
                sentences.append(String(text[range]))
            }
            searchRange.location = match.range.upperBound
            searchRange.length = text.utf16.count - searchRange.location
        }

        var result: [String] = []
        var currentChunk = ""
        var sentenceCounter = 0

        for sentence in sentences {
            let sentenceWithDelimiter = sentence.trimmingCharacters(in: .whitespacesAndNewlines)

            if currentChunk.count + sentenceWithDelimiter.count <= maxLetters {
                currentChunk += sentenceWithDelimiter
                sentenceCounter += 1
            } else {
                result.append(currentChunk)
                let startIndex = max(0, sentenceCounter - overlapSentences)
                currentChunk = sentences[startIndex...sentenceCounter].joined(separator: " ")
                sentenceCounter += 1
            }
        }

        if !currentChunk.isEmpty {
            result.append(currentChunk)
        }

        return result
    }

   
    @MainActor
    func savePdf(urlString:String, fileName:String) -> String? {
        let url = URL(string: urlString)
        let pdfData = try? Data.init(contentsOf: url!)
        let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
        let pdfNameFromUrl = "Summarly-\(fileName).pdf"
        let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
        do {
            try pdfData?.write(to: actualPath, options: .atomic)
            print("pdf successfully saved!")
            return pdfNameFromUrl
        } catch {
            print("Pdf could not be saved")
        }
        return nil
    }

        func loadPDFText(fileName:String) -> String? {
            do {
                let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                for url in contents {
                    if url.description.contains("\(fileName)") {
                        if let pdfDocument = PDFDocument(url: url) {
                            let pageCount = pdfDocument.pageCount
                            let documentContent = NSMutableAttributedString()

                            for i in 0 ..< pageCount {
                                guard let page = pdfDocument.page(at: i) else { continue }
                                guard let pageContent = page.attributedString else { continue }
                                documentContent.append(pageContent)
                            }
                            return documentContent.string
                        }
                }
            }
                return nil
        } catch {
            print("could not locate pdf file !!!!!!!")
            return nil
        }
            return nil
    }

    
}


extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}


struct Chats: Codable {
    let chats: [ChatModel]
}
