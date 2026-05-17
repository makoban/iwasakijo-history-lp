import AVFoundation
import AppKit
import CoreVideo
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outBase = root.appendingPathComponent("assets/seedance/tsuchi-no-shiro-v3")
let cardsDir = outBase.appendingPathComponent("text-cards")
let workDir = outBase.appendingPathComponent("work")
let editedDir = outBase.appendingPathComponent("edited")
let rawOutput = workDir.appendingPathComponent("tsuchi-no-shiro-cinematic-cm-v3-raw.mp4")
let compressedOutput = workDir.appendingPathComponent("tsuchi-no-shiro-cinematic-cm-v3-web.m4v")
let output = editedDir.appendingPathComponent("tsuchi-no-shiro-cinematic-cm-v3.mp4")

try? FileManager.default.createDirectory(at: cardsDir, withIntermediateDirectories: true)
try? FileManager.default.createDirectory(at: workDir, withIntermediateDirectories: true)
try? FileManager.default.createDirectory(at: editedDir, withIntermediateDirectories: true)

let size = CGSize(width: 1280, height: 720)
let fps: Int32 = 30
let fadeSeconds = 0.65

struct TextCard {
    let id: String
    let text: String
    let seconds: Double
    let emphasis: Bool
}

struct MovieClip {
    let url: URL
    let seconds: Double
}

enum Segment {
    case card(TextCard)
    case movie(MovieClip)
}

let v2Base = root.appendingPathComponent("assets/seedance/tsuchi-no-shiro-v2")
let v3Base = root.appendingPathComponent("assets/seedance/tsuchi-no-shiro-v3")

let segments: [Segment] = [
    .card(.init(id: "01-shitteiru", text: "知っているだろうか。", seconds: 5.0, emphasis: true)),
    .movie(.init(url: root.appendingPathComponent("assets/seedance/videos/scene-04-earth-castle-final-seedance2.mp4"), seconds: 5.0)),

    .card(.init(id: "02-1584", text: "天正12年、1584年。", seconds: 5.0, emphasis: true)),
    .movie(.init(url: root.appendingPathComponent("assets/seedance/videos/scene-03-battle-dawn-seedance2.mp4"), seconds: 5.0)),

    .card(.init(id: "03-hashiba", text: "羽柴方の軍勢は、\n徳川家康の本拠・岡崎を狙った。", seconds: 5.5, emphasis: false)),
    .movie(.init(url: root.appendingPathComponent("assets/seedance/videos/scene-02-roadside-market-seedance2.mp4"), seconds: 5.0)),

    .card(.init(id: "04-route", text: "その道中に、\n丹羽氏の小さな城があった。", seconds: 5.5, emphasis: false)),
    .movie(.init(url: v2Base.appendingPathComponent("videos/story/story-01-building-earthworks.mp4"), seconds: 5.0)),

    .card(.init(id: "05-iwasaki", text: "岩崎城。\n天守ではなく、土の城だった。", seconds: 5.5, emphasis: true)),
    .movie(.init(url: root.appendingPathComponent("assets/seedance/videos/scene-01-building-earthworks-seedance2.mp4"), seconds: 5.0)),

    .card(.init(id: "06-earthworks", text: "土塁、空堀、土橋。\n大軍の道を、狭くする。", seconds: 5.5, emphasis: false)),
    .movie(.init(url: v2Base.appendingPathComponent("videos/battle/battle-01-earth-bridge-bottleneck.mp4"), seconds: 5.0)),

    .card(.init(id: "07-falls", text: "城は落ちた。\nだが、軍勢は時間を失った。", seconds: 5.5, emphasis: false)),
    .movie(.init(url: v2Base.appendingPathComponent("videos/battle/battle-02-palisade-clash.mp4"), seconds: 5.0)),

    .card(.init(id: "08-caught", text: "その遅れで、\n徳川方が長久手で追いついた。", seconds: 5.5, emphasis: false)),
    .movie(.init(url: v3Base.appendingPathComponent("generated/seedance2-tokugawa-full-speed-nagakute.mp4"), seconds: 5.0)),

    .card(.init(id: "09-nagakute", text: "池田恒興、森長可らが戦死。\n岡崎奇襲は失敗した。", seconds: 6.0, emphasis: false)),
    .movie(.init(url: v3Base.appendingPathComponent("generated/seedance2-tokugawa-victory-okazaki-protected.mp4"), seconds: 5.0)),

    .movie(.init(url: v3Base.appendingPathComponent("generated/seedance2-iwasaki-earth-castle-aerial-text-final.mp4"), seconds: 10.0)),
]

