import AVFoundation
import AppKit
import CoreVideo
import Foundation

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let outDir = root.appendingPathComponent("assets/seedance/tsuchi-no-shiro-v3/generated")
let size = CGSize(width: 1280, height: 720)
let fps: Int32 = 30

try? FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

struct ClipSpec {
    let input: URL
    let output: URL
    let seconds: Double
    let startZoom: CGFloat
    let endZoom: CGFloat
    let startPan: CGPoint
    let endPan: CGPoint
    let shake: CGFloat
    let dust: CGFloat
    let vignette: CGFloat
    let finalText: String?
    let fadeToBlackStart: CGFloat
}

let clips: [ClipSpec] = [
    .init(
        input: outDir.appendingPathComponent("tokugawa-full-speed-nagakute.png"),
        output: outDir.appendingPathComponent("tokugawa-full-speed-nagakute-motion.mp4"),
        seconds: 5.0,
        startZoom: 1.03,
        endZoom: 1.20,
        startPan: CGPoint(x: -34, y: -2),
        endPan: CGPoint(x: 46, y: 16),
        shake: 5.0,
        dust: 0.42,
        vignette: 0.28,
        finalText: nil,
        fadeToBlackStart: 1.1
    ),
    .init(
        input: outDir.appendingPathComponent("tokugawa-victory-okazaki-protected.png"),
        output: outDir.appendingPathComponent("tokugawa-victory-okazaki-protected-motion.mp4"),
        seconds: 5.0,
        startZoom: 1.08,
        endZoom: 1.16,
        startPan: CGPoint(x: 10, y: -4),
        endPan: CGPoint(x: -20, y: 10),
        shake: 2.8,
        dust: 0.28,
        vignette: 0.24,
        finalText: nil,
        fadeToBlackStart: 1.1
    ),
    .init(
        input: root.appendingPathComponent("assets/generated/hero-earthwork-castle.png"),
        output: outDir.appendingPathComponent("iwasaki-earth-castle-aerial-final.mp4"),
        seconds: 8.0,
        startZoom: 1.23,
        endZoom: 1.03,
        startPan: CGPoint(x: -128, y: -42),
        endPan: CGPoint(x: 72, y: 20),
        shake: 0.0,
        dust: 0.04,
        vignette: 0.42,
        finalText: "岩崎城は、\n落ちても、時間を奪った\n土の城",
        fadeToBlackStart: 0.72
    ),
]

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

func smooth(_ t: CGFloat) -> CGFloat {
    t * t * (3 - 2 * t)
}

func coverRect(imageSize: CGSize, zoom: CGFloat, pan: CGPoint) -> CGRect {
    let baseScale = max(size.width / imageSize.width, size.height / imageSize.height)
    let scale = baseScale * zoom
    let drawSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
    return CGRect(
        x: (size.width - drawSize.width) / 2 + pan.x,
        y: (size.height - drawSize.height) / 2 + pan.y,
        width: drawSize.width,
        height: drawSize.height
    )
}

func drawVignette(context: CGContext, strength: CGFloat) {
    guard strength > 0 else { return }
    let colors = [
        NSColor(calibratedWhite: 0.0, alpha: 0.0).cgColor,
        NSColor(calibratedWhite: 0.0, alpha: strength).cgColor,
    ] as CFArray
    guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.45, 1.0]) else {
        return
    }
    context.drawRadialGradient(
        gradient,
        startCenter: CGPoint(x: size.width * 0.5, y: size.height * 0.55),
        startRadius: 40,
        endCenter: CGPoint(x: size.width * 0.5, y: size.height * 0.5),
        endRadius: 760,
        options: [.drawsAfterEndLocation]
    )
}

func drawDust(context: CGContext, progress: CGFloat, intensity: CGFloat) {
    guard intensity > 0 else { return }
    for i in 0..<38 {
        let seed = CGFloat((i * 73) % 101) / 100.0
        let drift = (progress * (0.45 + seed * 0.8)).truncatingRemainder(dividingBy: 1.0)
        let x = CGFloat((i * 179) % Int(size.width)) + sin(progress * 5 + CGFloat(i)) * 22
        let y = 64 + seed * 340 + drift * 180
        let w = 80 + seed * 180
        let h = 22 + seed * 52
        let alpha = max(0, (1 - drift) * intensity * 0.18)
        context.setFillColor(NSColor(calibratedRed: 0.78, green: 0.64, blue: 0.46, alpha: alpha).cgColor)
        context.fillEllipse(in: CGRect(x: x - w / 2, y: y - h / 2, width: w, height: h))
    }
}

