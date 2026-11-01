// 10/31/26 home screen, continue reading card plus browse and import buttons                  // file header
import UIKit                                                                                     // uikit for all the views

final class home_view_controller: UIViewController {                                             // the home screen
    private let scroll_view = UIScrollView()                                                     // whole screen scrolls
    private let content_stack = UIStackView()                                                    // main vertical column
    private let continue_card = UIView()                                                         // continue reading card
    private let card_stack = UIStackView()                                                       // cover plus text row
    private let cover_container = UIView()                                                       // holds the cover shadow
    private let cover_image_view = UIImageView()                                                 // the actual cover art
    private let info_stack = UIStackView()                                                       // right column of the card
    private let title_label = UILabel()                                                          // book title
    private let author_label = UILabel()                                                         // author and collection
    private let progress_label = UILabel()                                                       // page count and percent
    private let resume_row = UIStackView()                                                       // button plus spacer row
    private let resume_spacer = UIView()                                                         // keeps button from stretching
    private let resume_button = UIButton(type: .system)                                          // resume reading button
    private let browse_button = UIButton(type: .system)                                          // browse library row
    private let browse_chevron = UIImageView()                                                   // little arrow on the right
    private let import_button = UIButton(type: .system)                                          // import from files button
    private var current_book_id: UUID?                                                           // book the card is showing

    override var preferredStatusBarStyle: UIStatusBarStyle {                                     // light screen so dark text
        return .darkContent                                                                      // dark status bar content
    }                                                                                            // end preferredStatusBarStyle

    override func viewDidLoad() {                                                                // first time setup
        super.viewDidLoad()                                                                      // let uikit do its thing
        view.backgroundColor = app_theme.background_color                                       // off white background
        title = "TinyView"                                                                       // big nav title
        navigationItem.largeTitleDisplayMode = .always                                          // always show large title
        navigationItem.backButtonTitle = "Home"                                                  // back button on pushed screens
        build_scroll_layout()                                                                    // scroll view and main stack
        build_continue_card()                                                                    // the reading card
        build_browse_button()                                                                    // browse library row
        build_import_button()                                                                    // import from files button
        refresh_continue_card()                                                                  // fill card with data
    }                                                                                            // end viewDidLoad

    override func viewWillAppear(_ animated: Bool) {                                             // every time we come back
        super.viewWillAppear(animated)                                                           // call super first
        refresh_continue_card()                                                                  // progress may have changed
    }                                                                                            // end viewWillAppear

    private func build_scroll_layout() {                                                         // scroll view plus content stack
        scroll_view.translatesAutoresizingMaskIntoConstraints = false                            // using auto layout
        scroll_view.alwaysBounceVertical = true                                                  // bouncy even if short
        view.addSubview(scroll_view)                                                             // put it on screen
        content_stack.translatesAutoresizingMaskIntoConstraints = false                          // using auto layout
        content_stack.axis = .vertical                                                           // stack top to bottom
        content_stack.spacing = 22                                                               // gap between sections
        content_stack.alignment = .fill                                                          // full width children
        scroll_view.addSubview(content_stack)                                                    // stack lives in scroll view
        let content_guide = scroll_view.contentLayoutGuide                                       // scrollable area guide
        let frame_guide = scroll_view.frameLayoutGuide                                           // visible area guide
        NSLayoutConstraint.activate([                                                            // pin everything
            scroll_view.topAnchor.constraint(equalTo: view.topAnchor),                           // scroll top to view top
            scroll_view.leadingAnchor.constraint(equalTo: view.leadingAnchor),                   // scroll left edge
            scroll_view.trailingAnchor.constraint(equalTo: view.trailingAnchor),                 // scroll right edge
            scroll_view.bottomAnchor.constraint(equalTo: view.bottomAnchor),                     // scroll bottom edge
            content_stack.topAnchor.constraint(equalTo: content_guide.topAnchor, constant: 12),  // 12 from the top
            content_stack.leadingAnchor.constraint(equalTo: content_guide.leadingAnchor, constant: 16), // 16 on the left
            content_stack.trailingAnchor.constraint(equalTo: content_guide.trailingAnchor, constant: -16), // 16 on the right
            content_stack.bottomAnchor.constraint(equalTo: content_guide.bottomAnchor, constant: -24), // 24 at the bottom
            content_stack.widthAnchor.constraint(equalTo: frame_guide.widthAnchor, constant: -32) // width minus both sides
        ])                                                                                       // end activate
    }                                                                                            // end build_scroll_layout