func minchoFont(size: CGFloat, bold: Bool) -> NSFont {
    let names = bold
        ? ["Hiragino Mincho ProN W6", "Hiragino Mincho Pro W6", "YuMincho-Demibold"]
        : ["Hiragino Mincho ProN W3", "Hiragino Mincho Pro W3", "YuMincho-Regular"]

    for name in names {
        if let font = NSFont(name: name, size: size) {
            return font
        }
    }
    return NSFont.systemFont(ofSize: size, weight: bold ? .semibold : .regular)
}

func attributedText(_ text: String, size fontSize: CGFloat, emphasis: Bool) -> NSAttributedString {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    paragraph.lineSpacing = emphasis ? 24 : 18

    return NSAttributedString(
        string: text,
        attributes: [
            .font: minchoFont(size: fontSize, bold: emphasis),
            .foregroundColor: NSColor(calibratedWhite: 0.96, alpha: 1.0),
            .paragraphStyle: paragraph,
            .kern: 0.0,
        ]
    )
}

func fittedText(_ text: String, emphasis: Bool, maxSize: CGSize) -> NSAttributedString {
    let start: CGFloat = emphasis ? 74 : 56
    let minimum: CGFloat = 34
    var sizeValue = start

    while sizeValue >= minimum {
        let candidate = attributedText(text, size: sizeValue, emphasis: emphasis)
        let rect = candidate.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading])
        if rect.width <= maxSize.width && rect.height <= maxSize.height {
            return candidate
        }
        sizeValue -= 2
    }

    return attributedText(text, size: minimum, emphasis: emphasis)
}

func makeCardImage(_ card: TextCard) throws -> URL {
    let imageURL = cardsDir.appendingPathComponent("\(card.id).png")
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(size.width),
        pixelsHigh: Int(size.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw NSError(domain: "cmv3", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot create bitmap rep"])
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    defer { NSGraphicsContext.restoreGraphicsState() }

    NSColor.black.setFill()
    NSRect(origin: .zero, size: size).fill()

    let maxTextSize = CGSize(width: size.width * 0.78, height: size.height * 0.55)
    let text = fittedText(card.text, emphasis: card.emphasis, maxSize: maxTextSize)
    let textRect = text.boundingRect(with: maxTextSize, options: [.usesLineFragmentOrigin, .usesFontLeading])
    let drawRect = CGRect(
        x: (size.width - maxTextSize.width) / 2,
        y: (size.height - textRect.height) / 2 + 8,
        width: maxTextSize.width,
        height: textRect.height + 24
    )
    text.draw(with: drawRect, options: [.usesLineFragmentOrigin, .usesFontLeading])

    let markParagraph = NSMutableParagraphStyle()
    markParagraph.alignment = .center
    let mark = NSAttributedString(
        string: "土の城",
        attributes: [
            .font: minchoFont(size: 18, bold: false),
            .foregroundColor: NSColor(calibratedWhite: 0.56, alpha: 1.0),
            .paragraphStyle: markParagraph,
            .kern: 4.0,
        ]
    )
    mark.draw(in: CGRect(x: 0, y: 74, width: size.width, height: 28))

    guard let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "cmv3", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot encode card image"])
    }

    try png.write(to: imageURL)
    return imageURL
}

func pixelBuffer(from imageURL: URL, pool: CVPixelBufferPool) throws -> CVPixelBuffer {
    guard let nsImage = NSImage(contentsOf: imageURL) else {
        throw NSError(domain: "cmv3", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot load image: \(imageURL.path)"])
    }

    var pixelBuffer: CVPixelBuffer?
    let status = CVPixelBufferPoolCreatePixelBuffer(nil, pool, &pixelBuffer)
    guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
        throw NSError(domain: "cmv3", code: 4, userInfo: [NSLocalizedDescriptionKey: "Cannot create pixel buffer"])
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
        throw NSError(domain: "cmv3", code: 5, userInfo: [NSLocalizedDescriptionKey: "Cannot create context"])
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

func makeStillMovie(imageURL: URL, seconds: Double, out: URL) throws {
    if FileManager.default.fileExists(atPath: out.path) {
        try FileManager.default.removeItem(at: out)
    }

    let writer = try AVAssetWriter(outputURL: out, fileType: .mp4)
    let input = AVAssetWriterInput(
        mediaType: .video,
        outputSettings: [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: Int(size.width),
            AVVideoHeightKey: Int(size.height),
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 6_000_000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
            ],
        ]
    )
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
        throw NSError(domain: "cmv3", code: 6, userInfo: [NSLocalizedDescriptionKey: "Cannot get buffer pool"])
    }
    let buffer = try pixelBuffer(from: imageURL, pool: pool)
    let totalFrames = Int(round(seconds * Double(fps)))

    var frame = 0
    while frame < totalFrames {
        if input.isReadyForMoreMediaData {
            let time = CMTime(value: CMTimeValue(frame), timescale: fps)
            adaptor.append(buffer, withPresentationTime: time)
            frame += 1
        } else {
            Thread.sleep(forTimeInterval: 0.004)
        }
    }

    input.markAsFinished()
    let semaphore = DispatchSemaphore(value: 0)
    writer.finishWriting {
        semaphore.signal()
    }
    semaphore.wait()

    if writer.status != .completed {
        throw writer.error ?? NSError(domain: "cmv3", code: 7, userInfo: [NSLocalizedDescriptionKey: "Still movie writer failed"])
    }
}

var preparedSegments: [(url: URL, seconds: Double?)] = []

for segment in segments {
    switch segment {
    case .card(let card):
        let image = try makeCardImage(card)
        let movie = workDir.appendingPathComponent("\(card.id).mp4")
        try makeStillMovie(imageURL: image, seconds: card.seconds, out: movie)
        preparedSegments.append((movie, nil))

    case .movie(let clip):
        guard FileManager.default.fileExists(atPath: clip.url.path) else {
            throw NSError(domain: "cmv3", code: 8, userInfo: [NSLocalizedDescriptionKey: "Missing movie: \(clip.url.path)"])
        }
        preparedSegments.append((clip.url, clip.seconds))
    }
}

if FileManager.default.fileExists(atPath: rawOutput.path) {
    try FileManager.default.removeItem(at: rawOutput)
}

let composition = AVMutableComposition()
guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    throw NSError(domain: "cmv3", code: 9, userInfo: [NSLocalizedDescriptionKey: "Cannot create video track"])
}

