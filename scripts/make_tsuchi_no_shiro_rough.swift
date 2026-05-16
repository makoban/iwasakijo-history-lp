import AVFoundation
import AppKit
import CoreVideo
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let base = root.appendingPathComponent("assets/seedance/tsuchi-no-shiro-v2")
let work = base.appendingPathComponent("edited/work")
let output = base.appendingPathComponent("edited/tsuchi-no-shiro-story-cut.mp4")

try? FileManager.default.createDirectory(at: work, withIntermediateDirectories: true)
try? FileManager.default.createDirectory(at: output.deletingLastPathComponent(), withIntermediateDirectories: true)

let size = CGSize(width: 1280, height: 720)
let fps: Int32 = 30
let fadeSeconds = 0.22

struct StillClip {
    let image: URL
    let seconds: Double
    let out: URL
}

enum Segment {
    case still(StillClip)
    case movie(URL)
}

let stills: [StillClip] = [
    .init(image: base.appendingPathComponent("text-cards/text-01-title.png"), seconds: 2.2, out: work.appendingPathComponent("01-title.mp4")),
    .init(image: base.appendingPathComponent("text-cards/text-02-no-tenshu.png"), seconds: 2.2, out: work.appendingPathComponent("02-no-tenshu.mp4")),
    .init(image: base.appendingPathComponent("text-cards/text-03-earthworks.png"), seconds: 2.2, out: work.appendingPathComponent("03-earthworks.mp4")),
    .init(image: base.appendingPathComponent("text-cards/text-04-delay.png"), seconds: 2.2, out: work.appendingPathComponent("06-delay.mp4")),
    .init(image: base.appendingPathComponent("text-cards/text-05-nagakute.png"), seconds: 3.0, out: work.appendingPathComponent("08-nagakute.mp4")),
]

let segments: [Segment] = [
    .still(stills[0]),
    .still(stills[1]),
    .movie(base.appendingPathComponent("videos/story/story-01-building-earthworks.mp4")),
    .still(stills[2]),
    .movie(base.appendingPathComponent("videos/story/story-02-roadside-life.mp4")),
    .movie(base.appendingPathComponent("videos/tsuchi-no-shiro-v2-seedance2.mp4")),
    .movie(base.appendingPathComponent("videos/battle/battle-01-earth-bridge-bottleneck.mp4")),
    .still(stills[3]),
    .movie(base.appendingPathComponent("videos/battle/battle-02-palisade-clash.mp4")),
    .still(stills[4]),
]

func pixelBuffer(from imageURL: URL, size: CGSize, pool: CVPixelBufferPool) throws -> CVPixelBuffer {
    guard let nsImage = NSImage(contentsOf: imageURL) else {
        throw NSError(domain: "roughcut", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot load image: \(imageURL.path)"])
    }
    guard let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: 1) as UnsafeMutablePointer<CVPixelBuffer?>? else {
        throw NSError(domain: "roughcut", code: 2)
    }
    defer { pixelBufferPointer.deallocate() }

    let status = CVPixelBufferPoolCreatePixelBuffer(nil, pool, pixelBufferPointer)
    guard status == kCVReturnSuccess, let buffer = pixelBufferPointer.pointee else {
        throw NSError(domain: "roughcut", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot create pixel buffer"])
    }

    CVPixelBufferLockBaseAddress(buffer, [])
    defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

    guard let context = CGContext(
        data: CVPixelBufferGetBaseAddress(buffer),
        width: Int(size.width),
        height: Int(size.height),
        bitsPerComponent: 8,
        bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    ) else {
        throw NSError(domain: "roughcut", code: 4)
    }

    context.setFillColor(NSColor.black.cgColor)
    context.fill(CGRect(origin: .zero, size: size))

    let imageSize = nsImage.size
    let scale = max(size.width / imageSize.width, size.height / imageSize.height)
    let drawSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    let rect = CGRect(
        x: (size.width - drawSize.width) / 2,
        y: (size.height - drawSize.height) / 2,
        width: drawSize.width,
        height: drawSize.height
    )

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
    nsImage.draw(in: rect)
    NSGraphicsContext.restoreGraphicsState()

    return buffer
}

func makeStillMovie(_ clip: StillClip) throws {
    if FileManager.default.fileExists(atPath: clip.out.path) {
        try FileManager.default.removeItem(at: clip.out)
    }

    let writer = try AVAssetWriter(outputURL: clip.out, fileType: .mp4)
    let settings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: Int(size.width),
        AVVideoHeightKey: Int(size.height),
        AVVideoCompressionPropertiesKey: [
            AVVideoAverageBitRateKey: 5_000_000,
            AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
        ],
    ]
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
    input.expectsMediaDataInRealTime = false
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(
        assetWriterInput: input,
        sourcePixelBufferAttributes: [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: Int(size.width),
            kCVPixelBufferHeightKey as String: Int(size.height),
        ]
    )
    writer.add(input)
    writer.startWriting()
    writer.startSession(atSourceTime: .zero)

    guard let pool = adaptor.pixelBufferPool else {
        throw NSError(domain: "roughcut", code: 5)
    }
    let buffer = try pixelBuffer(from: clip.image, size: size, pool: pool)
    let totalFrames = Int(round(clip.seconds * Double(fps)))

    var frame = 0
    while frame < totalFrames {
        if input.isReadyForMoreMediaData {
            let time = CMTime(value: CMTimeValue(frame), timescale: fps)
            adaptor.append(buffer, withPresentationTime: time)
            frame += 1
        } else {
            Thread.sleep(forTimeInterval: 0.005)
        }
    }
    input.markAsFinished()
    let semaphore = DispatchSemaphore(value: 0)
    writer.finishWriting {
        semaphore.signal()
    }
    semaphore.wait()
    if writer.status != .completed {
        throw writer.error ?? NSError(domain: "roughcut", code: 6, userInfo: [NSLocalizedDescriptionKey: "Still writer failed"])
    }
}

