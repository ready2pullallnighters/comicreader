import Foundation                                                                               // Date and UUID live here

// 10/31/26 the book model and its reading status, every screen reads from this
enum reading_status: Int, CaseIterable {                                                        // where the reader is with a book
    case not_started                                                                            // never opened
    case reading                                                                                // in progress
    case on_hold                                                                                // paused
    case finished                                                                               // read to the end

    var display_name: String {                                                                  // text shown in the UI
        switch self {                                                                           // pick by case
        case .not_started: return "Not started"                                                 // not started label
        case .reading: return "Reading"                                                         // reading label
        case .on_hold: return "On hold"                                                         // on hold label
        case .finished: return "Finished"                                                       // finished label
        }                                                                                       // end switch
    }                                                                                           // end display_name
}                                                                                               // end reading_status

enum book_format: String {                                                                      // file types the app will open in milestone 3
    case cbz = "CBZ"                                                                            // comic book zip
    case pdf = "PDF"                                                                            // pdf document
}                                                                                               // end book_format

struct book_item {                                                                              // one book in the library
    let id: UUID                                                                                // stable id so screens can find the same book again
    var title: String                                                                           // book title
    var author: String                                                                          // author or artist
    var collection: String                                                                      // series, volume or shelf name
    var format: book_format                                                                     // cbz or pdf
    var status: reading_status                                                                  // reading status
    var current_page: Int                                                                       // last page the reader was on
    var page_count: Int                                                                         // total pages in the book
    var right_to_left: Bool                                                                     // manga mode, pages turn right to left
    var description_text: String                                                                // short blurb about the book
    var cover_image_name: String?                                                               // asset catalog image name, nil for books added in the app
    var last_opened: Date                                                                       // used to sort by recently opened

    var progress: Float {                                                                       // 0 to 1 for progress bars
        guard page_count > 0 else { return 0 }                                                  // avoid dividing by zero
        return Float(current_page) / Float(page_count)                                          // pages read over total pages
    }                                                                                           // end progress

    var progress_percent: Int {                                                                 // whole number percent for labels
        return Int((progress * 100).rounded())                                                  // round to the nearest percent
    }                                                                                           // end progress_percent
}                                                                                               // end book_item
