import SwiftUI

@main
struct LazyPDFApp: App {
    @StateObject private var store = PDFMergeStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 900, minHeight: 620)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Agregar PDFs...") {
                    store.presentOpenPanel()
                }
                .keyboardShortcut("o", modifiers: [.command])
            }
        }
    }
}