for still in stills {
    try makeStillMovie(still)
}

if FileManager.default.fileExists(atPath: output.path) {
    try FileManager.default.removeItem(at: output)
}

let composition = AVMutableComposition()
guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    throw NSError(domain: "roughcut", code: 7)
}
let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)

let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
var cursor = CMTime.zero

for segment in segments {
    let url: URL
    switch segment {
    case .still(let still): url = still.out
    case .movie(let movie): url = movie
    }

    let asset = AVURLAsset(url: url)
    guard let assetVideo = try await asset.loadTracks(withMediaType: .video).first else {
        throw NSError(domain: "roughcut", code: 8, userInfo: [NSLocalizedDescriptionKey: "No video track: \(url.path)"])
    }
    let duration = try await asset.load(.duration)
    try videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: assetVideo, at: cursor)

    if let assetAudio = try await asset.loadTracks(withMediaType: .audio).first, let audioTrack {
        try? audioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: assetAudio, at: cursor)
    }

    let transform = try await assetVideo.load(.preferredTransform)
    layerInstruction.setTransform(transform, at: cursor)

    let fade = CMTime(seconds: min(fadeSeconds, max(0.05, duration.seconds / 5)), preferredTimescale: 600)
    layerInstruction.setOpacityRamp(fromStartOpacity: 0, toEndOpacity: 1, timeRange: CMTimeRange(start: cursor, duration: fade))
    layerInstruction.setOpacityRamp(fromStartOpacity: 1, toEndOpacity: 0, timeRange: CMTimeRange(start: CMTimeSubtract(CMTimeAdd(cursor, duration), fade), duration: fade))
    cursor = CMTimeAdd(cursor, duration)
}

let instruction = AVMutableVideoCompositionInstruction()
instruction.timeRange = CMTimeRange(start: .zero, duration: cursor)
instruction.layerInstructions = [layerInstruction]

let videoComposition = AVMutableVideoComposition()
videoComposition.instructions = [instruction]
videoComposition.renderSize = size
videoComposition.frameDuration = CMTime(value: 1, timescale: fps)
videoComposition.renderScale = 1.0
videoComposition.animationTool = nil

guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset1280x720) else {
    throw NSError(domain: "roughcut", code: 9)
}
exporter.outputURL = output
exporter.outputFileType = .mp4
exporter.videoComposition = videoComposition
exporter.shouldOptimizeForNetworkUse = true

await exporter.export()
if exporter.status != .completed {
    throw exporter.error ?? NSError(domain: "roughcut", code: 10, userInfo: [NSLocalizedDescriptionKey: "Export failed"])
}

print("wrote \(output.path)")
