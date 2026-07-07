import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingItem: RestStop?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.items) { item in
                    Button {
                        editingItem = item
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(item.stopName)")
                                .font(Theme.headingFont)
                                .foregroundStyle(Theme.ink)
                            Text("\(item.highway)")
                                .font(Theme.captionFont)
                                .foregroundStyle(Theme.secondaryInk)
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityIdentifier("itemRow_\(item.id)")
                }
                .onDelete { offsets in
                    store.delete(at: offsets)
                }
                .listRowBackground(Theme.cardBackground)
            }
            .scrollContentBackground(.hidden)
            .themedBackground()
            .navigationTitle("Roadside Rest Stops")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EntryEditorView(mode: .add)
            }
            .sheet(item: $editingItem) { item in
                EntryEditorView(mode: .edit(item))
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

enum EditorMode: Identifiable, Equatable {
    case add
    case edit(RestStop)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return item.id.uuidString
        }
    }
}

struct EntryEditorView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    let mode: EditorMode

    @State private var draftStopname: String = ""
    @State private var draftHighway: String = ""
    @State private var draftRating: Int = 0
    @State private var draftHasfood: Bool = false
    @State private var draftHasfuel: Bool = false
    @State private var draftHasrestrooms: Bool = false
    @State private var draftNotes: String = ""

    init(mode: EditorMode) {
        self.mode = mode
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("RestStop Details") {
                TextField("Stopname", text: $draftStopname)
                    .accessibilityIdentifier("field_stopName")
                TextField("Highway", text: $draftHighway)
                    .accessibilityIdentifier("field_highway")
                Stepper("Rating: \(draftRating)", value: $draftRating, in: 0...9999)
                    .accessibilityIdentifier("field_rating")
                Toggle("Hasfood", isOn: $draftHasfood)
                    .accessibilityIdentifier("field_hasFood")
                Toggle("Hasfuel", isOn: $draftHasfuel)
                    .accessibilityIdentifier("field_hasFuel")
                Toggle("Hasrestrooms", isOn: $draftHasrestrooms)
                    .accessibilityIdentifier("field_hasRestrooms")
                TextField("Notes", text: $draftNotes)
                    .accessibilityIdentifier("field_notes")
                }

                if case .edit(let item) = mode {
                    Section {
                        Button("Delete", role: .destructive) {
                            store.delete(item)
                            dismiss()
                        }
                        .accessibilityIdentifier("deleteButton")
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .themedBackground()
            .scrollContentBackground(.hidden)
            .navigationTitle(isEditing ? "Edit" : "New Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .accessibilityIdentifier("saveButton")
                }
            }
            .onAppear { loadIfEditing() }
        }
    }

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func loadIfEditing() {
        if case .edit(let item) = mode {
        draftStopname = item.stopName
        draftHighway = item.highway
        draftRating = item.rating
        draftHasfood = item.hasFood
        draftHasfuel = item.hasFuel
        draftHasrestrooms = item.hasRestrooms
        draftNotes = item.notes
        } else {
        draftStopname = ""
        draftHighway = ""
        draftRating = 0
        draftHasfood = false
        draftHasfuel = false
        draftHasrestrooms = false
        draftNotes = ""
        }
    }

    private func save() {
        switch mode {
        case .add:
            store.add(RestStop(stopName: draftStopname, highway: draftHighway, rating: draftRating, hasFood: draftHasfood, hasFuel: draftHasfuel, hasRestrooms: draftHasrestrooms, notes: draftNotes))
        case .edit(let item):
            var updated = item
            updated.stopName = draftStopname
            updated.highway = draftHighway
            updated.rating = draftRating
            updated.hasFood = draftHasfood
            updated.hasFuel = draftHasfuel
            updated.hasRestrooms = draftHasrestrooms
            updated.notes = draftNotes
            store.update(updated)
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
