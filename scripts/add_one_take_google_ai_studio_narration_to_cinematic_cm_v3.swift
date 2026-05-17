import AVFoundation
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let editedDir = root.appendingPathComponent("assets/seedance/tsuchi-no-shiro-v3/edited")
let narrationDir = root.appendingPathComponent("assets/seedance/tsuchi-no-shiro-v3/narration/google-ai-studio-one-take/segments")
let sourceVideo = editedDir.appendingPathComponent("tsuchi-no-shiro-cinematic-cm-v3.mp4")
let bgmSource = URL(fileURLWithPath: "/Users/banmako/Downloads/9133F42A-700A-4E3D-AF8D-8E4D4267AF3D.MP4")
let outputVideo = editedDir.appendingPathComponent("tsuchi-no-shiro-cinematic-cm-v8-one-take-narration.mp4")

struct Line {
    let id: String
    let start: Double
}

let lines: [Line] = [
    .init(id: "01", start: 0.55),
    .init(id: "02", start: 10.35),
    .init(id: "03", start: 20.35),
    .init(id: "04", start: 31.05),
    .init(id: "05", start: 41.55),
    .init(id: "06", start: 51.20),
    .init(id: "07", start: 63.25),
    .init(id: "08", start: 73.05),
    .init(id: "09", start: 83.55),
    .init(id: "10", start: 94.45),
]

func narrationURL(_ line: Line) -> URL {
    narrationDir.appendingPathComponent("\(line.id).wav")
}

for line in lines {
    if !FileManager.default.fileExists(atPath: narrationURL(line).path) {
        throw NSError(domain: "one-take-narration", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing narration segment: \(narrationURL(line).path)"])
    }
}

if FileManager.default.fileExists(atPath: outputVideo.path) {
    try FileManager.default.removeItem(at: outputVideo)
}

let sourceAsset = AVURLAsset(url: sourceVideo)
let composition = AVMutableComposition()

guard let sourceVideoTrack = try await sourceAsset.loadTracks(withMediaType: .video).first,
      let compositionVideo = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    throw NSError(domain: "one-take-narration", code: 2, userInfo: [NSLocalizedDescriptionKey: "No source video track"])
}

let sourceDuration = try await sourceAsset.load(.duration)
try compositionVideo.insertTimeRange(
    CMTimeRange(start: .zero, duration: sourceDuration),
    of: sourceVideoTrack,
    at: .zero
)
compositionVideo.preferredTransform = try await sourceVideoTrack.load(.preferredTransform)

guard let narrationTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid),
      let bgmTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    throw NSError(domain: "one-take-narration", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot create audio tracks"])
}

for line in lines {
    let audioAsset = AVURLAsset(url: narrationURL(line))
    guard let sourceAudio = try await audioAsset.loadTracks(withMediaType: .audio).first else {
        continue
    }
    let duration = try await audioAsset.load(.duration)
    try narrationTrack.insertTimeRange(
        CMTimeRange(start: .zero, duration: duration),
        of: sourceAudio,
        at: CMTime(seconds: line.start, preferredTimescale: 600)
    )
}

let bgmAsset = AVURLAsset(url: bgmSource)
if let bgmAudio = try await bgmAsset.loadTracks(withMediaType: .audio).first {
    let bgmDuration = try await bgmAsset.load(.duration)
    var cursor = CMTime.zero
    while cursor < sourceDuration {
        let remaining = CMTimeSubtract(sourceDuration, cursor)
        let useDuration = CMTimeMinimum(bgmDuration, remaining)
        try bgmTrack.insertTimeRange(
            CMTimeRange(start: .zero, duration: useDuration),
            of: bgmAudio,
            at: cursor
        )
        cursor = CMTimeAdd(cursor, useDuration)
    }
}

let narrationMix = AVMutableAudioMixInputParameters(track: narrationTrack)
narrationMix.setVolume(1.12, at: .zero)

let bgmMix = AVMutableAudioMixInputParameters(track: bgmTrack)
bgmMix.setVolume(0.12, at: .zero)
bgmMix.setVolumeRamp(
    fromStartVolume: 0.0,
    toEndVolume: 0.12,
    timeRange: CMTimeRange(start: .zero, duration: CMTime(seconds: 2.0, preferredTimescale: 600))
)
bgmMix.setVolumeRamp(
    fromStartVolume: 0.12,
    toEndVolume: 0.0,
    timeRange: CMTimeRange(start: CMTimeSubtract(sourceDuration, CMTime(seconds: 4.0, preferredTimescale: 600)), duration: CMTime(seconds: 4.0, preferredTimescale: 600))
)

let audioMix = AVMutableAudioMix()
audioMix.inputParameters = [narrationMix, bgmMix]

guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset1280x720) else {
    throw NSError(domain: "one-take-narration", code: 4, userInfo: [NSLocalizedDescriptionKey: "Cannot create exporter"])
}
exporter.outputURL = outputVideo
exporter.outputFileType = .mp4
exporter.audioMix = audioMix
exporter.shouldOptimizeForNetworkUse = true

await exporter.export()
if exporter.status != .completed {
    throw exporter.error ?? NSError(domain: "one-take-narration", code: 5, userInfo: [NSLocalizedDescriptionKey: "export failed"])
}

print(outputVideo.path)
