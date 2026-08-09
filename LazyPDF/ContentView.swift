import AppKit
import PDFKit
import Combine
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    var body: some View {
        ZStack {
            LiquidBackdrop()

            VStack(spacing: 18) {
                HeaderView()

                HStack(alignment: .top, spacing: 18) {
                    PDFQueueView()
                        .frame(minWidth: 560)

                    ExportPanel()
                        .frame(width: 260)
                }
            }
            .padding(24)
        }
    }
}

struct HeaderView: View {
    @EnvironmentObject private var store: PDFMergeStore

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("LazyPDF")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                Text("Une PDFs y exporta copias desbloqueadas cuando tienes la contraseña.")
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                store.presentOpenPanel()
            } label: {
                Label("Agregar", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button {
                store.clear()
            } label: {
                Image(systemName: "trash")
            }
            .help("Vaciar lista")
            .buttonStyle(GlassIconButtonStyle())
            .disabled(store.items.isEmpty)
        }
    }
}

struct PDFQueueView: View {
    @EnvironmentObject private var store: PDFMergeStore
    @State private var isDropTargeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Cola de unión", systemImage: "rectangle.stack")
                    .font(.headline)
                Spacer()
                Text("\(store.totalPages) páginas")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(store.items) { item in
                        PDFRow(item: item)
                    }
                }
                .padding(10)
            }
            .frame(minHeight: 360)
            .scrollIndicators(.visible)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.22), lineWidth: 1)
            }
            .overlay {
                if store.items.isEmpty {
                    EmptyDropView(isTargeted: isDropTargeted)
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))
                }
            }
            .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
                store.loadDroppedFiles(from: providers)
            }
        }
    }
}

struct PDFRow: View {
    @EnvironmentObject private var store: PDFMergeStore
    let item: PDFItem

    var body: some View {
        HStack(spacing: 12) {
            ThumbnailView(image: item.thumbnail)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(item.url.lastPathComponent)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                    Spacer()
                    StatusBadge(item: item)
                }

                HStack(spacing: 10) {
                    Label(item.pageCountText, systemImage: "doc.text")
                        .foregroundStyle(.secondary)

                    Text(item.url.deletingLastPathComponent().path)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
                .font(.caption)

                if item.needsPassword {
                    HStack(spacing: 8) {
                        SecureField("Contraseña", text: store.passwordBinding(for: item.id))
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 260)
                            .onSubmit {
                                store.unlock(itemID: item.id)
                            }

                        Button {
                            store.unlock(itemID: item.id)
                        } label: {
                            Label("Desbloquear", systemImage: "lock.open")
                        }
                        .disabled(item.password.isEmpty)

                        if let error = item.error {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .lineLimit(1)
                        }
                    }
                }
            }

            VStack(spacing: 6) {
                Button {
                    store.move(itemID: item.id, direction: -1)
                } label: {
                    Image(systemName: "chevron.up")
                }
                .help("Subir")
                .buttonStyle(GlassIconButtonStyle())

                Button {
                    store.move(itemID: item.id, direction: 1)
                } label: {
                    Image(systemName: "chevron.down")
                }
                .help("Bajar")
                .buttonStyle(GlassIconButtonStyle())
            }

            Button {
                store.remove(itemID: item.id)
            } label: {
                Image(systemName: "xmark")
            }
            .help("Quitar")
            .buttonStyle(GlassIconButtonStyle())
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.24), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.10), radius: 18, y: 8)
    }
}

struct ExportPanel: View {
    @EnvironmentObject private var store: PDFMergeStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Exportar", systemImage: "square.and.arrow.down")
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                MetricLine(title: "Archivos", value: "\(store.items.count)")
                MetricLine(title: "Páginas", value: "\(store.totalPages)")
                MetricLine(title: "Bloqueados", value: "\(store.lockedCount)")
            }

            Divider()

            Text(store.statusMessage)
                .font(.callout)
                .foregroundStyle(store.canExport ? Color.secondary : Color.orange)
                .frame(minHeight: 44, alignment: .topLeading)

            Spacer()

            Button {
                store.presentSavePanel()
            } label: {
                Label(store.isExporting ? "Exportando..." : "Unir PDFs", systemImage: "wand.and.sparkles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!store.canExport || store.isExporting)
        }
        .padding(18)
        .frame(maxHeight: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.28), lineWidth: 1)
        }
    }
}

