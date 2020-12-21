//
//  ImageTableViewCell.swift
//  UnsplashClient
//
//  Created by Максим Голов on 16.12.2020.
//

import Foundation


// MARK: - QueryService

class QueryService {
    
    // MARK: - Link
    
    enum Link: String {
        case randomPhotos = "https://api.unsplash.com/photos/random"
        case searchPhotos = "https://api.unsplash.com/search/photos"
        case collections = "https://api.unsplash.com/collections"
        case collectionPhotos = "https://api.unsplash.com/collections/:id/photos"
    }
    
    static let pageSize = 20
    
    // MARK: - Internal Methods
    
    func getRandomPhotos(count: Int, completion: @escaping ([Image]?) -> Void) {
        guard let url = urlFrom(link: Link.randomPhotos,
                                queryItems: [URLQueryItem(name: "count", value: "\(count)")]) else { return }
        print(#function + " \(url)")
        query(for: [Image].self, from: url, completion: completion)
    }
    
    func searchPhotos(searchTerm: String, page: Int = 1, completion: @escaping (SearchResult?) -> Void) {
        guard let url = urlFrom(link: Link.searchPhotos,
                                queryItems: [URLQueryItem(name: "query", value: "\(searchTerm)"),
                                             URLQueryItem(name: "per_page", value: "\(QueryService.pageSize)"),
                                             URLQueryItem(name: "page", value: "\(page)")]) else { return }
        print(#function + " \(url)")
        query(for: SearchResult.self, from: url, completion: completion)
    }
    
    func getCollections(page: Int = 1, completion: @escaping ([PhotoCollection]?) -> Void) {
        guard let url = urlFrom(link: Link.collections,
                                queryItems: [URLQueryItem(name: "per_page", value: "\(QueryService.pageSize)"),
                                             URLQueryItem(name: "page", value: "\(page)")]) else { return }
        print(#function + " \(url)")
        query(for: [PhotoCollection].self, from: url, completion: completion)
    }
    
    func getCollectionPhotos(collectionId: String, page: Int = 1, completion: @escaping ([Image]?) -> Void) {
        let urlString = Link.collectionPhotos.rawValue.replacingOccurrences(of: ":id", with: collectionId)
        guard let url = urlFrom(string: urlString,
                                queryItems: [URLQueryItem(name: "per_page", value: "\(QueryService.pageSize)"),
                                             URLQueryItem(name: "page", value: "\(page)")]) else { return }
        print(#function + " \(url)")
        query(for: [Image].self, from: url, completion: completion)
    }
    
    func downloadImageData(from urlString: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(#function + " DataTask error: \(error.localizedDescription)")
            }
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                DispatchQueue.main.async {
                    completion(data)
                }
            }
        }.resume()
    }
    

    // MARK: - Private Methods
    
    private func urlFrom(link: Link, queryItems: [URLQueryItem]) -> URL? {
        return urlFrom(string: link.rawValue, queryItems: queryItems)
    }
    
    private func urlFrom(string: String, queryItems: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(string: string) else { return nil }
        urlComponents.queryItems = queryItems + [URLQueryItem(name: "client_id", value: accessKey)]
        return urlComponents.url
    }
    
    private func query<T: Decodable>(for type: T.Type,
                                     from url: URL,
                                     completion: @escaping (T?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            [weak self] data, response, error in
                if let error = error {
                    print(#function + " DataTask error: \(error.localizedDescription)")
                }
                if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    let result = self?.extract(type, from: data)
                    DispatchQueue.main.async {
                        completion(result)
                    }
                }
        }.resume()
    }
    
    private func extract<T: Decodable>(_ type: T.Type, from data: Data) -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try! decoder.decode(T.self, from: data)
    }
}
