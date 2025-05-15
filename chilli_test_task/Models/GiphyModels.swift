import Foundation

struct GiphySearchResponse: Codable {
    let data: [GiphyGif]
    let pagination: GiphyPagination
    let meta: GiphyMeta
}

struct GiphyGif: Codable, Identifiable {
    let id: String
    let title: String
    let images: GiphyImages
    let username: String?
    let rating: String?
}

struct GiphyImages: Codable {
    let original: GiphyImage
    let fixedWidth: GiphyImage?
    let fixedHeight: GiphyImage?
    let fixedWidthSmall: GiphyImage?
    let fixedHeightSmall: GiphyImage?
    let downsized: GiphyImage?
    let originalMp4: GiphyVideoImage?
    
    enum CodingKeys: String, CodingKey {
        case original
        case fixedWidth = "fixed_width"
        case fixedHeight = "fixed_height"
        case fixedWidthSmall = "fixed_width_small"
        case fixedHeightSmall = "fixed_height_small"
        case downsized
        case originalMp4 = "original_mp4"
    }
    
    // Helper method to get the best available image for grid display
    var bestForGrid: GiphyImage {
        return fixedWidth ?? 
               fixedHeight ?? 
               fixedWidthSmall ?? 
               fixedHeightSmall ?? 
               downsized ?? 
               original
    }
    
    // Helper method to get the best available video URL
    var bestVideoUrl: URL? {
        if let mp4Url = originalMp4?.mp4 {
            return URL(string: mp4Url)
        }
        if let mp4Url = original.mp4 {
            return URL(string: mp4Url)
        }
        return nil
    }
}

struct GiphyImage: Codable {
    let url: String
    let mp4: String?
    let width: String
    let height: String
    
    // Computed properties for numeric dimensions
    var widthFloat: CGFloat {
        return CGFloat(Float(width) ?? 0)
    }
    
    var heightFloat: CGFloat {
        return CGFloat(Float(height) ?? 0)
    }
    
    var aspectRatio: CGFloat {
        guard heightFloat > 0 else { return 1 }
        return widthFloat / heightFloat
    }
}

struct GiphyVideoImage: Codable {
    let mp4: String
    let mp4Size: String
    let width: String
    let height: String
    
    enum CodingKeys: String, CodingKey {
        case mp4
        case mp4Size = "mp4_size"
        case width
        case height
    }
    
    var widthFloat: CGFloat {
        return CGFloat(Float(width) ?? 0)
    }
    
    var heightFloat: CGFloat {
        return CGFloat(Float(height) ?? 0)
    }
    
    var aspectRatio: CGFloat {
        guard heightFloat > 0 else { return 1 }
        return widthFloat / heightFloat
    }
}

struct GiphyPagination: Codable {
    let totalCount: Int32
    let count: Int32
    let offset: Int32
}

struct GiphyMeta: Codable {
    let status: Int
    let msg: String
    let responseId: String
} 