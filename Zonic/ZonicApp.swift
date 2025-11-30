import SwiftUI
import SQLite
import AppKit

@main
struct ZyloqApp: App {
    @State var searchText: String = ""
    @State var places: [Place] = [];
    @State var favorites: [Favorite] = []
    @State var db: Connection? = loadDb()

    var body: some Scene {
        MenuBarExtra("₪") {
            VStack {
                
                if !favorites.isEmpty {
                    ForEach(favorites, id: \.id) { favorite in
                        HStack {
                            Text(favorite.place.flag)
                            Text(favorite.place.name)
                            Spacer()
                            TimeField(timezone: favorite.place.timezone)
                        }
                        .padding(.vertical, 2)
                    }
                    
                    Divider()
                }

                if favorites.count < 15 {
//                    TODO: Auto-focus the text field on appear.
                    TextField("Enter your city", text: $searchText)
                        .onChange(of: searchText) { _, val in
                            places = fetchPlaces(db: db, searchText: searchText)
                        }
                }

                if searchText != "" {
                    Divider()
                    
                    if places.isEmpty {
                        Text("No places found")
                    }
                }
                
                if !places.isEmpty {
                    ForEach(places, id: \.id) { place in
                        Button {
                            print(place.name)
                        } label: {
                            HStack {
                                Text(place.flag)
                                Text(place.name)
                                Spacer()
                                TimeField(timezone: place.timezone)
                            }
                            .padding(.vertical, 2)
                            .contentShape(Rectangle())
                            .onHover { hovering in
                                if hovering {
                                    NSCursor.pointingHand.push()
                                } else {
                                    NSCursor.pop()
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .opacity(favorites.contains(where: { $0.place.id == place.id }) ? 0.5 : 1)
                    }
                }

                Divider()
                
                HStack {
                    Spacer()
                    Button("Quit") {
                        NSApplication.shared.terminate(self)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .onAppear {
                favorites = fetchFavorites(db: db)
            }
            .onDisappear {
                searchText = ""
            }
        }
        .menuBarExtraStyle(.window)
    }
}
