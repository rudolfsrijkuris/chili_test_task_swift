import SwiftUI
import AVKit

struct GifDetailView: View {
    let gif: GiphyGif
    @State private var showingAlert = false
    @State private var alertType: AlertType = .error
    @State private var alertMessage = ""
    
    enum AlertType {
        case success, error
        
        var title: String {
            self == .success ? "Success" : "Error"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                mediaView
                detailsView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: saveGif) {
                    Image(systemName: "square.and.arrow.down")
                }
            }
        }
        .alert(alertType.title, isPresented: $showingAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }
    
    private var mediaView: some View {
        GeometryReader { geometry in
            if let url = gif.images.bestVideoUrl {
                VideoPlayerView(url: url)
                    .frame(width: geometry.size.width, height: geometry.size.width / gif.images.original.aspectRatio)
            } else {
                AsyncImage(url: URL(string: gif.images.original.url)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.width / gif.images.original.aspectRatio)
            }
        }
        .frame(height: UIScreen.main.bounds.width / gif.images.original.aspectRatio)
    }
    
    private var detailsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !gif.title.isEmpty {
                Text(gif.title)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                DetailRow(label: "ID", value: gif.id)
                DetailRow(label: "Size", value: "\(Int(gif.images.original.widthFloat))×\(Int(gif.images.original.heightFloat))")
                if let username = gif.username, !username.isEmpty {
                    DetailRow(label: "Creator", value: username)
                }
                if let rating = gif.rating?.uppercased() {
                    DetailRow(label: "Rating", value: rating)
                }
            }
            .font(.subheadline)
        }
        .padding(.horizontal)
    }
    
    private func saveGif() {
        guard let url = gif.images.bestVideoUrl ?? URL(string: gif.images.original.url) else {
            alertType = .error
            alertMessage = "Could not get media URL"
            showingAlert = true
            return
        }
        
        Task {
            do {
                try await MediaDownloader.downloadAndSave(url: url)
                await MainActor.run {
                    alertType = .success
                    alertMessage = "Successfully saved to Photos"
                    showingAlert = true
                }
            } catch MediaDownloadError.noPermission {
                await MainActor.run {
                    alertType = .error
                    alertMessage = "Please allow access to Photos in Settings to save GIFs"
                    showingAlert = true
                }
            } catch {
                await MainActor.run {
                    alertType = .error
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
}

private struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}