    private func build_continue_card() {                                                         // continue reading card
        continue_card.translatesAutoresizingMaskIntoConstraints = false                          // using auto layout
        continue_card.backgroundColor = app_theme.card_color                                    // warm card fill
        continue_card.layer.cornerRadius = 18                                                    // rounded card
        continue_card.layer.cornerCurve = .continuous                                            // smooth corners
        content_stack.addArrangedSubview(continue_card)                                          // card goes first

        card_stack.translatesAutoresizingMaskIntoConstraints = false                             // using auto layout
        card_stack.axis = .horizontal                                                            // cover left text right
        card_stack.spacing = 16                                                                  // gap between them
        card_stack.alignment = .center                                                           // center vertically
        continue_card.addSubview(card_stack)                                                     // row inside the card

        cover_container.translatesAutoresizingMaskIntoConstraints = false                        // using auto layout
        cover_container.backgroundColor = .clear                                                 // only the shadow shows
        cover_container.layer.shadowColor = UIColor.black.cgColor                                // black shadow
        cover_container.layer.shadowOpacity = 0.22                                               // soft shadow
        cover_container.layer.shadowRadius = 5                                                   // blur amount
        cover_container.layer.shadowOffset = CGSize(width: 0, height: 4)                         // shadow drops down
        cover_image_view.translatesAutoresizingMaskIntoConstraints = false                       // using auto layout
        cover_image_view.contentMode = .scaleAspectFill                                          // fill the cover box
        cover_image_view.layer.cornerRadius = 6                                                  // slightly rounded cover
        cover_image_view.clipsToBounds = true                                                    // crop to the corners
        cover_image_view.tintColor = app_theme.muted_color                                      // tint if it falls back to a symbol
        cover_image_view.isAccessibilityElement = false                                          // title label covers it
        cover_container.addSubview(cover_image_view)                                             // image inside container
        card_stack.addArrangedSubview(cover_container)                                           // cover on the left

        info_stack.axis = .vertical                                                              // text stacked
        info_stack.spacing = 5                                                                   // tight text spacing
        info_stack.alignment = .fill                                                             // full width rows
        card_stack.addArrangedSubview(info_stack)                                                // text on the right

        title_label.font = UIFont.systemFont(ofSize: 21, weight: .semibold)                      // big bold title
        title_label.textColor = app_theme.ink_color                                             // main text color
        title_label.numberOfLines = 2                                                            // wrap to two lines max
        info_stack.addArrangedSubview(title_label)                                               // title first

        author_label.font = UIFont.systemFont(ofSize: 13, weight: .regular)                      // small author text
        author_label.textColor = app_theme.muted_color                                          // gray text
        author_label.numberOfLines = 1                                                           // one line only
        info_stack.addArrangedSubview(author_label)                                              // author second

        progress_label.font = UIFont.systemFont(ofSize: 12, weight: .regular)                    // smaller progress text
        progress_label.textColor = app_theme.muted_color                                        // gray text
        progress_label.numberOfLines = 1                                                         // one line only
        info_stack.addArrangedSubview(progress_label)                                            // progress third

        var resume_config = UIButton.Configuration.filled()                                      // filled button style
        resume_config.baseBackgroundColor = app_theme.accent_color                              // terracotta fill
        resume_config.baseForegroundColor = .white                                               // white text and icon
        resume_config.image = UIImage(systemName: "book")                                        // book icon
        resume_config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15) // 15pt icon
        resume_config.imagePlacement = .leading                                                  // icon before text
        resume_config.imagePadding = 7                                                           // gap icon to text
        var resume_title = AttributedString("Resume reading")                                    // button text
        resume_title.font = UIFont.systemFont(ofSize: 14, weight: .semibold)                     // 14 semibold
        resume_config.attributedTitle = resume_title                                             // use styled title
        resume_config.cornerStyle = .fixed                                                       // use our own radius
        resume_config.background.cornerRadius = 10                                               // rounded button
        resume_config.contentInsets = NSDirectionalEdgeInsets(top: 9, leading: 14, bottom: 9, trailing: 14) // button padding
        resume_button.configuration = resume_config                                              // apply the config
        resume_button.accessibilityLabel = "Resume reading"                                      // voiceover label
        resume_button.setContentHuggingPriority(.required, for: .horizontal)                     // stay as small as content
        resume_button.setContentCompressionResistancePriority(.required, for: .horizontal)       // never squish the text
        resume_button.addAction(UIAction { [weak self] _ in                                      // tap handler
            self?.resume_tapped()                                                                // open the reader
        }, for: .touchUpInside)                                                                  // end resume action

