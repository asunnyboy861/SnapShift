import Foundation
import AVFoundation
import UIKit

class TimelapseGenerator {
    static func generate(from photos: [ProgressPhoto], fps: Int = 2) async -> URL? {
        guard !photos.isEmpty else { return nil }

        let sortedPhotos = photos.sorted { $0.date ?? Date() < $1.date ?? Date() }
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("timelapse_\(Int(Date().timeIntervalSince1970)).mp4")

        let size = CGSize(width: 1080, height: 1920)

        guard let writer = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) else { return nil }

        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: size.width,
            AVVideoHeightKey: size.height
        ]
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: input,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
                kCVPixelBufferWidthKey as String: size.width,
                kCVPixelBufferHeightKey as String: size.height
            ]
        )

        writer.add(input)
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)

        var frameCount: Int64 = 0

        for photo in sortedPhotos {
            guard let image = PhotoStorageManager.shared.loadPhoto(filename: photo.imagePath),
                  let resized = resizeImage(image, to: size),
                  let buffer = createPixelBuffer(from: resized) else { continue }

            while !adaptor.assetWriterInput.isReadyForMoreMediaData {
                try? await Task.sleep(nanoseconds: 10_000_000)
            }

            let presentationTime = CMTime(value: frameCount, timescale: Int32(fps))
            adaptor.append(buffer, withPresentationTime: presentationTime)
            frameCount += 1
        }

        input.markAsFinished()

        return await withCheckedContinuation { continuation in
            writer.finishWriting {
                continuation.resume(returning: writer.status == .completed ? outputURL : nil)
            }
        }
    }

    private static func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    private static func createPixelBuffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(image.size.width),
            Int(image.size.height),
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()

        guard let context = CGContext(
            data: pixelData,
            width: Int(image.size.width),
            height: Int(image.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
            return nil
        }

        context.translateBy(x: 0, y: image.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        UIGraphicsPushContext(context)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))

        return buffer
    }
}
