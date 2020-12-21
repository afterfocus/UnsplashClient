//
//  Image.swift
//  UnsplashClient
//
//  Created by Максим Голов on 16.12.2020.
//

import Foundation

struct User: Decodable {
    let name: String
}

struct Exif: Decodable {
    let make: String?
    let model: String?
}

struct Urls: Decodable {
    let full: String
    let regular: String
}

struct Links: Decodable {
    let html: String
}

struct SearchResult: Decodable {
    let totalPages: Int
    let images: [Image]
    
    enum CodingKeys: String, CodingKey {
        case totalPages = "total_pages", images = "results"
    }
}

struct Image: Decodable {
    let id: String
    let createdAt: Date
    let width: Int
    let height: Int
    let likes: Int
    let description: String?
    let exif: Exif?
    let user: User
    let urls: Urls
    let links: Links
    
    enum CodingKeys: String, CodingKey {
        case id, createdAt = "created_at", width, height, likes, description, exif, user, urls, links
    }
}