func drawLeftGradient(context: CGContext) {
    let colors = [
        NSColor(calibratedWhite: 0.0, alpha: 0.72).cgColor,
        NSColor(calibratedWhite: 0.0, alpha: 0.36).cgColor,
        NSColor(calibratedWhite: 0.0, alpha: 0.0).cgColor,
    ] as CFArray
    guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.0, 0.48, 1.0]) else {
        return
    }
    context.drawLinearGradient(
        gradient,
        start: CGPoint(x: 0, y: 0),
        end: CGPoint(x: size.width * 0.78, y: 0),
        options: []
    )
}

func drawFinalText(_ text: String, context: CGContext, progress: CGFloat) {
    drawLeftGradient(context: context)

    let fadeIn = min(1, max(0, progress / 0.12))
    let fadeOut = progress > 0.72 ? max(0, 1 - (progress - 0.72) / 0.24) : 1
    let alpha = fadeIn * fadeOut
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .left
    paragraph.lineSpacing = 22

    let shadow = NSShadow()
    shadow.shadowBlurRadius = 9
    shadow.shadowOffset = CGSize(width: 0, height: -2)
    shadow.shadowColor = NSColor(calibratedWhite: 0.0, alpha: 0.88)

    let attrs: [NSAttributedString.Key: Any] = [
        .font: minchoFont(size: 54, weight: .semibold),
        .foregroundColor: NSColor(calibratedWhite: 0.97, alpha: alpha),
        .paragraphStyle: paragraph,
        .kern: 0.0,
        .shadow: shadow,
    ]
    let label = NSAttributedString(string: text, attributes: attrs)
    label.draw(
        with: CGRect(x: 74, y: 252, width: 610, height: 240),
        options: [.usesLineFragmentOrigin, .usesFontLeading]
    )
}

func drawBlackFade(context: CGContext, progress: CGFloat, start: CGFloat) {
    guard start < 1, progress > start else { return }
    let alpha = min(1, (progress - start) / max(0.01, 1 - start))
    context.setFillColor(NSColor(calibratedWhite: 0.0, alpha: alpha).cgColor)
    context.fill(CGRect(origin: .zero, size: size))
}

func writeClip(_ spec: ClipSpec) throws {
    guard let image = NSImage(contentsOf: spec.input) else {
        throw NSError(domain: "motion", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot load \(spec.input.path)"])
    }

    if FileManager.default.fileExists(atPath: spec.output.path) {
        try FileManager.default.removeItem(at: spec.output)
    }

    let writer = try AVAssetWriter(outputURL: spec.output, fileType: .mp4)
    let input = AVAssetWriterInput(
        mediaType: .video,
        outputSettings: [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: Int(size.width),
            AVVideoHeightKey: Int(size.height),
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 7_500_000,
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
        throw NSError(domain: "motion", code: 2, userInfo: [NSLocalizedDescriptionKey: "Cannot make pixel buffer pool"])
    }

    let totalFrames = Int(round(spec.seconds * Double(fps)))
    for frame in 0..<totalFrames {
        while !input.isReadyForMoreMediaData {
            Thread.sleep(forTimeInterval: 0.004)
        }

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferPoolCreatePixelBuffer(nil, pool, &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            throw NSError(domain: "motion", code: 3, userInfo: [NSLocalizedDescriptionKey: "Cannot create pixel buffer"])
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
            throw NSError(domain: "motion", code: 4, userInfo: [NSLocalizedDescriptionKey: "Cannot create CGContext"])
        }

        let rawT = totalFrames > 1 ? CGFloat(frame) / CGFloat(totalFrames - 1) : 0
        let t = smooth(rawT)
        let zoom = spec.startZoom + (spec.endZoom - spec.startZoom) * t
        var pan = CGPoint(
            x: spec.startPan.x + (spec.endPan.x - spec.startPan.x) * t,
            y: spec.startPan.y + (spec.endPan.y - spec.startPan.y) * t
        )
        if spec.shake > 0 {
            pan.x += sin(rawT * 90) * spec.shake + sin(rawT * 37) * spec.shake * 0.45
            pan.y += cos(rawT * 82) * spec.shake * 0.7
        }

        context.setFillColor(NSColor.black.cgColor)
        context.fill(CGRect(origin: .zero, size: size))

        let rect = coverRect(imageSize: image.size, zoom: zoom, pan: pan)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
        image.draw(in: rect)
        drawDust(context: context, progress: rawT, intensity: spec.dust)
        drawVignette(context: context, strength: spec.vignette)
        if let finalText = spec.finalText {
            drawFinalText(finalText, context: context, progress: rawT)
        }
        drawBlackFade(context: context, progress: rawT, start: spec.fadeToBlackStart)
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
        throw writer.error ?? NSError(domain: "motion", code: 5, userInfo: [NSLocalizedDescriptionKey: "Writer failed"])
    }

    print(spec.output.path)
}

for clip in clips {
    try writeClip(clip)
}
