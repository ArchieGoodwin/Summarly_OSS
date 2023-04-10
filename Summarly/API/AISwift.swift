//
//  AISwift.swift
//  strAI
//
//  Created by Sergey Dikarev on 10.12.2022.
//

import Foundation
import MobileCoreServices
import UniformTypeIdentifiers
import PineconeSwift

import Accelerate

public enum OpenAIError: Error {
    case genericError(error: Error)
    case decodingError(error: Error)
    case incorrectUrl
}

public enum ResponseImageFormat: String {
    case url
    case b64_json
}

public enum ResponseAIImageSize: String {
    case s256 = "256x256"
    case s512 = "512x512"
    case s1024 = "1024x1024"
}

public class AISwift {
    fileprivate(set) var token: String?
    
    public init(authToken: String) {
        self.token = authToken
    }
}

extension AISwift {
    /// Send a Completion to the OpenAI API
    /// - Parameters:
    ///   - prompt: The Text Prompt
    ///   - model: The AI Model to Use. Set to `OpenAIModelType.gpt3(.davinci)` by default which is the most capable model
    ///   - maxTokens: The limit character for the returned response, defaults to 500
    ///   - completionHandler: Returns an OpenAI Data Model
    public func sendCompletion(with prompt: String, model: OpenAIModelType = .gpt3(.davinci), maxTokens: Int = 500, completionHandler: @escaping (Result<OpenAI, OpenAIError>) -> Void) {
        let endpoint = Endpoint.completions
        let body = CommandText(prompt: prompt, model: model.modelName, maxTokens: maxTokens)
        let request = prepareRequest(endpoint, body: body)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(.genericError(error: error)))
            } else if let data = data {
                do {
                    let res = try JSONDecoder().decode(OpenAI.self, from: data)
                    print(res)
                    completionHandler(.success(res))
                } catch {
                    print(error.localizedDescription)
                    completionHandler(.failure(.decodingError(error: error)))
                }
            }
        }
        
        task.resume()
    }
    

    public func chatGenerate(with messages: [Message], model: OpenAIModelType = .chatGPT(.turbo)) async throws -> ChatResponse? {
        let endpoint = Endpoint.chatcompletions
        let body = ChatRequest(model: model.modelName, messages: messages)
        let request = prepareRequest(endpoint, body: body)
        
        let session = URLSession.shared
        let (data, _) = try await session.data(for: request)
        print(NSString(string: String(decoding: data, as: UTF8.self)))

        let res = try JSONDecoder().decode(ChatResponse.self, from: data)
        print(res)
        
        return res
    }
    
    public func fetchEmbeddings(with messages: [String], model: OpenAIModelType = .embed(.ada002)) async throws -> [EmbedResult] {
        do {
            let endpoint = Endpoint.embeddings
            let body = EmbedModel(model: model.modelName, input: messages)
            let request = prepareRequest(endpoint, body: body)
            
            let session = URLSession.shared
            let (data, _) = try await session.data(for: request)
            //print(NSString(string: String(decoding: data, as: UTF8.self)))

            let res = try JSONDecoder().decode(EmbedResponse.self, from: data)
            let result = res.data.map { emb in
                Log("vectors fetched", emb.embedding.count)
                return EmbedResult(index: emb.index, embedding: emb.embedding, text: messages[emb.index])
            }

            return result
        }
        catch {
            Log(error)
            return []
        }
        
    }
    
    public func loadLink(with link: String) async throws -> String {
    
        if let url = URL(string: link) {
            do {
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                
                let session = URLSession.shared
                let (data, _) = try await session.data(for: request)
                let res = String(decoding: data, as: UTF8.self)
                return res
            }
            catch {
                throw OpenAIError.incorrectUrl
            }
            
        }
        else {
            throw OpenAIError.incorrectUrl
        }
        
    }
    
    public func imageGeneration(with prompt: String, number: Int = 1, size: ResponseAIImageSize = .s512, format: ResponseImageFormat = .url, user: String? = nil, completionHandler: @escaping (Result<AIImageResponse, OpenAIError>) -> Void) {
        let endpoint = Endpoint.images
        let body = CommandImage(prompt: prompt, number: number, size: size, format: format, user: user)
        let request = prepareRequest(endpoint, body: body)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(.genericError(error: error)))
            } else if let data = data {
                do {
                    let res = try JSONDecoder().decode(AIImageResponse.self, from: data)
                    print(res)
                    completionHandler(.success(res))
                } catch {
                    print(error.localizedDescription)
                    completionHandler(.failure(.decodingError(error: error)))
                }
            }
        }
        
        task.resume()
    }
    
    private func prepareRequest<BodyType: Encodable>(_ endpoint: Endpoint, body: BodyType) -> URLRequest {
        var urlComponents = URLComponents(url: URL(string: endpoint.baseURL())!, resolvingAgainstBaseURL: true)
        urlComponents?.path = endpoint.path
        var request = URLRequest(url: urlComponents!.url!)
        request.httpMethod = endpoint.method
        
        if let token = self.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(body) {
            request.httpBody = encoded
        }
        
        return request
    }
    
    private func calculateDotProduct(question: [Double], doc: [Double]) -> Double {
        let n = vDSP_Length(question.count)
        var c: Double = .nan

        let stride = vDSP_Stride(1)

        vDSP_dotprD(question, stride,
                   doc, stride,
                   &c,
                   n)
        
        print("fetchEmbeddings", c)
        return c
    }
}



extension URL {
   
    func mimeType() -> String {
        let pathExtension = self.pathExtension
        if let type = UTType(filenameExtension: pathExtension) {
            if let mimetype = type.preferredMIMEType {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
    
    func conforms(to type: UTType) -> Bool{
        let uttype = UTType(mimeType: mimeType())
        
        return uttype?.conforms(to: type) ?? false
        
        
    }
}
