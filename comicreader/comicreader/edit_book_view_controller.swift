// 10/31/26 edit book screen, also used as the add book screen when there is no book  // file header

import UIKit  // uikit for all the views

final class edit_book_view_controller: UIViewController, UITextFieldDelegate, UITextViewDelegate {  // the add and edit form screen

    private let original_book: book_item?  // nil means we are adding a new book
    private let on_save_handler: (book_item) -> Void  // presenter closure that stores the book

    private let scroll_view = UIScrollView()  // scrolls the whole form
    private let form_stack = UIStackView()  // holds every section top to bottom

    private let title_field = UITextField()  // book title input
    private let author_field = UITextField()  // author input
    private let collection_field = UITextField()  // collection input

    private let status_options: [reading_status] = [.reading, .finished, .on_hold]  // same order as the figma segments
    private let status_control = UISegmentedControl(items: ["Reading", "Finished", "On hold"])  // status picker

    private let direction_switch = UISwitch()  // right to left toggle

    private let description_view = UITextView()  // multi line description box
    private let description_placeholder = UILabel()  // fake placeholder for the text view

    private var did_focus_title = false  // only auto focus once

    init(book: book_item?, on_save: @escaping (book_item) -> Void) {  // main init
        self.original_book = book  // remember the book we are editing
        self.on_save_handler = on_save  // remember the save closure
        super.init(nibName: nil, bundle: nil)  // no nib, all code
    }  // end init

    required init?(coder: NSCoder) {  // storyboard init we never use
        fatalError("init(coder:) has not been implemented")  // crash on purpose
    }  // end init coder

    override var preferredStatusBarStyle: UIStatusBarStyle {  // light screen so dark status bar
        return .darkContent  // dark text on the light background
    }  // end preferredStatusBarStyle

    override func viewDidLoad() {  // set up the screen once
        super.viewDidLoad()  // let uikit do its thing first
        view.backgroundColor = app_theme.background_color  // warm off white background
        title = original_book == nil ? "Add Book" : "Edit Book"  // title depends on the mode
        navigationItem.largeTitleDisplayMode = .never  // small title for a sheet
        build_nav_buttons()  // cancel and save
        build_layout()  // scroll view and form
        fill_from_book()  // prefill when editing
    }  // end viewDidLoad

    override func viewDidAppear(_ animated: Bool) {  // screen is fully on screen now
        super.viewDidAppear(animated)  // call super
        if original_book == nil && !did_focus_title {  // add mode and first time showing
            did_focus_title = true  // do not refocus later
            title_field.becomeFirstResponder()  // pop the keyboard on the title field
        }  // end focus check
    }  // end viewDidAppear