        resume_spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)                   // spacer takes leftover room
        resume_row.axis = .horizontal                                                            // button then spacer
        resume_row.alignment = .center                                                           // center vertically
        resume_row.spacing = 0                                                                   // no gap needed
        resume_row.addArrangedSubview(resume_button)                                             // button on the left
        resume_row.addArrangedSubview(resume_spacer)                                             // empty space after
        info_stack.addArrangedSubview(resume_row)                                                // row goes last
        info_stack.setCustomSpacing(11, after: progress_label)                                   // 5 plus 6 extra above the button

        NSLayoutConstraint.activate([                                                            // card constraints
            card_stack.topAnchor.constraint(equalTo: continue_card.topAnchor, constant: 16),     // 16 padding top
            card_stack.leadingAnchor.constraint(equalTo: continue_card.leadingAnchor, constant: 16), // 16 padding left
            card_stack.trailingAnchor.constraint(equalTo: continue_card.trailingAnchor, constant: -16), // 16 padding right
            card_stack.bottomAnchor.constraint(equalTo: continue_card.bottomAnchor, constant: -16), // 16 padding bottom
            cover_container.widthAnchor.constraint(equalToConstant: 96),                         // cover width
            cover_container.heightAnchor.constraint(equalToConstant: 138),                       // cover height
            cover_image_view.topAnchor.constraint(equalTo: cover_container.topAnchor),           // image fills top
            cover_image_view.leadingAnchor.constraint(equalTo: cover_container.leadingAnchor),   // image fills left
            cover_image_view.trailingAnchor.constraint(equalTo: cover_container.trailingAnchor), // image fills right
            cover_image_view.bottomAnchor.constraint(equalTo: cover_container.bottomAnchor)      // image fills bottom
        ])                                                                                       // end activate
    }                                                                                            // end build_continue_card

    private func build_browse_button() {                                                         // browse library row
        var browse_config = UIButton.Configuration.plain()                                       // plain button style
        browse_config.baseForegroundColor = app_theme.ink_color                                 // dark text
        var browse_title = AttributedString("Browse library")                                    // row text
        browse_title.font = UIFont.systemFont(ofSize: 16, weight: .semibold)                     // 16 semibold
        browse_config.attributedTitle = browse_title                                             // use styled title
        browse_config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 44) // room for chevron
        browse_button.configuration = browse_config                                              // apply the config
        browse_button.translatesAutoresizingMaskIntoConstraints = false                          // using auto layout
        browse_button.contentHorizontalAlignment = .leading                                      // text hugs the left
        browse_button.backgroundColor = app_theme.surface_color                                 // white row
        browse_button.layer.borderWidth = 1                                                      // thin border
        browse_button.layer.borderColor = app_theme.border_color.cgColor                        // light gray border
        browse_button.layer.cornerRadius = 14                                                    // rounded row
        browse_button.layer.cornerCurve = .continuous                                            // smooth corners
        browse_button.accessibilityLabel = "Browse library"                                      // voiceover label
        browse_button.addAction(UIAction { [weak self] _ in                                      // tap handler
            self?.browse_tapped()                                                                // open the library
        }, for: .touchUpInside)                                                                  // end browse action
        content_stack.addArrangedSubview(browse_button)                                          // second section

        browse_chevron.translatesAutoresizingMaskIntoConstraints = false                         // using auto layout
        browse_chevron.image = UIImage(systemName: "chevron.right")                              // right arrow icon
        browse_chevron.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16) // 16pt arrow
        browse_chevron.tintColor = app_theme.muted_color                                        // gray arrow
        browse_chevron.contentMode = .scaleAspectFit                                             // keep its shape
        browse_chevron.isUserInteractionEnabled = false                                          // taps go to the button
        browse_chevron.isAccessibilityElement = false                                            // just decoration
        browse_button.addSubview(browse_chevron)                                                 // arrow on top of the button
        NSLayoutConstraint.activate([                                                            // chevron constraints
            browse_chevron.trailingAnchor.constraint(equalTo: browse_button.trailingAnchor, constant: -16), // 16 from the right
            browse_chevron.centerYAnchor.constraint(equalTo: browse_button.centerYAnchor)        // centered vertically
        ])                                                                                       // end activate
    }                                                                                            // end build_browse_button

    private func build_import_button() {                                                         // import from files button
        var import_config = UIButton.Configuration.plain()                                       // plain so no fill
        import_config.baseForegroundColor = app_theme.accent_color                              // terracotta text and icon
        import_config.image = UIImage(systemName: "plus")                                        // plus icon
        import_config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 18) // 18pt icon
        import_config.imagePlacement = .leading                                                  // icon before text
        import_config.imagePadding = 8                                                           // gap icon to text
        var import_title = AttributedString("Import from Files")                                 // button text
        import_title.font = UIFont.systemFont(ofSize: 16, weight: .semibold)                     // 16 semibold
        import_config.attributedTitle = import_title                                             // use styled title
        import_config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16) // button padding
        import_button.configuration = import_config                                              // apply the config
        import_button.translatesAutoresizingMaskIntoConstraints = false                          // using auto layout
        import_button.contentHorizontalAlignment = .center                                       // centered content
        import_button.backgroundColor = .clear                                                   // no fill
        import_button.layer.borderWidth = 1.5                                                    // accent outline
        import_button.layer.borderColor = app_theme.accent_color.cgColor                        // terracotta border
        import_button.layer.cornerRadius = 14                                                    // rounded button
        import_button.layer.cornerCurve = .continuous                                            // smooth corners
        import_button.accessibilityLabel = "Import from Files"                                   // voiceover label
        import_button.addAction(UIAction { [weak self] _ in                                      // tap handler
            self?.import_tapped()                                                                // open add book
        }, for: .touchUpInside)                                                                  // end import action
        content_stack.addArrangedSubview(import_button)                                          // last section
    }                                                                                            // end build_import_button

    func refresh_continue_card() {                                                               // fill card from the store
        guard let book = book_store.shared.current_book else {                                   // nothing being read
            current_book_id = nil                                                                // forget old book
            continue_card.isHidden = true                                                        // hide the card
            return                                                                               // nothing else to do
        }                                                                                        // end guard
        current_book_id = book.id                                                                // remember for resume
        continue_card.isHidden = false                                                           // show the card
        cover_image_view.image = app_theme.cover_image(named: book.cover_image_name)            // cover art
        title_label.text = book.title                                                            // book title
        author_label.text = book.author + " · " + book.collection                                // author dot collection
        progress_label.text = "Page \(book.current_page) of \(book.page_count) · \(book.progress_percent)%" // page progress
        continue_card.accessibilityLabel = "Continue reading \(book.title)"                      // voiceover hint for card
    }                                                                                            // end refresh_continue_card

    private func resume_tapped() {                                                               // resume reading tapped
        guard let book_id = current_book_id else { return }                                      // no book no reader
        let reader_screen = reader_view_controller(book_id: book_id)                             // make the reader
        navigationController?.pushViewController(reader_screen, animated: true)                  // push it
    }                                                                                            // end resume_tapped

    private func browse_tapped() {                                                               // browse library tapped
        let library_screen = library_view_controller()                                           // make the library
        navigationController?.pushViewController(library_screen, animated: true)                 // push it
    }                                                                                            // end browse_tapped

    private func import_tapped() {                                                               // import from files tapped
        let edit_screen = edit_book_view_controller(book: nil) { [weak self] saved_book in       // add book mode
            book_store.shared.save(saved_book)                                                   // presenter saves the book
            self?.refresh_continue_card()                                                        // update the card
        }                                                                                        // end on_save closure
        present(app_navigation_controller(rootViewController: edit_screen), animated: true)      // show as a sheet
    }                                                                                            // end import_tapped
}                                                                                                // end home_view_controller
