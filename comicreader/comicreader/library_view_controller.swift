// 10/31/26 library_view_controller, the Library screen with filter, sort, search and the book list
import UIKit                                                                    // need uikit for everything here

final class library_view_controller: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating { // library screen

    private enum sort_option: CaseIterable {                                    // ways we can sort the list
        case recently_opened                                                    // newest opened first
        case title                                                              // a to z by title
        case progress                                                           // most progress first

        var display_name: String {                                              // text shown in the menu
            switch self {                                                       // pick by case
            case .recently_opened: return "Recently opened"                     // default sort name
            case .title: return "Title"                                         // title sort name
            case .progress: return "Progress"                                   // progress sort name
            }                                                                   // end switch
        }                                                                       // end display_name
    }                                                                           // end sort_option

    private var visible_books: [book_item] = []                                 // books after filter, search and sort
    private var current_sort: sort_option = .recently_opened                    // sort we start with

    private let search_controller = UISearchController(searchResultsController: nil) // search bar in the nav bar
    private let filter_control = UISegmentedControl(items: ["All", "Reading", "On hold", "Finished"]) // status filter
    private let count_label = app_theme.make_label("", size: 13, weight: .regular, color: app_theme.muted_color) // like 7 books
    private let sort_button = UIButton(type: .system)                           // sort menu button on the right
    private let table_view = UITableView(frame: .zero, style: .insetGrouped)    // the actual book list

    override var preferredStatusBarStyle: UIStatusBarStyle {                    // light screen so dark text
        return .darkContent                                                     // dark status bar text
    }                                                                           // end preferredStatusBarStyle

    override func viewDidLoad() {                                               // runs once when the view loads
        super.viewDidLoad()                                                     // always call super
        view.backgroundColor = app_theme.background_color                       // off white screen background
        title = "Library"                                                       // nav bar title
        navigationItem.largeTitleDisplayMode = .always                          // big title like figma
        navigationItem.backButtonTitle = "Library"                              // back button text on the reader
        setup_nav_items()                                                       // plus and edit buttons
        setup_search()                                                          // search controller stuff
        build_layout()                                                          // header and table
    }                                                                           // end viewDidLoad

    override func viewWillAppear(_ animated: Bool) {                            // runs every time we show up
        super.viewWillAppear(animated)                                          // always call super
        refresh_list()                                                          // books may have changed elsewhere
    }                                                                           // end viewWillAppear

    private func setup_nav_items() {                                            // right side bar buttons
        let add_action = UIAction { [weak self] _ in                            // what plus does
            self?.present_add_book()                                            // open the add book sheet
        }                                                                       // end add_action
        let add_item = UIBarButtonItem(systemItem: .add, primaryAction: add_action) // the plus button
        navigationItem.rightBarButtonItems = [add_item, editButtonItem]         // first item is far right so plus then edit
    }                                                                           // end setup_nav_items

    private func setup_search() {                                               // sets up the search bar
        search_controller.searchResultsUpdater = self                           // we filter as they type
        search_controller.obscuresBackgroundDuringPresentation = false          // keep the list visible
        search_controller.searchBar.placeholder = "Search title or author"      // hint text in the bar
        navigationItem.searchController = search_controller                     // put it in the nav bar
        navigationItem.hidesSearchBarWhenScrolling = false                      // always show the search bar
        definesPresentationContext = true                                       // keep search inside this screen
    }                                                                           // end setup_search

