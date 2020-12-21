//
//  PhotoCollection.swift
//  UnsplashClient
//
//  Created by Максим Голов on 20.12.2020.
//

import Foundation

struct PhotoCollection: Decodable {
    let id: String
    let title: String
    let description: String?
    let publishedAt: Date
    // Иногда API возвращает неправильное значение (На самом деле в коллекции иное количество фото)
    let totalPhotos: Int
    let coverPhoto: Image
    let user: User
    let links: Links
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, publishedAt = "published_at", totalPhotos = "total_photos", coverPhoto = "cover_photo", user, links
    }
}
