import SwiftUI
import SQLite
import AppKit

@main
struct ZyloqApp: App {
  @State var searchText: String = ""
  @State var places: [Place] = [];
  @State var favorites: [Favorite] = []
  @State var db: Connection? = loadDb()
  @State private var showAbout = false
  
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
              Menu {
                Button("Delete") {
                  removeFavorite(db: db, id: favorite.id)
                  favorites = fetchFavorites(db: db)
                }
              } label: {}
                .menuStyle(.borderlessButton)
                .fixedSize()
                .buttonStyle(.plain)
            }
            .padding(.vertical, 2)
          }
          
          Divider()
        }
        
        if favorites.count < 20 {
          //                    TODO: Auto-focus the text field on appear.
          TextField("Enter your city", text: $searchText)
            .onChange(of: searchText) { _, val in
              places = fetchPlaces(db: db, searchText: searchText)
            }
            .onSubmit {
              if !places.isEmpty {
                let isFavorite = favorites.contains(where: { $0.place.id == places.first!.id })
                if !isFavorite {
                  addFavorite(db: db, place: places.first!)
                  favorites = fetchFavorites(db: db)
                }
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
              let isFavorite = favorites.contains(where: { $0.place.id == place.id })
              
              Button {
                if !isFavorite {
                  addFavorite(db: db, place: place)
                  favorites = fetchFavorites(db: db)
                }
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
              .opacity(isFavorite ? 0.5 : 1)
            }
          }
        } else {
          Text("Max. 20 favorites are permitted")
            .onAppear {
              searchText = ""
              places = []
            }
        }
        
        Divider()
        
        HStack {
          Button("ⓘ") {}
          .buttonStyle(.plain)
          .onHover(perform: { hovering in
            showAbout = hovering
          })
          .popover(isPresented: $showAbout, arrowEdge: .bottom) {
            VStack(spacing: 16) {
              Text("Zonic is made available under MIT license. The DB is made available under ODbL.")
                .multilineTextAlignment(.center)
                .font(.caption)
            }
            .padding()
            .frame(minWidth: 300)
          }
          
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