    private func build_layout() {                                               // builds header and table
        filter_control.selectedSegmentIndex = 0                                 // start on All
        filter_control.backgroundColor = app_theme.fill_color                   // light gray track
        filter_control.selectedSegmentTintColor = .white                        // white selected pill
        filter_control.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 13, weight: .medium), .foregroundColor: app_theme.ink_color], for: .normal) // normal text
        filter_control.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 13, weight: .semibold), .foregroundColor: app_theme.ink_color], for: .selected) // selected text
        filter_control.addAction(UIAction { [weak self] _ in                    // when the filter changes
            self?.refresh_list()                                                // rebuild the list
        }, for: .valueChanged)                                                  // end filter action

        count_label.setContentHuggingPriority(.defaultLow, for: .horizontal)    // count label takes the extra space
        sort_button.setContentHuggingPriority(.required, for: .horizontal)      // button stays tight on the right
        sort_button.setContentCompressionResistancePriority(.required, for: .horizontal) // never squish the button
        sort_button.showsMenuAsPrimaryAction = true                             // tap opens the menu right away
        update_sort_button()                                                    // set title and menu

        let sort_row = UIStackView(arrangedSubviews: [count_label, sort_button]) // count left, sort right
        sort_row.axis = .horizontal                                             // left to right
        sort_row.alignment = .center                                            // center them vertically
        sort_row.spacing = 8                                                    // small gap just in case

        let header_stack = UIStackView(arrangedSubviews: [filter_control, sort_row]) // whole header above the table
        header_stack.translatesAutoresizingMaskIntoConstraints = false          // auto layout for the header
        header_stack.axis = .vertical                                           // top to bottom
        header_stack.spacing = 14                                               // gap from figma
        view.addSubview(header_stack)                                           // add header to the screen

        table_view.translatesAutoresizingMaskIntoConstraints = false            // auto layout for the table
        table_view.backgroundColor = app_theme.background_color                 // match the screen background
        table_view.rowHeight = UITableView.automaticDimension                   // cells size themselves
        table_view.estimatedRowHeight = 98                                      // rough row height guess
        table_view.register(book_cell.self, forCellReuseIdentifier: book_cell.reuse_identifier) // register our cell
        table_view.dataSource = self                                            // we give it rows
        table_view.delegate = self                                              // we handle taps
        table_view.allowsSelectionDuringEditing = true                          // edit mode tap opens edit book
        table_view.keyboardDismissMode = .onDrag                                // scrolling hides the keyboard
        view.addSubview(table_view)                                             // add table to the screen

        let safe_area = view.safeAreaLayoutGuide                                // shortcut for the safe area
        NSLayoutConstraint.activate([                                           // all constraints at once
            header_stack.topAnchor.constraint(equalTo: safe_area.topAnchor, constant: 8), // 8 below safe area top
            header_stack.leadingAnchor.constraint(equalTo: safe_area.leadingAnchor, constant: 16), // 16 on the left
            header_stack.trailingAnchor.constraint(equalTo: safe_area.trailingAnchor, constant: -16), // 16 on the right
            table_view.topAnchor.constraint(equalTo: header_stack.bottomAnchor, constant: 6), // table right under header
            table_view.leadingAnchor.constraint(equalTo: view.leadingAnchor),   // full width left
            table_view.trailingAnchor.constraint(equalTo: view.trailingAnchor), // full width right
            table_view.bottomAnchor.constraint(equalTo: view.bottomAnchor)      // all the way down
        ])                                                                      // end activate
    }                                                                           // end build_layout

    private func update_sort_button() {                                         // rebuilds sort title and menu
        var title_attributes = AttributeContainer()                             // font and color for the title
        title_attributes.font = UIFont.systemFont(ofSize: 13, weight: .medium)  // 13 medium
        title_attributes.foregroundColor = app_theme.accent_color               // accent color text

        var config = UIButton.Configuration.plain()                             // plain style button
        config.image = UIImage(systemName: "arrow.up.arrow.down")               // sort arrows symbol
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 13) // 13pt symbol
        config.attributedTitle = AttributedString(current_sort.display_name, attributes: title_attributes) // current sort name
        config.imagePadding = 5                                                 // gap between icon and title
        config.baseForegroundColor = app_theme.accent_color                     // tint icon accent too
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0) // no side padding so it lines up
        sort_button.configuration = config                                      // apply the config

        let menu_actions = sort_option.allCases.map { option in                 // one action per sort option
            UIAction(title: option.display_name, state: option == self.current_sort ? .on : .off) { [weak self] _ in // checked if current
                self?.current_sort = option                                     // remember the choice
                self?.update_sort_button()                                      // redo title and checkmark
                self?.refresh_list()                                            // resort the list
            }                                                                   // end action handler
        }                                                                       // end map
        sort_button.menu = UIMenu(children: menu_actions)                       // attach the menu
    }                                                                           // end update_sort_button

    private func refresh_list() {                                               // rebuilds visible_books and reloads
        var books = book_store.shared.books                                     // start with every book

        switch filter_control.selectedSegmentIndex {                            // status filter from the segment
        case 1: books = books.filter { $0.status == .reading }                  // only reading
        case 2: books = books.filter { $0.status == .on_hold }                  // only on hold
        case 3: books = books.filter { $0.status == .finished }                 // only finished
        default: break                                                          // All keeps everything
        }                                                                       // end switch

        let search_text = (search_controller.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines) // typed search
        if !search_text.isEmpty {                                               // only filter if they typed something
            books = books.filter { $0.title.localizedCaseInsensitiveContains(search_text) || $0.author.localizedCaseInsensitiveContains(search_text) } // title or author match
        }                                                                       // end search filter

        switch current_sort {                                                   // apply the chosen sort
        case .recently_opened:                                                  // newest first
            books.sort { $0.last_opened > $1.last_opened }                      // later date goes first
        case .title:                                                            // a to z
            books.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending } // ignore case
        case .progress:                                                         // most done first
            books.sort { $0.progress > $1.progress }                            // higher progress first
        }                                                                       // end sort switch

        visible_books = books                                                   // save the result
        update_count_label()                                                    // fix the count text
        table_view.reloadData()                                                 // redraw the table
    }                                                                           // end refresh_list

    private func update_count_label() {                                         // count text plus empty state
        let total = visible_books.count                                         // how many we show
        count_label.text = total == 1 ? "1 book" : "\(total) books"             // singular vs plural
        if visible_books.isEmpty {                                              // nothing to show
            let empty_label = app_theme.make_label("No books match", size: 15, weight: .regular, color: app_theme.muted_color) // empty message
            empty_label.textAlignment = .center                                 // center it in the table
            table_view.backgroundView = empty_label                             // table sizes it for us
        } else {                                                                // we have books
            table_view.backgroundView = nil                                     // remove the empty message
        }                                                                       // end empty check
    }                                                                           // end update_count_label

    private func present_add_book() {                                           // opens add book sheet
        let edit_screen = edit_book_view_controller(book: nil) { [weak self] saved_book in // nil means add mode
            book_store.shared.save(saved_book)                                  // presenter saves to the store
            self?.refresh_list()                                                // sheet wont trigger viewWillAppear
        }                                                                       // end on_save
        (presentedViewController ?? self).present(app_navigation_controller(rootViewController: edit_screen), animated: true) // show as a sheet, from the search bar if it is up
    }                                                                           // end present_add_book

    override func setEditing(_ editing: Bool, animated: Bool) {                 // edit button toggles this
        super.setEditing(editing, animated: animated)                           // updates the edit button title
        table_view.setEditing(editing, animated: animated)                      // put the table in edit mode too
    }                                                                           // end setEditing

    // MARK: search                                                             // search updater section

    func updateSearchResults(for searchController: UISearchController) {        // called as they type
        refresh_list()                                                          // refilter the list
    }                                                                           // end updateSearchResults

    // MARK: table data source                                                  // data source section

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // row count
        return visible_books.count                                              // one row per book
    }                                                                           // end numberOfRowsInSection

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // builds a row
        guard let cell = tableView.dequeueReusableCell(withIdentifier: book_cell.reuse_identifier, for: indexPath) as? book_cell else { // grab our cell
            return UITableViewCell()                                            // fallback that should never happen
        }                                                                       // end guard
        cell.configure(with: visible_books[indexPath.row])                      // fill it with the book
        return cell                                                             // hand it back
    }                                                                           // end cellForRowAt

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { // swipe or edit delete
        guard editingStyle == .delete else { return }                           // only handle delete
        let book = visible_books[indexPath.row]                                 // book being removed
        book_store.shared.delete_book(id: book.id)                              // remove from the store
        visible_books.remove(at: indexPath.row)                                 // remove from our list
        tableView.deleteRows(at: [indexPath], with: .automatic)                 // animate the row out
        update_count_label()                                                    // fix count and empty state
    }                                                                           // end commit editingStyle

    // MARK: table delegate                                                     // delegate section

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // row tapped
        tableView.deselectRow(at: indexPath, animated: true)                    // clear the highlight
        let book = visible_books[indexPath.row]                                 // book that was tapped
        if tableView.isEditing {                                                // edit mode opens edit book
            let edit_screen = edit_book_view_controller(book: book) { [weak self] saved_book in // edit this book
                book_store.shared.save(saved_book)                              // presenter saves to the store
                self?.refresh_list()                                            // show the changes
            }                                                                   // end on_save
            (presentedViewController ?? self).present(app_navigation_controller(rootViewController: edit_screen), animated: true) // show as a sheet, from the search bar if it is up
        } else {                                                                // normal mode opens the reader
            navigationController?.pushViewController(reader_view_controller(book_id: book.id), animated: true) // go read it
        }                                                                       // end editing check
    }                                                                           // end didSelectRowAt
}                                                                               // end library_view_controller
