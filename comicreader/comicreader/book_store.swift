import Foundation                                                                               // Date and UUID live here

// 10/31/26 in memory sample data for milestone 1, matches the books in the Figma file, real storage comes in milestone 3
final class book_store {                                                                        // one shared list of books for every screen
    static let shared = book_store()                                                            // the single shared instance

    private(set) var books: [book_item]                                                         // every book, only this class can change it directly

    private init() {                                                                            // private so everyone uses shared
        let now = Date()                                                                        // one timestamp so the recently opened order is stable
        books = [                                                                               // the seven sample books
            book_item(id: UUID(), title: "The Last Light", author: "Nora Ellis", collection: "Volume 1", format: .cbz, status: .reading, current_page: 48, page_count: 160, right_to_left: false, description_text: "Some lights are worth finding your way back to. A lighthouse keeper, a stranger at the door, and an island that has kept its secrets for forty years.", cover_image_name: "cover_the_last_light", last_opened: now),    // the book on the home screen
            book_item(id: UUID(), title: "Orbit, Alone", author: "Jules Moreno", collection: "Volume 1", format: .cbz, status: .reading, current_page: 99, page_count: 160, right_to_left: false, description_text: "A lone astronaut keeps a station running long after the crew has gone home.", cover_image_name: "cover_orbit_alone", last_opened: now.addingTimeInterval(-3_600)),    // opened an hour ago
            book_item(id: UUID(), title: "The Quiet Garden", author: "Aki Tanaka", collection: "Volume 2", format: .cbz, status: .reading, current_page: 36, page_count: 200, right_to_left: true, description_text: "Two neighbors share a garden and slowly share everything else.", cover_image_name: "cover_the_quiet_garden", last_opened: now.addingTimeInterval(-86_400)),    // manga, right to left
            book_item(id: UUID(), title: "After the Rain", author: "Mika Sato", collection: "Volume 1", format: .pdf, status: .on_hold, current_page: 88, page_count: 200, right_to_left: true, description_text: "A city that only exists while it is raining.", cover_image_name: "cover_after_the_rain", last_opened: now.addingTimeInterval(-172_800)),    // on hold pdf
            book_item(id: UUID(), title: "Wildwood", author: "Rowan Blake", collection: "Complete edition", format: .cbz, status: .finished, current_page: 180, page_count: 180, right_to_left: false, description_text: "Three kids follow a path into the forest that was not there yesterday.", cover_image_name: "cover_wildwood", last_opened: now.addingTimeInterval(-259_200)),    // finished
            book_item(id: UUID(), title: "Blue Hours", author: "Léa Martin", collection: "One shot", format: .pdf, status: .finished, current_page: 140, page_count: 140, right_to_left: false, description_text: "Short stories that all happen in the hour after sunset.", cover_image_name: "cover_blue_hours", last_opened: now.addingTimeInterval(-345_600)),    // finished pdf
            book_item(id: UUID(), title: "Paper Planets", author: "Eli Park", collection: "Volume 1", format: .cbz, status: .not_started, current_page: 0, page_count: 120, right_to_left: false, description_text: "A kid builds a solar system out of paper and one of the planets wakes up.", cover_image_name: "cover_paper_planets", last_opened: now.addingTimeInterval(-432_000))    // not started yet
        ]                                                                                       // end sample books
    }                                                                                           // end init

    var current_book: book_item? {                                                              // the book shown in Continue Reading on the home screen
        let reading_books = books.filter { $0.status == .reading }                              // only books in progress
        let newest_first = reading_books.sorted { $0.last_opened > $1.last_opened }             // most recently opened first
        return newest_first.first ?? books.first                                                // fall back to any book
    }                                                                                           // end current_book

    func book(with book_id: UUID) -> book_item? {                                               // find a book by id
        return books.first { $0.id == book_id }                                                 // first match or nil
    }                                                                                           // end book(with:)

    func count(of status: reading_status) -> Int {                                              // how many books have a status
        return books.filter { $0.status == status }.count                                       // filter then count
    }                                                                                           // end count(of:)

    func save(_ book: book_item) {                                                              // add a new book or replace an existing one
        if let existing_index = books.firstIndex(where: { $0.id == book.id }) {                 // the book is already in the list
            books[existing_index] = book                                                        // replace it
        } else {                                                                                // brand new book
            books.insert(book, at: 0)                                                           // put it at the top
        }                                                                                       // end add or replace
    }                                                                                           // end save

    func delete_book(id book_id: UUID) {                                                        // remove a book
        books.removeAll { $0.id == book_id }                                                    // drop every match
    }                                                                                           // end delete_book
}                                                                                               // end book_store
