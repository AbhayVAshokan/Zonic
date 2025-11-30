import SwiftUI
import SQLite

@main
struct ZyloqApp: App {
    @State var searchText: String = ""
    @State var places: [Place] = [];
    @State var favorites: [Favorite] = []
    @State var db: Connection? = loadDb()

    var body: some Scene {
        MenuBarExtra("67", systemImage: "\(7).circle") {
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
                        HStack {
                            Text(place.flag)
                            Text(place.name)
                            Spacer()
                            TimeField(timezone: place.timezone)
                        }
                        .padding(.vertical, 2)
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
