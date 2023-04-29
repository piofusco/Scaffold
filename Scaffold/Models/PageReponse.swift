//
//  PageReponse.swift
//  Scaffold
//
//  Created by Michael Pace on 4/25/23.
//

import Foundation

struct PageResponse: Decodable {
    let data: [GiphySearchResult]
    let pagination: Pagination
}

struct Pagination: Decodable {
    let totalCount: Int
    let count: Int
    let offset: Int
}

struct GiphySearchResult: Decodable {
    let id: String
    let title: String
    let url: URL
    let images: GiphySearchResultImages
}

struct GiphySearchResultImages: Decodable {
    let fixedWidthDownsampled: GiphySearchResultImage
}

struct GiphySearchResultImage: Decodable {
    let url: URL
}
