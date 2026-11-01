// 10/31/26 book_cell, one row in the library list (cover, title, meta, status, progress)
import UIKit                                                                    // need uikit for the cell stuff

final class book_cell: UITableViewCell {                                        // custom row cell for a book
    static let reuse_identifier = "book_cell"                                   // id we register and dequeue with

    private let cover_container = UIView()                                      // holds the shadow for the cover
    private let cover_image_view = UIImageView()                                // the actual cover picture
    private let title_label = app_theme.make_label("", size: 16, weight: .semibold, color: app_theme.ink_color)  // book title
    private let meta_label = app_theme.make_label("", size: 13, weight: .regular, color: app_theme.muted_color)  // author and format
    private let status_label = app_theme.make_label("", size: 12, weight: .medium, color: app_theme.muted_color) // reading status text
    private let progress_bar = UIProgressView(progressViewStyle: .bar)          // little progress bar
    private let percent_label = app_theme.make_label("", size: 12, weight: .medium, color: app_theme.muted_color) // percent text on the right
    private let finished_green = app_theme.hex_color(0x5F7F5A)                  // green tint for finished books

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) { // main init for code made cells
        super.init(style: style, reuseIdentifier: reuseIdentifier)              // let uikit do its setup first
        build_layout()                                                          // then build our views
    }                                                                           // end init

    required init?(coder: NSCoder) {                                            // storyboard init, not used
        fatalError("init(coder:) has not been implemented")                     // we only build in code
    }                                                                           // end init coder

    private func build_layout() {                                               // sets up all the subviews
        backgroundColor = .white                                                // white row like the figma
        accessoryType = .disclosureIndicator                                    // chevron on the right side

        cover_container.translatesAutoresizingMaskIntoConstraints = false       // auto layout for the cover box
        cover_container.layer.shadowColor = UIColor.black.cgColor               // black shadow
        cover_container.layer.shadowOpacity = 0.18                              // pretty soft shadow
        cover_container.layer.shadowRadius = 2                                  // small blur
        cover_container.layer.shadowOffset = CGSize(width: 0, height: 2)        // shadow sits a bit below
        cover_container.clipsToBounds = false                                   // dont clip or the shadow disappears

        cover_image_view.translatesAutoresizingMaskIntoConstraints = false      // auto layout for the image
        cover_image_view.contentMode = .scaleAspectFill                         // fill the box and crop extra
        cover_image_view.layer.cornerRadius = 4                                 // little rounded corners
        cover_image_view.clipsToBounds = true                                   // clip so corners actually round
        cover_image_view.backgroundColor = app_theme.fill_color                 // fill behind placeholder symbol
        cover_image_view.tintColor = app_theme.muted_color                      // tint for the placeholder symbol
        cover_container.addSubview(cover_image_view)                            // put image inside the shadow box

        progress_bar.translatesAutoresizingMaskIntoConstraints = false          // auto layout for the bar
        progress_bar.progressTintColor = app_theme.accent_color                 // default tint is accent
        progress_bar.trackTintColor = app_theme.fill_color                      // light track behind it

        percent_label.translatesAutoresizingMaskIntoConstraints = false         // auto layout for the percent
        percent_label.textAlignment = .right                                    // numbers line up on the right

        let progress_row = UIStackView(arrangedSubviews: [progress_bar, percent_label]) // bar plus percent side by side
        progress_row.axis = .horizontal                                         // left to right row
        progress_row.spacing = 8                                                // gap between bar and percent
        progress_row.alignment = .center                                        // center them vertically

        let info_stack = UIStackView(arrangedSubviews: [title_label, meta_label, status_label, progress_row]) // all the text stuff
        info_stack.axis = .vertical                                             // top to bottom
        info_stack.spacing = 3                                                  // tight spacing like figma
        info_stack.setCustomSpacing(3 + 4, after: meta_label)                   // 4 extra above the status
        info_stack.setCustomSpacing(3 + 3, after: status_label)                 // 3 extra above the progress row

        let main_stack = UIStackView(arrangedSubviews: [cover_container, info_stack]) // cover on left, info on right
        main_stack.translatesAutoresizingMaskIntoConstraints = false            // auto layout for the main row
        main_stack.axis = .horizontal                                           // left to right
        main_stack.spacing = 14                                                 // gap between cover and text
        main_stack.alignment = .center                                          // center everything vertically
        contentView.addSubview(main_stack)                                      // add to the cell content

        let bottom_pin = main_stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12) // 12 from the bottom
        bottom_pin.priority = UILayoutPriority(999)                             // 999 so the first 44pt pass doesnt log a conflict
        NSLayoutConstraint.activate([                                           // all the constraints at once
            cover_container.widthAnchor.constraint(equalToConstant: 52),        // cover width from figma
            cover_container.heightAnchor.constraint(equalToConstant: 74),       // cover height from figma
            cover_image_view.topAnchor.constraint(equalTo: cover_container.topAnchor), // image fills top
            cover_image_view.bottomAnchor.constraint(equalTo: cover_container.bottomAnchor), // image fills bottom
            cover_image_view.leadingAnchor.constraint(equalTo: cover_container.leadingAnchor), // image fills left
            cover_image_view.trailingAnchor.constraint(equalTo: cover_container.trailingAnchor), // image fills right
            percent_label.widthAnchor.constraint(equalToConstant: 38),          // fixed width so bars line up
            main_stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12), // 12 from the top
            bottom_pin,                                                         // bottom pin from above
            main_stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16), // 16 on the left
            main_stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8) // 8 on the right
        ])                                                                      // end activate
    }                                                                           // end build_layout

    func configure(with book: book_item) {                                      // fills the cell with a book
        cover_image_view.image = app_theme.cover_image(named: book.cover_image_name) // cover or placeholder symbol
        title_label.text = book.title                                           // show the title
        meta_label.text = book.author + " · " + book.format.rawValue            // author dot format
        status_label.text = book.status.display_name                            // like Reading or On hold
        percent_label.text = "\(book.progress_percent)%"                        // percent number
        progress_bar.setProgress(book.progress, animated: false)                // fill the bar, no animation
        progress_bar.trackTintColor = app_theme.fill_color                      // track always the light fill

        switch book.status {                                                    // pick the bar color by status
        case .reading:                                                          // currently reading
            progress_bar.progressTintColor = app_theme.accent_color             // terracotta accent
        case .on_hold:                                                          // paused for now
            progress_bar.progressTintColor = app_theme.muted_color              // gray for on hold
        case .finished:                                                         // all done
            progress_bar.progressTintColor = finished_green                     // green for finished
        case .not_started:                                                      // never opened
            progress_bar.progressTintColor = app_theme.fill_color               // just the track shows
        }                                                                       // end switch

        accessibilityLabel = "\(book.title), by \(book.author), \(book.status.display_name), \(book.progress_percent) percent" // voiceover summary
    }                                                                           // end configure
}                                                                               // end book_cell