    private func build_nav_buttons() {  // bar buttons on both sides
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel_tapped))  // cancel on the left
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save_tapped))  // bold save on the right
    }  // end build_nav_buttons

    private func build_layout() {  // builds the whole form
        scroll_view.translatesAutoresizingMaskIntoConstraints = false  // auto layout
        scroll_view.keyboardDismissMode = .interactive  // drag down to hide keyboard
        scroll_view.alwaysBounceVertical = true  // feels nicer even when short
        view.addSubview(scroll_view)  // put it on screen

        form_stack.translatesAutoresizingMaskIntoConstraints = false  // auto layout
        form_stack.axis = .vertical  // sections go down
        form_stack.spacing = 18  // gap between sections
        scroll_view.addSubview(form_stack)  // stack lives in the scroll view

        NSLayoutConstraint.activate([  // pin scroll view and stack
            scroll_view.topAnchor.constraint(equalTo: view.topAnchor),  // top edge
            scroll_view.leadingAnchor.constraint(equalTo: view.leadingAnchor),  // left edge
            scroll_view.trailingAnchor.constraint(equalTo: view.trailingAnchor),  // right edge
            scroll_view.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),  // stops above the keyboard
            form_stack.topAnchor.constraint(equalTo: scroll_view.contentLayoutGuide.topAnchor, constant: 8),  // small top gap
            form_stack.leadingAnchor.constraint(equalTo: scroll_view.contentLayoutGuide.leadingAnchor, constant: 16),  // left inset
            form_stack.trailingAnchor.constraint(equalTo: scroll_view.contentLayoutGuide.trailingAnchor, constant: -16),  // right inset
            form_stack.bottomAnchor.constraint(equalTo: scroll_view.contentLayoutGuide.bottomAnchor, constant: -24),  // bottom gap
            form_stack.widthAnchor.constraint(equalTo: scroll_view.frameLayoutGuide.widthAnchor, constant: -32)  // no sideways scrolling
        ])  // end activate

        form_stack.addArrangedSubview(make_section(title: "Details", content: build_details_group()))  // details section
        form_stack.addArrangedSubview(make_section(title: "Status", content: build_status_group()))  // status section
        form_stack.addArrangedSubview(make_section(title: "Reading", content: build_reading_group()))  // reading section
        form_stack.addArrangedSubview(make_section(title: "Description", content: build_description_group()))  // description section
    }  // end build_layout

    private func make_section(title section_title: String, content content_view: UIView) -> UIStackView {  // header plus group
        let header_label = UILabel()  // small caps style header
        header_label.translatesAutoresizingMaskIntoConstraints = false  // auto layout
        header_label.attributedText = NSAttributedString(string: section_title.uppercased(), attributes: [  // uppercase with spacing
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),  // 12 medium
            .foregroundColor: app_theme.muted_color,  // muted gray
            .kern: 0.6  // little letter spacing
        ])  // end attributes

        let header_container = UIView()  // gives the header its left inset
        header_container.addSubview(header_label)  // label inside container
        NSLayoutConstraint.activate([  // pin the header label
            header_label.topAnchor.constraint(equalTo: header_container.topAnchor),  // top
            header_label.bottomAnchor.constraint(equalTo: header_container.bottomAnchor),  // bottom
            header_label.leadingAnchor.constraint(equalTo: header_container.leadingAnchor, constant: 16),  // lines up with row text
            header_label.trailingAnchor.constraint(equalTo: header_container.trailingAnchor)  // right
        ])  // end activate

        let section_stack = UIStackView(arrangedSubviews: [header_container, content_view])  // header on top of group
        section_stack.axis = .vertical  // stacked
        section_stack.spacing = 6  // small gap under header
        return section_stack  // hand it back
    }  // end make_section

    private func make_group_view() -> UIView {  // white rounded card
        let group_view = UIView()  // plain view
        group_view.translatesAutoresizingMaskIntoConstraints = false  // auto layout
        app_theme.style_group(group_view, corner_radius: 12)  // shared group look
        return group_view  // hand it back
    }  // end make_group_view

    private func pin(_ child_view: UIView, inside parent_view: UIView, inset: CGFloat) {  // pins a child to all edges
        child_view.translatesAutoresizingMaskIntoConstraints = false  // auto layout
        parent_view.addSubview(child_view)  // add it first
        NSLayoutConstraint.activate([  // all four edges
            child_view.topAnchor.constraint(equalTo: parent_view.topAnchor, constant: inset),  // top
            child_view.leadingAnchor.constraint(equalTo: parent_view.leadingAnchor, constant: inset),  // left
            child_view.trailingAnchor.constraint(equalTo: parent_view.trailingAnchor, constant: -inset),  // right
            child_view.bottomAnchor.constraint(equalTo: parent_view.bottomAnchor, constant: -inset)  // bottom
        ])  // end activate
    }  // end pin

    private func build_details_group() -> UIView {  // title author collection rows
        set_up_field(title_field, placeholder: "Title", capitalization: .words, return_key: .next)  // title field
        set_up_field(author_field, placeholder: "Author", capitalization: .words, return_key: .next)  // author field
        set_up_field(collection_field, placeholder: "Collection", capitalization: .sentences, return_key: .done)  // collection field

        let rows_stack = UIStackView(arrangedSubviews: [  // rows with lines between
            make_field_row(label_text: "Title", field: title_field),  // row 1
            app_theme.make_separator(),  // line
            make_field_row(label_text: "Author", field: author_field),  // row 2
            app_theme.make_separator(),  // line
            make_field_row(label_text: "Collection", field: collection_field)  // row 3
        ])  // end rows
        rows_stack.axis = .vertical  // rows go down

        let group_view = make_group_view()  // the card
        pin(rows_stack, inside: group_view, inset: 0)  // rows fill the card
        return group_view  // hand it back
    }  // end build_details_group

    private func set_up_field(_ field: UITextField, placeholder placeholder_text: String, capitalization: UITextAutocapitalizationType, return_key: UIReturnKeyType) {  // shared field styling
        field.font = UIFont.systemFont(ofSize: 15, weight: .regular)  // 15 regular
        field.textColor = app_theme.ink_color  // main text color
        field.attributedPlaceholder = NSAttributedString(string: placeholder_text, attributes: [.foregroundColor: app_theme.placeholder_color])  // light gray placeholder
        field.clearButtonMode = .whileEditing  // little x while typing
        field.autocapitalizationType = capitalization  // words or sentences
        field.returnKeyType = return_key  // next or done
        field.delegate = self  // so return key works
        field.setContentHuggingPriority(.defaultLow, for: .horizontal)  // field takes the extra width
    }  // end set_up_field

    private func make_field_row(label_text: String, field: UITextField) -> UIStackView {  // label plus field row
        let name_label = app_theme.make_label(label_text, size: 15, weight: .regular, color: app_theme.muted_color)  // left label
        name_label.translatesAutoresizingMaskIntoConstraints = false  // auto layout
        name_label.widthAnchor.constraint(equalToConstant: 96).isActive = true  // fixed label column

        let row_stack = UIStackView(arrangedSubviews: [name_label, field])  // side by side
        row_stack.axis = .horizontal  // left to right
        row_stack.spacing = 12  // gap between label and field
        row_stack.alignment = .center  // vertically centered
        row_stack.isLayoutMarginsRelativeArrangement = true  // use the margins below
        row_stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)  // row padding
        return row_stack  // hand it back
    }  // end make_field_row

    private func build_status_group() -> UIView {  // segmented status picker
        status_control.backgroundColor = app_theme.fill_color  // gray track
        status_control.selectedSegmentTintColor = .white  // white thumb
        status_control.setTitleTextAttributes([  // normal titles
            .font: UIFont.systemFont(ofSize: 13, weight: .medium),  // 13 medium
            .foregroundColor: app_theme.ink_color  // ink text
        ], for: .normal)  // end normal
        status_control.setTitleTextAttributes([  // selected titles
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),  // 13 semibold
            .foregroundColor: app_theme.ink_color  // ink text
        ], for: .selected)  // end selected
        status_control.selectedSegmentIndex = UISegmentedControl.noSegment  // nothing picked until we prefill
        status_control.addTarget(self, action: #selector(status_changed), for: .valueChanged)  // track edits

        let group_view = make_group_view()  // the card
        pin(status_control, inside: group_view, inset: 12)  // 12 padding all around
        return group_view  // hand it back
    }  // end build_status_group

    private func build_reading_group() -> UIView {  // right to left switch row
        let switch_title = app_theme.make_label("Right to left (manga)", size: 15, weight: .regular, color: app_theme.ink_color)  // main text
        let switch_subtitle = app_theme.make_label("Turn pages from right to left for this book", size: 12, weight: .regular, color: app_theme.muted_color, lines: 0)  // helper text

        let text_stack = UIStackView(arrangedSubviews: [switch_title, switch_subtitle])  // title over subtitle
        text_stack.axis = .vertical  // stacked
        text_stack.spacing = 2  // tight gap

        direction_switch.onTintColor = app_theme.accent_color  // terracotta when on
        direction_switch.setContentHuggingPriority(.required, for: .horizontal)  // switch keeps its size
        direction_switch.setContentCompressionResistancePriority(.required, for: .horizontal)  // never squished
        direction_switch.addTarget(self, action: #selector(switch_changed), for: .valueChanged)  // track edits

        let row_stack = UIStackView(arrangedSubviews: [text_stack, direction_switch])  // text then switch
        row_stack.axis = .horizontal  // left to right
        row_stack.spacing = 12  // gap
        row_stack.alignment = .center  // centered vertically
        row_stack.isLayoutMarginsRelativeArrangement = true  // use the margins below
        row_stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)  // row padding

        let group_view = make_group_view()  // the card
        pin(row_stack, inside: group_view, inset: 0)  // row fills the card
        return group_view  // hand it back
    }  // end build_reading_group

    private func build_description_group() -> UIView {  // description text box
        description_view.font = UIFont.systemFont(ofSize: 15, weight: .regular)  // 15 regular
        description_view.textColor = app_theme.ink_color  // ink text
        description_view.backgroundColor = .clear  // card shows through
        description_view.isScrollEnabled = false  // grows with the text
        description_view.textContainerInset = UIEdgeInsets(top: 12, left: 11, bottom: 12, right: 11)  // inner padding
        description_view.delegate = self  // for placeholder and edits

        description_placeholder.translatesAutoresizingMaskIntoConstraints = false  // auto layout
        description_placeholder.text = "What is this book about?"  // hint text
        description_placeholder.font = UIFont.systemFont(ofSize: 15, weight: .regular)  // same font as the box
        description_placeholder.textColor = app_theme.placeholder_color  // light gray
        description_placeholder.isUserInteractionEnabled = false  // taps go to the text view

        let group_view = make_group_view()  // the card
        pin(description_view, inside: group_view, inset: 0)  // text view fills the card
        group_view.addSubview(description_placeholder)  // placeholder sits on top
        let text_padding = description_view.textContainer.lineFragmentPadding  // extra padding inside the text container
        NSLayoutConstraint.activate([  // size and placeholder spot
            description_view.heightAnchor.constraint(greaterThanOrEqualToConstant: 110),  // at least 110 tall
            description_placeholder.topAnchor.constraint(equalTo: group_view.topAnchor, constant: 12),  // matches top inset
            description_placeholder.leadingAnchor.constraint(equalTo: group_view.leadingAnchor, constant: 11 + text_padding),  // matches where text starts
            description_placeholder.trailingAnchor.constraint(lessThanOrEqualTo: group_view.trailingAnchor, constant: -11)  // stays inside
        ])  // end activate
        return group_view  // hand it back
    }  // end build_description_group

    private func fill_from_book() {  // prefill fields in edit mode
        guard let book = original_book else {  // add mode has nothing to fill
            description_placeholder.isHidden = false  // show the hint
            return  // leave everything empty
        }  // end guard
        title_field.text = book.title  // title
        author_field.text = book.author  // author
        collection_field.text = book.collection  // collection
        if let status_index = status_options.firstIndex(of: book.status) {  // reading finished or on hold
            status_control.selectedSegmentIndex = status_index  // pick that segment
        } else {  // not started
            status_control.selectedSegmentIndex = UISegmentedControl.noSegment  // nothing picked
        }  // end status check
        direction_switch.isOn = book.right_to_left  // reading direction
        description_view.text = book.description_text  // description
        description_placeholder.isHidden = !book.description_text.isEmpty  // hide hint if there is text
    }  // end fill_from_book

    private func selected_status() -> reading_status? {  // status from the segmented control
        let index = status_control.selectedSegmentIndex  // current pick
        guard index >= 0 && index < status_options.count else { return nil }  // no segment picked
        return status_options[index]  // matching status
    }  // end selected_status

    @objc private func cancel_tapped() {  // cancel button
        view.endEditing(true)  // drop the keyboard
        dismiss(animated: true)  // close without saving
    }  // end cancel_tapped

    @objc private func save_tapped() {  // save button
        let trimmed_title = (title_field.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)  // clean up the title
        guard !trimmed_title.isEmpty else {  // title is required
            let alert = UIAlertController(title: "Title needed", message: "Give the book a title before saving.", preferredStyle: .alert)  // warning popup
            alert.addAction(UIAlertAction(title: "OK", style: .default))  // just close it
            present(alert, animated: true)  // show it
            return  // stop here
        }  // end guard
        let author_text = (author_field.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)  // clean author
        let collection_text = (collection_field.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)  // clean collection
        let description_text = description_view.text ?? ""  // description as typed

        let saved_book: book_item  // the book we hand back
        if let original = original_book {  // edit mode
            var updated_book = original  // start from the original copy
            updated_book.title = trimmed_title  // new title
            updated_book.author = author_text  // new author
            updated_book.collection = collection_text  // new collection
            updated_book.status = selected_status() ?? original.status  // keep old status if nothing picked
            updated_book.right_to_left = direction_switch.isOn  // new direction
            updated_book.description_text = description_text  // new description
            saved_book = updated_book  // done editing
        } else {  // add mode
            saved_book = book_item(id: UUID(), title: trimmed_title, author: author_text, collection: collection_text, format: .cbz, status: selected_status() ?? .not_started, current_page: 0, page_count: 120, right_to_left: direction_switch.isOn, description_text: description_text, cover_image_name: nil, last_opened: Date())  // brand new book
        }  // end mode check

        view.endEditing(true)  // drop the keyboard
        on_save_handler(saved_book)  // presenter saves it
        dismiss(animated: true)  // close the sheet
    }  // end save_tapped

    @objc private func status_changed() {  // segment tapped
        isModalInPresentation = true  // block swipe to dismiss
    }  // end status_changed

    @objc private func switch_changed() {  // switch flipped
        isModalInPresentation = true  // block swipe to dismiss
    }  // end switch_changed

    func textFieldDidBeginEditing(_ textField: UITextField) {  // user started typing
        isModalInPresentation = true  // block swipe to dismiss so edits are safe
    }  // end textFieldDidBeginEditing

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {  // return key pressed
        if textField === title_field {  // on title
            author_field.becomeFirstResponder()  // go to author
        } else if textField === author_field {  // on author
            collection_field.becomeFirstResponder()  // go to collection
        } else {  // last field
            textField.resignFirstResponder()  // hide keyboard
        }  // end field check
        return true  // allow the return
    }  // end textFieldShouldReturn

    func textViewDidBeginEditing(_ textView: UITextView) {  // started typing the description
        isModalInPresentation = true  // block swipe to dismiss
    }  // end textViewDidBeginEditing

    func textViewDidChange(_ textView: UITextView) {  // description text changed
        description_placeholder.isHidden = !textView.text.isEmpty  // hint only when empty
    }  // end textViewDidChange
}  // end edit_book_view_controller
