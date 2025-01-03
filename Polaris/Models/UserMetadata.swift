//
//  UserMetadata.swift
//  Polaris
//
//  Created by Kevin Perez on 1/2/25.
//


struct UserMetadata: Codable {
    let firstName: String
    let lastName: String
    let dateOfBirth: String // ISO8601 formatted string
}
