import Foundation

final class DataResponse: Decodable {
    let status: String
    let userTier: String
    let total: Int
    let startIndex: Int
    let pageSize: Int
    let currentPage: Int
    let pages: Int
    let orderBy: String
    let results: [NewsResponse]
}
