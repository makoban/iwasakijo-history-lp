import AVFoundation
import AppKit
import CoreVideo
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let inputURL = root.appendingPathComponent("assets/seedance/tsuchi-no-shiro-v3/generated/seedance2-iwasaki-earth-castle-aerial.mp4")
let outputURL = root.appendingPathComponent("assets/seedance/tsuchi-no-shiro-v3/generated/seedance2-iwasaki-earth-castle-aerial-text-final.mp4")
let size = CGSize(width: 1280, height: 720)
let fps: Int32 = 30
let seconds = 10.0

if FileManager.default.fileExists(atPath: outputURL.path) {
    try FileManager.default.removeItem(at: outputURL)
}

let asset = AVURLAsset(url: inputURL)
let sourceDuration = try await asset.load(.duration)
let generator = AVAssetImageGenerator(asset: asset)
generator.appliesPreferredTrackTransform = true
generator.maximumSize = size
generator.requestedTimeToleranceBefore = .zero
generator.requestedTimeToleranceAfter = .zero

func minchoFont(size: CGFloat, weight: NSFont.Weight) -> NSFont {
    let candidates = weight.rawValue >= NSFont.Weight.semibold.rawValue
        ? ["Hiragino Mincho ProN W6", "Hiragino Mincho Pro W6", "YuMincho-Demibold"]
        : ["Hiragino Mincho ProN W3", "Hiragino Mincho Pro W3", "YuMincho-Regular"]
    for name in candidates {
        if let font = NSFont(name: name, size: size) {
            return font
        }
    }
    return NSFont.systemFont(ofSize: size, weight: weight)
}

func drawLeftGradient(context: CGContext) {
    let colors = [
        NSColor(calibratedWhite: 0.0, alpha: 0.72).cgColor,
        NSColor(calibratedWhite: 0.0, alpha: 0.34).cgColor,
        NSColor(calibratedWhite: 0.0, alpha: 0.0).cgColor,
    ] as CFArray
    guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.0, 0.52, 1.0]) else {
        return
    }
    context.drawLinearGradient(
        gradient,
        start: CGPoint(x: 0, y: 0),
        end: CGPoint(x: size.width * 0.78, y: 0),
        options: []
    )
}

func drawVignette(context: CGContext) {
    let colors = [
        NSColor(calibratedWhite: 0.0, alpha: 0.0).cgColor,
        NSColor(calibratedWhite: 0.0, alpha: 0.38).cgColor,
    ] as CFArray
    guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.44, 1.0]) else {
        return
    }
    context.drawRadialGradient(
        gradient,
        startCenter: CGPoint(x: size.width * 0.52, y: size.height * 0.56),
        startRadius: 60,
        endCenter: CGPoint(x: size.width * 0.52, y: size.height * 0.5),
        endRadius: 760,
        options: [.drawsAfterEndLocation]
    )
}

func drawText(progress: CGFloat) {
    drawLeftGradient(context: NSGraphicsContext.current!.cgContext)

    let fadeIn = min(1, max(0, progress / 0.14))
    let fadeOut = progress > 0.76 ? max(0, 1 - (progress - 0.76) / 0.18) : 1
    let alpha = fadeIn * fadeOut
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .left
    paragraph.lineSpacing = 22

    let shadow = NSShadow()
    shadow.shadowBlurRadius = 10
    shadow.shadowOffset = CGSize(width: 0, height: -2)
    shadow.shadowColor = NSColor(calibratedWhite: 0.0, alpha: 0.9)

    let text = NSAttributedString(
        string: "岩崎城は、\n落ちても、時間を奪った\n土の城",
        attributes: [
            .font: minchoFont(size: 54, weight: .semibold),
            .foregroundColor: NSColor(calibratedWhite: 0.97, alpha: alpha),
            .paragraphStyle: paragraph,
            .kern: 0.0,
            .shadow: shadow,
        ]
    )
    text.draw(
        with: CGRect(x: 74, y: 252, width: 610, height: 240),
        options: [.usesLineFragmentOrigin, .usesFontLeading]
    )
}

func drawBlackFade(context: CGContext, progress: CGFloat) {
    guard progress > 0.74 else { return }
    let alpha = min(1, (progress - 0.74) / 0.26)
    context.setFillColor(NSColor(calibratedWhite: 0.0, alpha: alpha).cgColor)
    context.fill(CGRect(origin: .zero, size: size))
}

func drawCover(_ image: NSImage, progress: CGFloat) {
    let baseScale = max(size.width / image.size.width, size.height / image.size.height)
    let zoom = 1.02 + (1.08 - 1.02) * progress
    let scale = baseScale * zoom
    let drawSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
    let panX = -20 + progress * 36
    let panY = -8 + progress * 16
    let rect = CGRect(
        x: (size.width - drawSize.width) / 2 + panX,
        y: (size.height - drawSize.height) / 2 + panY,
        width: drawSize.width,
        height: drawSize.height
    )
    image.draw(in: rect)
}

let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
let input = AVAssetWriterInput(
    mediaType: .video,
    outputSettings: [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: Int(size.width),
        AVVideoHeightKey: Int(size.height),
        AVVideoCompressionPropertiesKey: [
            AVVideoAverageBitRateKey: 7_000_000,
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
    throw NSError(domain: "final-overlay", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot get pixel buffer pool"])
}

let totalFrames = Int(round(seconds * Double(fps)))
for frame in 0..<totalFrames {
    while !input.isReadyForMoreMediaData {
        Thread.sleep(forTimeInterval: 0.004)
    }

    let progress = totalFrames > 1 ? CGFloat(frame) / CGFloat(totalFrames - 1) : 0
    let sourceSeconds = min(sourceDuration.seconds - 0.04, Double(progress) * sourceDuration.seconds)
    let sourceTime = CMTime(seconds: max(0, sourceSeconds), preferredTimescale: 600)
    let cgImage = try generator.copyCGImage(at: sourceTime, actualTime: nil)
    let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))

    var pixelBuffer: CVPixelBuffer?
    let status = CVPixelBufferPoolCreatePixelBuffer(nil, pool, &pixelBuffer)
    guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
        throw NSError(domain: "final-overlay", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot create pixel buffer"])
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
        throw NSError(domain: "final-overlay", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot create context"])
    }

    context.setFillColor(NSColor.black.cgColor)
    context.fill(CGRect(origin: .zero, size: size))

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
    drawCover(nsImage, progress: progress)
    drawVignette(context: context)
    drawText(progress: progress)
    drawBlackFade(context: context, progress: progress)
    NSGraphicsContext.restoreGraphicsState()

    adaptor.append(buffer, withPresentationTime: CMTime(value: CMTimeValue(frame), timescale: fps))
}

input.markAsFinished()
let semaphore = DispatchSemaphore(value: 0)
writer.finishWriting {
    semaphore.signal()
}
semaphore.wait()

if writer.status != .completed {
    throw writer.error ?? NSError(domain: "final-overlay", code: 4, userInfo: [NSLocalizedDescriptionKey: "Writer failed"])
}

print(outputURL.path)
