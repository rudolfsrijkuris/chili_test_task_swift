# GIF Search App

A Swift-based iOS application for searching and viewing GIFs using the Giphy API. The app features auto-search functionality, infinite scrolling, and a detailed view for individual GIFs.

## Demo

![App Demo](demo_video.gif)

## Features

- **Auto Search**: Automatically performs search after 300ms of user input pause
- **Infinite Scrolling**: Load more GIFs as you scroll to the bottom of the grid
- **Grid Layout**: Display GIFs in a responsive 2-column grid
- **Detailed View**: View GIFs in full screen with additional metadata
- **Error Handling**: User-friendly error messages and loading states
- **Media Handling**: Support for both GIF and MP4 formats
- **Save**: Save GIFs to Photos app
- **No External Dependencies**: Pure SwiftUI and AVKit implementation

## Requirements

- iOS 18.2+
- Xcode 15.0+
- Swift 5.0+
- Giphy API Key

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
```

2. Create a `Config.xcconfig` file in the project root with your Giphy API key:
```
GIPHY_API_KEY = your_api_key_here
```

3. Open `chilli_test_task.xcodeproj` in Xcode

4. Build and run the project

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern with SwiftUI:

### Models
- `GiphyGif`: Core model representing a GIF with metadata
- `GiphyImage`: Image URLs and dimensions with aspect ratio calculations
- `GiphyVideoImage`: Video-specific metadata and URLs
- `GiphySearchResponse`: API response with pagination support

### Views
- `GifSearchView`: Main view with search and grid layout
- `GifDetailView`: Detailed view with metadata and actions
- `VideoPlayerView`: AVKit-based video player for MP4s
- `GifGridItem`: Grid item component with async image loading

### ViewModels
- `GifSearchViewModel`: Manages search state, pagination, and data loading
- `MediaDownloader`: Handles saving media to Photos

### Networking
- `GiphyAPIClient`: Type-safe API client with proper error handling
- `Configuration`: Secure API key management with environment variable support

## Key Features Implementation

### Auto Search
The search functionality uses Combine's debounce operator to optimize API calls:

```swift
searchSubject
    .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
    .sink { [weak self] query in
        self?.performSearch(query: query)
    }
```

### Infinite Scrolling
Implemented using SwiftUI's LazyVGrid with pagination:

```swift
if gif.id == viewModel.gifs.last?.id {
    viewModel.loadMore()
}
```

### Error Handling
Comprehensive error handling with user-friendly messages:

```swift
enum GiphyAPIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse(Int)
    case decodingError(Error)
}
```

### Media Handling
Support for both GIF and MP4 formats with optimal quality selection:

```swift
var bestVideoUrl: URL? {
    if let mp4Url = originalMp4?.mp4 {
        return URL(string: mp4Url)
    }
    if let mp4Url = original.mp4 {
        return URL(string: mp4Url)
    }
    return nil
}
```

## Configuration

The app uses xcconfig files for secure configuration:

- `Config.xcconfig.template`: Template for configuration
- `Config.xcconfig`: (gitignored) Contains actual API keys

## Security

- API keys stored in xcconfig files (not in source control)
- Proper permission handling for Photos access
- Input validation and error handling
- Secure URL construction and response validation

## Acknowledgments

- [Giphy API](https://developers.giphy.com/docs/api/) for the GIF service
- SwiftUI for the modern UI framework
- AVKit for video playback
- Combine for reactive programming 