let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
var cursor = CMTime.zero

for prepared in preparedSegments {
    let asset = AVURLAsset(url: prepared.url)
    guard let assetVideo = try await asset.loadTracks(withMediaType: .video).first else {
        throw NSError(domain: "cmv3", code: 10, userInfo: [NSLocalizedDescriptionKey: "No video track: \(prepared.url.path)"])
    }

    let assetDuration = try await asset.load(.duration)
    let useDuration: CMTime
    if let seconds = prepared.seconds {
        useDuration = CMTimeMinimum(assetDuration, CMTime(seconds: seconds, preferredTimescale: 600))
    } else {
        useDuration = assetDuration
    }

    try videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: useDuration), of: assetVideo, at: cursor)

    let transform = try await assetVideo.load(.preferredTransform)
    layerInstruction.setTransform(transform, at: cursor)

    let fade = CMTime(seconds: min(fadeSeconds, max(0.12, useDuration.seconds / 4)), preferredTimescale: 600)
    layerInstruction.setOpacityRamp(fromStartOpacity: 0, toEndOpacity: 1, timeRange: CMTimeRange(start: cursor, duration: fade))
    layerInstruction.setOpacityRamp(
        fromStartOpacity: 1,
        toEndOpacity: 0,
        timeRange: CMTimeRange(start: CMTimeSubtract(CMTimeAdd(cursor, useDuration), fade), duration: fade)
    )

    cursor = CMTimeAdd(cursor, useDuration)
}

let instruction = AVMutableVideoCompositionInstruction()
instruction.timeRange = CMTimeRange(start: .zero, duration: cursor)
instruction.layerInstructions = [layerInstruction]

let videoComposition = AVMutableVideoComposition()
videoComposition.instructions = [instruction]
videoComposition.renderSize = size
videoComposition.frameDuration = CMTime(value: 1, timescale: fps)
videoComposition.renderScale = 1.0

guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPreset1280x720) else {
    throw NSError(domain: "cmv3", code: 11, userInfo: [NSLocalizedDescriptionKey: "Cannot create exporter"])
}
exporter.outputURL = rawOutput
exporter.outputFileType = .mp4
exporter.videoComposition = videoComposition
exporter.shouldOptimizeForNetworkUse = true

await exporter.export()
if exporter.status != .completed {
    throw exporter.error ?? NSError(domain: "cmv3", code: 12, userInfo: [NSLocalizedDescriptionKey: "Export failed"])
}

if FileManager.default.fileExists(atPath: output.path) {
    try FileManager.default.removeItem(at: output)
}
if FileManager.default.fileExists(atPath: compressedOutput.path) {
    try FileManager.default.removeItem(at: compressedOutput)
}

let converter = Process()
converter.executableURL = URL(fileURLWithPath: "/usr/bin/avconvert")
converter.arguments = [
    "--source", rawOutput.path,
    "--preset", "PresetAppleM4V720pHD",
    "--output", compressedOutput.path,
    "--replace",
]
try converter.run()
converter.waitUntilExit()

if converter.terminationStatus == 0, FileManager.default.fileExists(atPath: compressedOutput.path) {
    try FileManager.default.moveItem(at: compressedOutput, to: output)
} else {
    try FileManager.default.copyItem(at: rawOutput, to: output)
}

print("wrote \(output.path)")
print("duration \(String(format: "%.1f", cursor.seconds)) seconds")
