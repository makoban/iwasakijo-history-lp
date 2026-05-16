import AVFoundation
import Foundation

if CommandLine.arguments.count < 4 {
    fputs("usage: concat_videos.swift <output.mp4> <input1.mp4> <input2.mp4> [...]\n", stderr)
    exit(2)
}

let outputURL = URL(fileURLWithPath: CommandLine.arguments[1])
let inputURLs = CommandLine.arguments.dropFirst(2).map { URL(fileURLWithPath: $0) }

let composition = AVMutableComposition()
guard let compositionVideo = composition.addMutableTrack(
    withMediaType: .video,
    preferredTrackID: kCMPersistentTrackID_Invalid
) else {
    fputs("failed to create video track\n", stderr)
    exit(1)
}

let compositionAudio = composition.addMutableTrack(
    withMediaType: .audio,
    preferredTrackID: kCMPersistentTrackID_Invalid
)

var cursor = CMTime.zero
var preferredTransformSet = false

for inputURL in inputURLs {
    let asset = AVURLAsset(url: inputURL)
    let duration = asset.duration

    guard let sourceVideo = asset.tracks(withMediaType: .video).first else {
        fputs("no video track: \(inputURL.path)\n", stderr)
        exit(1)
    }

    if !preferredTransformSet {
        compositionVideo.preferredTransform = sourceVideo.preferredTransform
        preferredTransformSet = true
    }

    do {
        try compositionVideo.insertTimeRange(
            CMTimeRange(start: .zero, duration: duration),
            of: sourceVideo,
            at: cursor
        )

        if let sourceAudio = asset.tracks(withMediaType: .audio).first,
           let compositionAudio {
            try compositionAudio.insertTimeRange(
                CMTimeRange(start: .zero, duration: duration),
                of: sourceAudio,
                at: cursor
            )
        }
    } catch {
        fputs("insert failed for \(inputURL.path): \(error)\n", stderr)
        exit(1)
    }

    cursor = cursor + duration
}

if FileManager.default.fileExists(atPath: outputURL.path) {
    try FileManager.default.removeItem(at: outputURL)
}

guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset1280x720) else {
    fputs("failed to create exporter\n", stderr)
    exit(1)
}

exporter.outputURL = outputURL
exporter.outputFileType = .mp4
exporter.shouldOptimizeForNetworkUse = true

let semaphore = DispatchSemaphore(value: 0)
exporter.exportAsynchronously {
    semaphore.signal()
}
semaphore.wait()

switch exporter.status {
case .completed:
    print(outputURL.path)
case .failed:
    fputs("export failed: \(exporter.error?.localizedDescription ?? "unknown error")\n", stderr)
    exit(1)
case .cancelled:
    fputs("export cancelled\n", stderr)
    exit(1)
default:
    fputs("export ended with status \(exporter.status.rawValue)\n", stderr)
    exit(1)
}
