import SwiftUI
import AVFoundation

struct GhostOverlayCameraView: View {
    let album: ProgressAlbum
    @StateObject private var viewModel = CameraViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            CameraPreview(session: viewModel.cameraManager.session)
                .ignoresSafeArea()

            if let ghost = viewModel.ghostImage {
                Image(uiImage: ghost)
                    .resizable()
                    .scaledToFill()
                    .opacity(viewModel.ghostOpacity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            if viewModel.showGrid {
                GridOverlay()
                    .allowsHitTesting(false)
            }

            VStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Button {
                        withAnimation { viewModel.showGrid.toggle() }
                    } label: {
                        Image(systemName: viewModel.showGrid ? "grid" : "grid")
                            .font(.title2)
                            .foregroundColor(.white)
                    }

                    if viewModel.ghostImage != nil {
                        Button {
                            viewModel.ghostOpacity = max(0.1, viewModel.ghostOpacity - 0.1)
                        } label: {
                            Image(systemName: "eye.slash")
                                .font(.title2)
                                .foregroundColor(.white)
                        }

                        Slider(value: $viewModel.ghostOpacity, in: 0.1...0.8)
                            .frame(width: 100)
                            .tint(.white)

                        Button {
                            viewModel.ghostOpacity = min(0.8, viewModel.ghostOpacity + 0.1)
                        } label: {
                            Image(systemName: "eye")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }

                    Button {
                        viewModel.startTimer(seconds: 5)
                    } label: {
                        Image(systemName: "timer")
                            .font(.title2)
                            .foregroundColor(.white)
                    }

                    Button {
                        viewModel.toggleVoiceCapture()
                    } label: {
                        Image(systemName: viewModel.voiceCaptureManager.isListening ? "mic.fill" : "mic")
                            .font(.title2)
                            .foregroundColor(viewModel.voiceCaptureManager.isListening ? .red : .white)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Spacer()

                if let count = viewModel.countdown {
                    Text("\(count)")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                }

                HStack(spacing: 12) {
                    ForEach(PhotoAngle.allCases, id: \.self) { angle in
                        Button {
                            viewModel.selectedAngle = angle
                        } label: {
                            VStack(spacing: 2) {
                                Image(systemName: angle.iconName)
                                    .font(.body)
                                Text(angle.displayName)
                                    .font(.caption2)
                            }
                            .foregroundColor(viewModel.selectedAngle == angle ? .teal : .white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(viewModel.selectedAngle == angle ? Color.white.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.bottom, 8)

                HStack(spacing: 50) {
                    Button {
                        viewModel.cameraManager.switchCamera()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(.title2)
                            .foregroundColor(.white)
                    }

                    Button {
                        viewModel.capturePhoto()
                    } label: {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 72, height: 72)
                            .overlay(Circle().stroke(Color.gray, lineWidth: 3))
                    }

                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            viewModel.setAlbum(album)
            viewModel.cameraManager.onPhotoCaptured = { image in
                viewModel.handleCapturedImage(image)
            }
            viewModel.cameraManager.start()
        }
        .onDisappear {
            viewModel.cameraManager.stop()
            viewModel.voiceCaptureManager.stopListening()
        }
    }
}

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let layer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
                layer.frame = uiView.bounds
            }
        }
    }
}

struct GridOverlay: View {
    var body: some View {
        Canvas { context, size in
            let lines = 3
            let spacingX = size.width / CGFloat(lines)
            let spacingY = size.height / CGFloat(lines)

            var path = Path()
            for i in 1..<lines {
                path.move(to: CGPoint(x: spacingX * CGFloat(i), y: 0))
                path.addLine(to: CGPoint(x: spacingX * CGFloat(i), y: size.height))
                path.move(to: CGPoint(x: 0, y: spacingY * CGFloat(i)))
                path.addLine(to: CGPoint(x: size.width, y: spacingY * CGFloat(i)))
            }
            context.stroke(path, with: .color(.white.opacity(0.3)), lineWidth: 0.5)
        }
        .ignoresSafeArea()
    }
}
