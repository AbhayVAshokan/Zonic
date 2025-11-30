import Combine
import SwiftUI

struct TimeField: View {
    let timezone: String
    @State private var currentTime = ""
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(currentTime)
            .onAppear {
                updateTime()
            }
            .onReceive(timer) { _ in
                updateTime()
            }
    }
    
    func updateTime() {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: timezone)
        formatter.dateFormat = "h:mm a"
        currentTime = formatter.string(from: Date())
    }
}

