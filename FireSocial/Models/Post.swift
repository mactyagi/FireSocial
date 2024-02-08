//
//  Post.swift
//  FireSocial
//
//  Created by Manu on 07/02/24.
//

import Foundation
import FirebaseFirestore

struct Post: Codable {
    var id: String
    let imageURLs: [String]
    let description: String
    let userId: String
    let creationDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageURLs
        case description
        case userId
        case creationDate
      }
}


extension Post {
    init?(document: DocumentSnapshot) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: document.data() ?? [:]),
              let decodedPost = try? JSONDecoder().decode(Post.self, from: jsonData) else {
            return nil
        }
        self = decodedPost
    }
    
    
    var readableTime: String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        return dateFormatter.string(from: creationDate)
        
    }
}
