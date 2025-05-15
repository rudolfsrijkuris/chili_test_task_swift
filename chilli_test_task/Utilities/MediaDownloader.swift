import Foundation
import Photos

enum MediaDownloadError: LocalizedError {
    case downloadFailed
    case saveToPhotosFailed(Error?)
    case noPermission
    
    var errorDescription: String? {
        switch self {
        case .downloadFailed:
            return "Failed to download the media"
        case .saveToPhotosFailed(let error):
            if let error = error {
                return "Failed to save to Photos: \(error.localizedDescription)"
            }
            return "Failed to save to Photos"
        case .noPermission:
            return "No permission to access Photos"
        }
    }
}

class MediaDownloader {
    static func downloadAndSave(url: URL) async throws {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        if status == .notDetermined {
            let granted = await PHPhotoLibrary.requestAuthorization(for: .addOnly) == .authorized
            if !granted {
                throw MediaDownloadError.noPermission
            }
        } else if status != .authorized {
            throw MediaDownloadError.noPermission
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if url.pathExtension.lowercased() == "mp4" {
            try await saveVideo(data: data)
        } else {
            try await saveImage(data: data)
        }
    }
    
    private static func saveVideo(data: Data) async throws {
        let downloadURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")
        
        try data.write(to: downloadURL)
        
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: downloadURL)
        }
        
        try? FileManager.default.removeItem(at: downloadURL)
    }
    
    private static func saveImage(data: Data) async throws {
        try await PHPhotoLibrary.shared().performChanges {
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: .photo, data: data, options: nil)
        }
    }
} 