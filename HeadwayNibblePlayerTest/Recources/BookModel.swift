

import Foundation

struct BookModel {
    let bookName: String?
    let bookCover: String?
    let bookSections: [BookSectionModel]?
    let sectionCount: Int?
}


struct BookSectionModel {
    let sectionTitle: String?
    let sectionURL: String?
    let sectionNumber: Int?
}

extension BookModel {
    
    static let mockBook = BookModel(bookName: "RamStein", 
                                    bookCover: "bookCoverMock",
                                    bookSections: [BookSectionModel(sectionTitle: "Title 1", sectionURL: "audioName1",
                                                                    sectionNumber: 1),
                                                   BookSectionModel(sectionTitle: "Title 2",
                                                                    sectionURL: "audioName2",
                                                                    sectionNumber: 2)],
                                    sectionCount: 2)
}
