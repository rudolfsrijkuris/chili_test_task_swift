import SwiftUI

struct GifSearchView: View {
    @StateObject private var viewModel = GifSearchViewModel()
    @State private var searchText = ""
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                searchBar
                
                if let error = viewModel.error {
                    errorView(error: error)
                } else if viewModel.isLoading && viewModel.gifs.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if viewModel.gifs.isEmpty && !searchText.isEmpty {
                    emptyResultsView
                } else if !searchText.isEmpty {
                    gifGrid
                } else {
                    placeholderView
                }
            }
            .navigationTitle("Gif Search")
        }
    }
    
    private var searchBar: some View {
        TextField("Search GIFs...", text: $searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .onChange(of: searchText) { oldValue, newValue in
                print("TextField onChange: \(newValue)")
                viewModel.search(query: newValue)
            }
            .autocorrectionDisabled()
    }
    
    private var gifGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.gifs) { gif in
                    NavigationLink(destination: GifDetailView(gif: gif)) {
                        GifGridItem(gif: gif)
                            .onAppear {
                                if gif.id == viewModel.gifs.last?.id {
                                    print("Reached last item, loading more...")
                                    viewModel.loadMore()
                                }
                            }
                    }
                }
            }
            .padding()
            
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            }
        }
    }
    
    private func errorView(error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("Something went wrong")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
    
    private var emptyResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundColor(.gray)
            Text("No GIFs found")
                .font(.headline)
            Text("Try a different search term")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
    
    private var placeholderView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundColor(.gray)
            Text("Search for GIFs")
                .font(.headline)
            Text("Type something in the search bar above")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct GifGridItem: View {
    let gif: GiphyGif
    private let imageSize: CGSize = CGSize(width: 150, height: 150)
    
    var body: some View {
        AsyncImage(url: URL(string: gif.images.bestForGrid.url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: imageSize.width, height: imageSize.height)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: imageSize.width, height: imageSize.height)
            case .failure(_):
                Image(systemName: "photo")
                    .foregroundColor(.gray)
                    .frame(width: imageSize.width, height: imageSize.height)
            @unknown default:
                EmptyView()
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .clipped()
    }
} 