struct EmptyDropView: View {
    let isTargeted: Bool

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 54, weight: .light))
                .symbolRenderingMode(.hierarchical)

            Text("Arrastra PDFs aquí")
                .font(.title2.weight(.semibold))

            Text("También puedes usar el botón Agregar.")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 42)
        .padding(.horizontal, 58)
        .background(isTargeted ? .regularMaterial : .ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [8, 6]))
                .foregroundStyle(.white.opacity(isTargeted ? 0.62 : 0.28))
        }
        .scaleEffect(isTargeted ? 1.03 : 1)
        .animation(.spring(response: 0.24, dampingFraction: 0.82), value: isTargeted)
    }
}

struct ThumbnailView: View {
    let image: NSImage?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.thinMaterial)

            if let image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .padding(4)
            } else {
                Image(systemName: "doc.richtext")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 54, height: 72)
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(.white.opacity(0.24), lineWidth: 1)
        }
    }
}

struct StatusBadge: View {
    let item: PDFItem

    var body: some View {
        Label(item.statusText, systemImage: item.statusIcon)
            .font(.caption.weight(.medium))
            .foregroundStyle(item.statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(item.statusColor.opacity(0.12), in: Capsule())
    }
}

struct MetricLine: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .monospacedDigit()
        }
    }
}

struct LiquidBackdrop: View {
    var body: some View {
        ZStack {
            VisualEffectBackdrop()

            Color.black.opacity(0.16)
        }
        .ignoresSafeArea()
    }
}

struct VisualEffectBackdrop: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }

    func updateNSView(_ view: NSVisualEffectView, context: Context) {}
}

