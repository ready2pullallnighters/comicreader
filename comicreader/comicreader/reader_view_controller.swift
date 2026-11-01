// 10/31/26 reader screen, dark comic page view with the bottom controls overlay
import UIKit // need UIKit for all the views

final class reader_view_controller: UIViewController, UIScrollViewDelegate { // the reader screen
    private let book_id: UUID // which book we are reading
    private var current_book: book_item? // local copy of the book, refreshed after saves
    private var controls_hidden = false // true when the user tapped to hide the chrome
    private let scroll_view = UIScrollView() // lets the page zoom and scroll
    private let page_view = UIView() // the paper page itself
    private let running_head_title_label = UILabel() // book title at the top left of the page
    private let running_head_chapter_label = UILabel() // chapter name at the top right of the page
    private let page_number_label = app_theme.make_label("", size: 8) // little number at the bottom of the page
    private let controls_view = UIView() // dark overlay at the bottom
    private let left_page_button = UIButton(type: .system) // left chevron button
    private let right_page_button = UIButton(type: .system) // right chevron button
    private let page_status_label = app_theme.make_label("Page 48 of 160", size: 15, weight: .semibold, color: .white) // page x of y text
    private let page_slider = UISlider() // scrub through pages
    private let layout_control = UISegmentedControl(items: ["Single", "Spread", "Vertical"]) // reading layout picker

    init(book_id: UUID) { // make a reader for one book
        self.book_id = book_id // remember the id
        super.init(nibName: nil, bundle: nil) // no nib, all code
    } // end init

    required init?(coder: NSCoder) { // storyboard init we never use
        fatalError("init(coder:) has not been implemented") // crash on purpose
    } // end init coder

    override var preferredStatusBarStyle: UIStatusBarStyle { // white status bar on the dark screen
        return .lightContent // light text
    } // end preferredStatusBarStyle

    override func viewDidLoad() { // build everything once
        super.viewDidLoad() // let UIKit do its thing
        view.backgroundColor = app_theme.reader_background_color // dark reader background
        navigationItem.largeTitleDisplayMode = .never // small title only here
        guard var found_book = book_store.shared.book(with: book_id) else { // look up the book
            DispatchQueue.main.async { [weak self] in // wait a tick so we are on the stack
                self?.navigationController?.popViewController(animated: true) // book is gone so go back
            } // end async
            return // nothing else to build
        } // end guard
        found_book.last_opened = Date() // mark it opened right now
        book_store.shared.save(found_book) // save the opened time
        current_book = found_book // keep our copy
        title = found_book.title // nav bar title
        setup_nav_bar() // dark bar and edit button
        build_page() // the comic page
        build_controls() // the bottom overlay
        build_layout() // all the constraints
        setup_gestures() // tap and double tap
        update_controls() // fill in the page numbers
        setNeedsStatusBarAppearanceUpdate() // make sure the status bar goes light
    } // end viewDidLoad

    override func viewWillAppear(_ animated: Bool) { // every time we show up
        super.viewWillAppear(animated) // call super
        navigationController?.navigationBar.tintColor = .white // white back arrow and edit button
    } // end viewWillAppear

    override func viewWillDisappear(_ animated: Bool) { // leaving the reader
        super.viewWillDisappear(animated) // call super
        navigationController?.navigationBar.tintColor = app_theme.accent_color // put the normal tint back
        if controls_hidden { // nav bar might still be hidden
            navigationController?.setNavigationBarHidden(false, animated: animated) // bring it back for the other screens
        } // end if hidden
    } // end viewWillDisappear

    // MARK: nav bar

