import Foundation

final class News {
    let id: String
    let title: String
    let sectionName: String
    let date: String
    let url: String
    
    init(
        id: String,
        title: String,
        sectionName: String,
        date: String,
        url: String
    ) {
        self.id = id
        self.title = title
        self.sectionName = sectionName
        self.date = date
        self.url = url
    }
}