struct GlassIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .frame(width: 30, height: 30)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 9, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(.white.opacity(configuration.isPressed ? 0.38 : 0.22), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct PDFItem: Identifiable, Equatable {
    let id = UUID()
    let url: URL
    var pageCount: Int?
    var isEncrypted: Bool
    var isUnlocked: Bool
    var password = ""
    var error: String?
    var thumbnail: NSImage?

    var needsPassword: Bool {
        isEncrypted && !isUnlocked
    }

    var pageCountText: String {
        guard let pageCount else { return "Bloqueado" }
        return pageCount == 1 ? "1 página" : "\(pageCount) páginas"
    }

    var statusText: String {
        if error != nil { return "Error" }
        if needsPassword { return "Contraseña" }
        if isEncrypted { return "Desbloqueado" }
        return "Listo"
    }

    var statusIcon: String {
        if error != nil { return "exclamationmark.triangle" }
        if needsPassword { return "lock" }
        if isEncrypted { return "lock.open" }
        return "checkmark"
    }

    var statusColor: Color {
        if error != nil { return .red }
        if needsPassword { return .orange }
        if isEncrypted { return .mint }
        return .green
    }
}

@MainActor
final class PDFMergeStore: ObservableObject {
    @Published var items: [PDFItem] = []
    @Published var statusMessage = "Agrega PDFs para empezar."
    @Published var isExporting = false

    var totalPages: Int {
        items.compactMap(\.pageCount).reduce(0, +)
    }

    var lockedCount: Int {
        items.filter(\.needsPassword).count
    }

    var canExport: Bool {
        !items.isEmpty && lockedCount == 0 && !isExporting
    }

    func presentOpenPanel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.pdf]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.prompt = "Agregar"

        if panel.runModal() == .OK {
            add(urls: panel.urls)
        }
    }

    func presentSavePanel() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = "PDF unido.pdf"
        panel.prompt = "Exportar"

        if panel.runModal() == .OK, let url = panel.url {
            export(to: url)
        }
    }

    func loadDroppedFiles(from providers: [NSItemProvider]) -> Bool {
        for provider in providers where provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                let url: URL?

                if let data = item as? Data {
                    url = URL(dataRepresentation: data, relativeTo: nil)
                } else {
                    url = item as? URL
                }

                guard let url else { return }

                Task { @MainActor in
                    self.add(urls: [url])
                }
            }
        }

        return true
    }

    func add(urls: [URL]) {
        let pdfURLs = urls
            .filter { $0.pathExtension.lowercased() == "pdf" }
            .filter { url in !items.contains { $0.url == url } }

        for url in pdfURLs {
            items.append(makeItem(from: url))
        }

        updateStatus()
    }

    func clear() {
        items.removeAll()
        statusMessage = "Agrega PDFs para empezar."
    }

    func remove(itemID: UUID) {
        items.removeAll { $0.id == itemID }
        updateStatus()
    }

    func move(itemID: UUID, direction: Int) {
        guard let currentIndex = items.firstIndex(where: { $0.id == itemID }) else { return }
        let newIndex = currentIndex + direction
        guard items.indices.contains(newIndex) else { return }
        items.swapAt(currentIndex, newIndex)
    }

    func passwordBinding(for itemID: UUID) -> Binding<String> {
        Binding(
            get: { self.items.first(where: { $0.id == itemID })?.password ?? "" },
            set: { newValue in
                guard let index = self.items.firstIndex(where: { $0.id == itemID }) else { return }
                self.items[index].password = newValue
                self.items[index].error = nil
            }
        )
    }

    func unlock(itemID: UUID) {
        guard let index = items.firstIndex(where: { $0.id == itemID }) else { return }
        let password = items[index].password

        guard !password.isEmpty else {
            items[index].error = "Falta contraseña"
            return
        }

        guard let document = PDFDocument(url: items[index].url) else {
            items[index].error = "No se pudo abrir"
            return
        }

        guard document.unlock(withPassword: password) else {
            items[index].error = "Contraseña incorrecta"
            return
        }

        items[index].isUnlocked = true
        items[index].pageCount = document.pageCount
        items[index].thumbnail = thumbnail(for: document)
        items[index].error = nil
        updateStatus()
    }

    func export(to outputURL: URL) {
        isExporting = true
        statusMessage = "Exportando PDF..."

        do {
            let merged = PDFDocument()
            var destinationIndex = 0

            for item in items {
                guard let source = PDFDocument(url: item.url) else {
                    throw PDFMergeError.cannotOpen(item.url.lastPathComponent)
                }

                if source.isLocked, !source.unlock(withPassword: item.password) {
                    throw PDFMergeError.locked(item.url.lastPathComponent)
                }

                for pageIndex in 0..<source.pageCount {
                    guard let page = source.page(at: pageIndex) else { continue }
                    merged.insert(page, at: destinationIndex)
                    destinationIndex += 1
                }
            }

            guard destinationIndex > 0 else {
                throw PDFMergeError.empty
            }

            guard merged.write(to: outputURL) else {
                throw PDFMergeError.writeFailed
            }

            statusMessage = "Listo: \(outputURL.lastPathComponent)"
        } catch {
            statusMessage = error.localizedDescription
        }

        isExporting = false
    }

    private func makeItem(from url: URL) -> PDFItem {
        guard let document = PDFDocument(url: url) else {
            return PDFItem(
                url: url,
                pageCount: nil,
                isEncrypted: false,
                isUnlocked: false,
                error: "No se pudo abrir"
            )
        }

        let isEncrypted = document.isEncrypted
        let isLocked = document.isLocked

        return PDFItem(
            url: url,
            pageCount: isLocked ? nil : document.pageCount,
            isEncrypted: isEncrypted,
            isUnlocked: !isLocked,
            thumbnail: isLocked ? nil : thumbnail(for: document)
        )
    }

    private func thumbnail(for document: PDFDocument) -> NSImage? {
        guard let page = document.page(at: 0) else { return nil }
        return page.thumbnail(of: CGSize(width: 96, height: 128), for: .mediaBox)
    }

    private func updateStatus() {
        if items.isEmpty {
            statusMessage = "Agrega PDFs para empezar."
        } else if lockedCount > 0 {
            statusMessage = "Desbloquea \(lockedCount) PDF antes de exportar."
        } else {
            statusMessage = "Todo listo para unir y exportar sin contraseña."
        }
    }
}

enum PDFMergeError: LocalizedError {
    case cannotOpen(String)
    case locked(String)
    case empty
    case writeFailed

    var errorDescription: String? {
        switch self {
        case .cannotOpen(let name):
            "No se pudo abrir \(name)."
        case .locked(let name):
            "\(name) sigue bloqueado."
        case .empty:
            "No hay páginas para exportar."
        case .writeFailed:
            "No se pudo escribir el PDF final."
        }
    }
}
