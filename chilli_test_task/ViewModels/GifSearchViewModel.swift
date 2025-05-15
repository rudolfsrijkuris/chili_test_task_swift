import Foundation
import Combine

@MainActor
class GifSearchViewModel: ObservableObject {
    @Published private(set) var gifs: [GiphyGif] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    private let apiClient: GiphyAPIClient
    private var searchTask: Task<Void, Never>?
    private var currentOffset: Int32 = 0
    private var currentQuery = ""
    private var canLoadMore = true
    
    private var searchSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(apiClient: GiphyAPIClient = GiphyAPIClient(apiKey: Configuration.giphyApiKey)) {
        self.apiClient = apiClient
        setupSearchDebounce()
    }
    
    private func setupSearchDebounce() {
        searchSubject
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                print("Debounced search query: \(query)")
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    func search(query: String) {
        print("Search called with query: \(query)")
        currentQuery = query
        currentOffset = 0
        canLoadMore = true
        gifs = []
        searchSubject.send(query)
    }
    
    func loadMore() {
        guard !isLoading && canLoadMore else { return }
        performSearch(query: currentQuery, loadMore: true)
    }
    
    private func performSearch(query: String, loadMore: Bool = false) {
        guard !query.isEmpty else {
            print("Empty query, clearing results")
            gifs = []
            return
        }
        
        print("Performing search with query: \(query), loadMore: \(loadMore)")
        searchTask?.cancel()
        
        searchTask = Task {
            do {
                isLoading = true
                error = nil
                
                let response = try await apiClient.search(
                    query: query,
                    offset: loadMore ? currentOffset : 0
                )
                
                print("Search response received. GIFs count: \(response.data.count)")
                
                if loadMore {
                    gifs.append(contentsOf: response.data)
                } else {
                    gifs = response.data
                }
                
                currentOffset = Int32(gifs.count)
                canLoadMore = response.pagination.totalCount > Int32(gifs.count)
                
            } catch {
                print("Search error: \(error)")
                self.error = error
            }
            
            isLoading = false
        }
    }
} 