    private func setup_nav_bar() { // dark bar only for this screen
        let bar_appearance = UINavigationBarAppearance() // new appearance
        bar_appearance.configureWithOpaqueBackground() // solid bar
        bar_appearance.backgroundColor = app_theme.reader_bar_color // dark bar color
        bar_appearance.shadowColor = .clear // no line under the bar
        bar_appearance.titleTextAttributes = [ // title style
            .foregroundColor: UIColor.white, // white title
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold) // 15 semibold
        ] // end title attributes
        bar_appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white] // white back text
        navigationItem.standardAppearance = bar_appearance // normal state
        navigationItem.scrollEdgeAppearance = bar_appearance // scrolled to top state
        navigationItem.compactAppearance = bar_appearance // landscape state
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(edit_tapped)) // edit button
    } // end setup_nav_bar

    @objc private func edit_tapped() { // open the edit sheet
        guard let book = current_book else { return } // need a book to edit
        let edit_screen = edit_book_view_controller(book: book) { [weak self] saved_book in // edit this book
            book_store.shared.save(saved_book) // presenter saves to the store
            self?.reload_book() // refresh our copy and the screen
        } // end on_save closure
        present(app_navigation_controller(rootViewController: edit_screen), animated: true) // show it as a sheet
    } // end edit_tapped

    private func reload_book() { // grab the latest book from the store
        guard let fresh_book = book_store.shared.book(with: book_id) else { return } // still there?
        current_book = fresh_book // swap in the new copy
        title = fresh_book.title // title might have changed
        update_controls() // redraw numbers and arrows
    } // end reload_book

    // MARK: page

    private func build_page() { // the paper page with the panels
        scroll_view.translatesAutoresizingMaskIntoConstraints = false // using constraints
        scroll_view.delegate = self // for zooming
        scroll_view.minimumZoomScale = 1 // no zooming out
        scroll_view.maximumZoomScale = 3 // up to 3x
        scroll_view.showsVerticalScrollIndicator = false // hide bars
        scroll_view.showsHorizontalScrollIndicator = false // hide bars
        scroll_view.backgroundColor = .clear // see the dark background
        view.addSubview(scroll_view) // add to the screen
        page_view.translatesAutoresizingMaskIntoConstraints = false // using constraints
        page_view.backgroundColor = app_theme.paper_color // paper color
        page_view.layer.shadowColor = UIColor.black.cgColor // black shadow
        page_view.layer.shadowOpacity = 0.4 // fairly strong
        page_view.layer.shadowRadius = 11 // soft blur
        page_view.layer.shadowOffset = CGSize(width: 0, height: 4) // drop down a bit
        scroll_view.addSubview(page_view) // page goes in the scroll view
        let running_head_row = UIStackView(arrangedSubviews: [running_head_title_label, running_head_chapter_label]) // top row of tiny text
        running_head_row.axis = .horizontal // side by side
        running_head_row.distribution = .equalSpacing // push them to the edges
        running_head_row.alignment = .center // line them up
        running_head_title_label.textAlignment = .left // title on the left
        running_head_chapter_label.textAlignment = .right // chapter on the right
        running_head_title_label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal) // title truncates first
        running_head_title_label.setContentHuggingPriority(.required, for: .vertical) // stay short
        running_head_chapter_label.setContentHuggingPriority(.required, for: .vertical) // stay short
        running_head_chapter_label.attributedText = running_head_text("CHAPTER THREE · THE KEEPER") // chapter text
        let establishing_panel = make_panel(image_name: "page_island_at_dusk") // big wide panel
        let narration_box = UIView() // caption box in the corner
        narration_box.translatesAutoresizingMaskIntoConstraints = false // using constraints
        narration_box.backgroundColor = app_theme.narration_color // cream caption
        narration_box.layer.borderWidth = 0.8 // thin border
        narration_box.layer.borderColor = app_theme.hex_color(0x353E3A).cgColor // dark border
        let narration_label = UILabel() // caption text
        narration_label.translatesAutoresizingMaskIntoConstraints = false // using constraints
        narration_label.text = "By dusk, the island had gone quiet." // caption words
        narration_label.font = app_theme.serif_font(size: 10, italic: true) // serif italic
        narration_label.textColor = app_theme.hex_color(0x35403D) // caption ink
        narration_label.numberOfLines = 0 // wrap
        narration_box.addSubview(narration_label) // label inside box
        establishing_panel.addSubview(narration_box) // box on top of the image
        let left_panel = make_panel(image_name: "page_lighthouse_door") // story panel left
        let left_balloon = make_balloon(text: "I thought no one lived here anymore.") // first balloon
        left_panel.addSubview(left_balloon) // balloon over the art
        let right_panel = make_panel(image_name: "page_keeper_answers") // story panel right
        let right_balloon = make_balloon(text: "Someone has to keep the light on.") // second balloon
        right_panel.addSubview(right_balloon) // balloon over the art
        let story_row = UIStackView(arrangedSubviews: [left_panel, right_panel]) // two tall panels
        story_row.axis = .horizontal // side by side
        story_row.distribution = .fillEqually // same width
        story_row.spacing = 6 // gutter
        story_row.setContentHuggingPriority(UILayoutPriority(1), for: .vertical) // take the leftover height
        story_row.setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical) // can shrink too
        page_number_label.font = app_theme.serif_font(size: 8) // serif number
        page_number_label.textColor = app_theme.page_ink_color // gray ink
        page_number_label.textAlignment = .center // centered
        page_number_label.setContentHuggingPriority(.required, for: .vertical) // stay short
        page_number_label.setContentCompressionResistancePriority(.required, for: .vertical) // never squish
        let page_stack = UIStackView(arrangedSubviews: [running_head_row, establishing_panel, story_row, page_number_label]) // whole page column
        page_stack.translatesAutoresizingMaskIntoConstraints = false // using constraints
        page_stack.axis = .vertical // top to bottom
        page_stack.spacing = 6 // gap between rows
        page_stack.distribution = .fill // story row stretches
        page_view.addSubview(page_stack) // column on the paper
        NSLayoutConstraint.activate([ // page content constraints
            page_stack.topAnchor.constraint(equalTo: page_view.topAnchor, constant: 13), // top padding
            page_stack.leadingAnchor.constraint(equalTo: page_view.leadingAnchor, constant: 13), // left padding
            page_stack.trailingAnchor.constraint(equalTo: page_view.trailingAnchor, constant: -13), // right padding
            page_stack.bottomAnchor.constraint(equalTo: page_view.bottomAnchor, constant: -13), // bottom padding
            establishing_panel.heightAnchor.constraint(equalTo: page_view.heightAnchor, multiplier: 0.38), // big panel is 38 percent of the page
            narration_box.topAnchor.constraint(equalTo: establishing_panel.topAnchor, constant: 9), // caption near the top
            narration_box.leadingAnchor.constraint(equalTo: establishing_panel.leadingAnchor, constant: 9), // caption near the left
            narration_box.widthAnchor.constraint(equalTo: establishing_panel.widthAnchor, multiplier: 0.44), // caption is 44 percent wide
            narration_label.topAnchor.constraint(equalTo: narration_box.topAnchor, constant: 6), // caption top padding
            narration_label.bottomAnchor.constraint(equalTo: narration_box.bottomAnchor, constant: -6), // caption bottom padding
            narration_label.leadingAnchor.constraint(equalTo: narration_box.leadingAnchor, constant: 8), // caption left padding
            narration_label.trailingAnchor.constraint(equalTo: narration_box.trailingAnchor, constant: -8), // caption right padding
            left_balloon.topAnchor.constraint(equalTo: left_panel.topAnchor, constant: 11), // balloon near the top
            left_balloon.leadingAnchor.constraint(equalTo: left_panel.leadingAnchor, constant: 10), // balloon near the left
            left_balloon.widthAnchor.constraint(equalTo: left_panel.widthAnchor, multiplier: 0.65), // 65 percent wide
            right_balloon.bottomAnchor.constraint(equalTo: right_panel.bottomAnchor, constant: -12), // balloon near the bottom
            right_balloon.centerXAnchor.constraint(equalTo: right_panel.centerXAnchor), // centered across
            right_balloon.widthAnchor.constraint(equalTo: right_panel.widthAnchor, multiplier: 0.78) // 78 percent wide
        ]) // end page content constraints
    } // end build_page

    private func running_head_text(_ text: String) -> NSAttributedString { // tiny spaced out caps
        return NSAttributedString(string: text, attributes: [ // build the string
            .font: UIFont.systemFont(ofSize: 7, weight: .regular), // 7pt regular
            .foregroundColor: app_theme.page_ink_color, // gray ink
            .kern: 1 // letter spacing
        ]) // end attributes
    } // end running_head_text

    private func make_panel(image_name: String) -> UIView { // bordered comic panel with art
        let panel = UIView() // the frame
        panel.translatesAutoresizingMaskIntoConstraints = false // using constraints
        panel.layer.borderWidth = 0.8 // thin border
        panel.layer.borderColor = app_theme.panel_border_color.cgColor // dark teal border
        panel.clipsToBounds = true // crop the art
        let art_view = UIImageView(image: UIImage(named: image_name)) // the art
        art_view.translatesAutoresizingMaskIntoConstraints = false // using constraints
        art_view.contentMode = .scaleAspectFill // fill and crop
        art_view.clipsToBounds = true // no spill
        art_view.setContentHuggingPriority(UILayoutPriority(1), for: .vertical) // image size should not matter
        art_view.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal) // image size should not matter
        art_view.setContentCompressionResistancePriority(UILayoutPriority(1), for: .vertical) // let it squish
        art_view.setContentCompressionResistancePriority(UILayoutPriority(1), for: .horizontal) // let it squish
        panel.addSubview(art_view) // art inside the frame
        NSLayoutConstraint.activate([ // art fills the panel
            art_view.topAnchor.constraint(equalTo: panel.topAnchor), // top
            art_view.leadingAnchor.constraint(equalTo: panel.leadingAnchor), // left
            art_view.trailingAnchor.constraint(equalTo: panel.trailingAnchor), // right
            art_view.bottomAnchor.constraint(equalTo: panel.bottomAnchor) // bottom
        ]) // end art constraints
        return panel // hand it back
    } // end make_panel

    private func make_balloon(text: String) -> UIView { // round speech balloon
        let balloon = UIView() // the bubble
        balloon.translatesAutoresizingMaskIntoConstraints = false // using constraints
        balloon.backgroundColor = app_theme.balloon_color // cream fill
        balloon.layer.cornerRadius = 19 // very round
        balloon.layer.borderWidth = 0.8 // thin border
        balloon.layer.borderColor = app_theme.hex_color(0x34423F).cgColor // dark border
        let balloon_label = UILabel() // the words
        balloon_label.translatesAutoresizingMaskIntoConstraints = false // using constraints
        balloon_label.text = text // what they say
        balloon_label.font = app_theme.serif_font(size: 11) // serif 11
        balloon_label.textColor = app_theme.balloon_ink_color // balloon ink
        balloon_label.textAlignment = .center // centered
        balloon_label.numberOfLines = 0 // wrap
        balloon.addSubview(balloon_label) // words in the bubble
        NSLayoutConstraint.activate([ // padding around the words
            balloon_label.topAnchor.constraint(equalTo: balloon.topAnchor, constant: 10), // top
            balloon_label.leadingAnchor.constraint(equalTo: balloon.leadingAnchor, constant: 10), // left
            balloon_label.trailingAnchor.constraint(equalTo: balloon.trailingAnchor, constant: -10), // right
            balloon_label.bottomAnchor.constraint(equalTo: balloon.bottomAnchor, constant: -10) // bottom
        ]) // end balloon constraints
        return balloon // hand it back
    } // end make_balloon

    // MARK: controls

    private func build_controls() { // bottom overlay with page row, slider, layout picker
        controls_view.translatesAutoresizingMaskIntoConstraints = false // using constraints
        controls_view.backgroundColor = app_theme.reader_bar_color // dark bar color
        view.addSubview(controls_view) // add to the screen
        let chevron_config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold) // arrow size
        left_page_button.setImage(UIImage(systemName: "chevron.left", withConfiguration: chevron_config), for: .normal) // left arrow
        right_page_button.setImage(UIImage(systemName: "chevron.right", withConfiguration: chevron_config), for: .normal) // right arrow
        left_page_button.tintColor = .white // white arrow
        right_page_button.tintColor = .white // white arrow
        left_page_button.addTarget(self, action: #selector(left_page_tapped), for: .touchUpInside) // left tap
        right_page_button.addTarget(self, action: #selector(right_page_tapped), for: .touchUpInside) // right tap
        left_page_button.translatesAutoresizingMaskIntoConstraints = false // using constraints
        right_page_button.translatesAutoresizingMaskIntoConstraints = false // using constraints
        page_status_label.textAlignment = .center // centered text
        page_status_label.setContentHuggingPriority(.defaultLow, for: .horizontal) // label takes the middle
        let page_row = UIStackView(arrangedSubviews: [left_page_button, page_status_label, right_page_button]) // arrows and label
        page_row.axis = .horizontal // side by side
        page_row.alignment = .center // vertically centered
        page_row.distribution = .fill // label expands
        page_slider.minimumValue = 1 // first page
        page_slider.minimumTrackTintColor = app_theme.accent_color // terracotta fill
        page_slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.22) // faint track
        page_slider.thumbTintColor = .white // white knob
        page_slider.addTarget(self, action: #selector(slider_changed), for: .valueChanged) // scrub handler
        layout_control.selectedSegmentIndex = 0 // single page by default
        layout_control.backgroundColor = UIColor.white.withAlphaComponent(0.12) // faint fill
        layout_control.selectedSegmentTintColor = UIColor.white.withAlphaComponent(0.92) // bright pill
        layout_control.setTitleTextAttributes([ // normal titles
            .font: UIFont.systemFont(ofSize: 13, weight: .medium), // 13 medium
            .foregroundColor: UIColor.white // white text
        ], for: .normal) // end normal titles
        layout_control.setTitleTextAttributes([ // selected title
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold), // 13 semibold
            .foregroundColor: app_theme.reader_background_color // dark text on the pill
        ], for: .selected) // end selected title
        let controls_stack = UIStackView(arrangedSubviews: [page_row, page_slider, layout_control]) // overlay column
        controls_stack.translatesAutoresizingMaskIntoConstraints = false // using constraints
        controls_stack.axis = .vertical // top to bottom
        controls_stack.spacing = 14 // gap between rows
        controls_view.addSubview(controls_stack) // column in the overlay
        NSLayoutConstraint.activate([ // overlay inner constraints
            left_page_button.widthAnchor.constraint(equalToConstant: 44), // tap size
            left_page_button.heightAnchor.constraint(equalToConstant: 44), // tap size
            right_page_button.widthAnchor.constraint(equalToConstant: 44), // tap size
            right_page_button.heightAnchor.constraint(equalToConstant: 44), // tap size
            controls_stack.topAnchor.constraint(equalTo: controls_view.topAnchor, constant: 16), // top padding
            controls_stack.leadingAnchor.constraint(equalTo: controls_view.leadingAnchor, constant: 20), // left padding
            controls_stack.trailingAnchor.constraint(equalTo: controls_view.trailingAnchor, constant: -20), // right padding
            controls_stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8) // above the home bar
        ]) // end overlay inner constraints
    } // end build_controls

    private func build_layout() { // big picture constraints
        NSLayoutConstraint.activate([ // screen level constraints
            scroll_view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor), // under the nav bar
            scroll_view.leadingAnchor.constraint(equalTo: view.leadingAnchor), // full width
            scroll_view.trailingAnchor.constraint(equalTo: view.trailingAnchor), // full width
            scroll_view.bottomAnchor.constraint(equalTo: controls_view.topAnchor), // stops at the overlay
            controls_view.leadingAnchor.constraint(equalTo: view.leadingAnchor), // overlay left edge
            controls_view.trailingAnchor.constraint(equalTo: view.trailingAnchor), // overlay right edge
            controls_view.bottomAnchor.constraint(equalTo: view.bottomAnchor), // overlay to the very bottom
            page_view.topAnchor.constraint(equalTo: scroll_view.contentLayoutGuide.topAnchor, constant: 8), // page top gap
            page_view.bottomAnchor.constraint(equalTo: scroll_view.contentLayoutGuide.bottomAnchor, constant: -8), // page bottom gap
            page_view.leadingAnchor.constraint(equalTo: scroll_view.contentLayoutGuide.leadingAnchor), // page left
            page_view.trailingAnchor.constraint(equalTo: scroll_view.contentLayoutGuide.trailingAnchor), // page right
            page_view.widthAnchor.constraint(equalTo: scroll_view.frameLayoutGuide.widthAnchor), // as wide as the screen
            page_view.heightAnchor.constraint(equalTo: page_view.widthAnchor, multiplier: 1.416) // comic page shape
        ]) // end screen level constraints
    } // end build_layout

    // MARK: gestures

    private func setup_gestures() { // tap to hide chrome, double tap to zoom
        let double_tap = UITapGestureRecognizer(target: self, action: #selector(handle_double_tap(_:))) // zoom tap
        double_tap.numberOfTapsRequired = 2 // two taps
        scroll_view.addGestureRecognizer(double_tap) // on the page area
        let single_tap = UITapGestureRecognizer(target: self, action: #selector(handle_single_tap(_:))) // chrome tap
        single_tap.numberOfTapsRequired = 1 // one tap
        single_tap.require(toFail: double_tap) // wait to make sure it is not a double tap
        scroll_view.addGestureRecognizer(single_tap) // on the page area
    } // end setup_gestures

    @objc private func handle_single_tap(_ recognizer: UITapGestureRecognizer) { // show or hide the chrome
        controls_hidden.toggle() // flip the state
        let hide_now = controls_hidden // copy for the closure
        controls_view.isUserInteractionEnabled = !hide_now // no taps on a hidden overlay
        UIView.animate(withDuration: 0.2) { // quick fade
            self.controls_view.alpha = hide_now ? 0 : 1 // fade the overlay
        } // end animate
        navigationController?.setNavigationBarHidden(hide_now, animated: true) // slide the nav bar
    } // end handle_single_tap

    @objc private func handle_double_tap(_ recognizer: UITapGestureRecognizer) { // zoom in or out
        if scroll_view.zoomScale > 1 { // already zoomed
            scroll_view.setZoomScale(1, animated: true) // back to normal
        } else { // not zoomed
            scroll_view.setZoomScale(2, animated: true) // zoom to 2x
        } // end if zoomed
    } // end handle_double_tap

    func viewForZooming(in scrollView: UIScrollView) -> UIView? { // which view zooms
        return page_view // the page
    } // end viewForZooming

    // MARK: paging

    @objc private func left_page_tapped() { // left arrow tapped
        guard let book = current_book else { return } // need a book
        let step = book.right_to_left ? 1 : -1 // right to left books go forward on the left
        go_to_page(book.current_page + step) // move one page
    } // end left_page_tapped

    @objc private func right_page_tapped() { // right arrow tapped
        guard let book = current_book else { return } // need a book
        let step = book.right_to_left ? -1 : 1 // right to left books go back on the right
        go_to_page(book.current_page + step) // move one page
    } // end right_page_tapped

    @objc private func slider_changed() { // slider moved
        let whole_page = Int(page_slider.value.rounded()) // snap to a whole page
        page_slider.value = Float(whole_page) // snap the knob too
        guard let book = current_book, whole_page != book.current_page else { return } // skip if nothing changed
        go_to_page(whole_page) // jump there
    } // end slider_changed

    func go_to_page(_ page_number: Int) { // jump to a page and save
        guard var book = current_book else { return } // need a book
        let total_pages = max(book.page_count, 1) // at least one page
        let clamped_page = min(max(page_number, 1), total_pages) // keep it in range
        let page_changed = clamped_page != book.current_page // did it actually move
        book.current_page = clamped_page // new page
        if page_changed && book.status == .not_started { // first real page turn
            book.status = .reading // now we are reading it
        } // end if status
        book.last_opened = Date() // touched just now
        book_store.shared.save(book) // write it back
        current_book = book // keep our copy in sync
        update_controls() // redraw labels and slider
    } // end go_to_page

    private func update_controls() { // sync every label and the slider with the book
        guard let book = current_book else { return } // need a book
        let total_pages = max(book.page_count, 1) // at least one page
        let shown_page = min(max(book.current_page, 1), total_pages) // safe page number
        page_status_label.text = "Page \(shown_page) of \(total_pages)" // page x of y
        page_slider.maximumValue = Float(total_pages) // last page
        page_slider.value = Float(shown_page) // knob position
        page_number_label.text = "\(shown_page)" // number on the paper
        running_head_title_label.attributedText = running_head_text(book.title.uppercased()) // title in caps
        left_page_button.accessibilityLabel = book.right_to_left ? "Next page" : "Previous page" // voiceover name
        right_page_button.accessibilityLabel = book.right_to_left ? "Previous page" : "Next page" // voiceover name
    } // end update_controls
} // end reader_view_controller
