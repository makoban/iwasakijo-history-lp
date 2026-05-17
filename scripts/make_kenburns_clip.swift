import AVFoundation
import AppKit
import CoreVideo
import Foundation

if CommandLine.arguments.count < 4 {
    fputs("usage: swift make_kenburns_clip.swift <input.png> <output.mp4> <seconds>\n", stderr)
    exit(2)
}

let inputURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])
let seconds = Double(CommandLine.arguments[3]) ?? 5.0

let size = CGSize(width: 1280, height: 720)
let fps: Int32 = 30

guard let source = NSImage(contentsOf: inputURL) else {
    fputs("cannot load image: \(inputURL.path)\n", stderr)
    exit(1)
}

if FileManager.default.fileExists(atPath: outputURL.path) {
    try FileManager.default.removeItem(at: outputURL)
}
try? FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)

let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
let input = AVAssetWriterInput(
    mediaType: .video,
    outputSettings: [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: Int(size.width),
        AVVideoHeightKey: Int(size.height),
        AVVideoCompressionPropertiesKey: [
            AVVideoAverageBitRateKey: 6_500_000,
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
    fputs("cannot create pixel buffer pool\n", stderr)
    exit(1)
}

func makeBuffer(progress: CGFloat) throws -> CVPixelBuffer {
    var pixelBuffer: CVPixelBuffer?
    let status = CVPixelBufferPoolCreatePixelBuffer(nil, pool, &pixelBuffer)
    guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
        throw NSError(domain: "kenburns", code: 1)
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
        throw NSError(domain: "kenburns", code: 2)
    }

    context.setFillColor(NSColor.black.cgColor)
    context.fill(CGRect(origin: .zero, size: size))

    let imageSize = source.size
    let baseScale = max(size.width / imageSize.width, size.height / imageSize.height)
    let zoom = 1.08 + progress * 0.08
    let scale = baseScale * zoom
    let drawSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    let panX = -34 + progress * 70
    let panY = -10 + progress * 20
    let rect = CGRect(
        x: (size.width - drawSize.width) / 2 + panX,
        y: (size.height - drawSize.height) / 2 + panY,
        width: drawSize.width,
        height: drawSize.height
    )

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
    source.draw(in: rect)
    NSGraphicsContext.restoreGraphicsState()

    return buffer
}

let frames = Int(round(seconds * Double(fps)))
for frame in 0..<frames {
    while !input.isReadyForMoreMediaData {
        Thread.sleep(forTimeInterval: 0.004)
    }
    let t = frames > 1 ? CGFloat(frame) / CGFloat(frames - 1) : 0
    let smooth = t * t * (3 - 2 * t)
    let buffer = try makeBuffer(progress: smooth)
    adaptor.append(buffer, withPresentationTime: CMTime(value: CMTimeValue(frame), timescale: fps))
}

input.markAsFinished()
let semaphore = DispatchSemaphore(value: 0)
writer.finishWriting {
    semaphore.signal()
}
semaphore.wait()

if writer.status != .completed {
    fputs("export failed: \(writer.error?.localizedDescription ?? "unknown")\n", stderr)
    exit(1)
}

print(outputURL.path)
