//
//  VideoSource.swift
//  Monitor
//
//  Created by Jeremy Massel on 2018-04-13.
//  Copyright © 2018 Massel Industries. All rights reserved.
//

import Cocoa
import AVFoundation
import CoreGraphics
import Quartz

fileprivate let pixelFormat = NSOpenGLPixelFormat(attributes: [])!

class VideoSource: NSView {

	var previewLayer: AVCaptureVideoPreviewLayer?

	private var currentDevice: AVCaptureDevice?
	private let session = AVCaptureSession()
	private let dispatchQueue = DispatchQueue(label: "video-source-\(NSUUID().uuidString)")

	private let colorSpace = CGColorSpaceCreateDeviceRGB()

	private let devicePicker = NSPopUpButton(frame: .zero, pullsDown: true)

	init(){
		super.init(frame: .zero)

//		let output = AVCaptureVideoDataOutput()
//		output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
//		output.alwaysDiscardsLateVideoFrames = true
//		output.setSampleBufferDelegate(self, queue: self.dispatchQueue)

		self.devicePicker.addItem(withTitle: "No Device")
		self.devicePicker.addItems(withTitles: AVCaptureDevice.devices(for: .video).map{ $0.localizedName })
		self.devicePicker.pullsDown = false

		self.devicePicker.action = #selector(didChangeInput(_:))
		self.devicePicker.target = self

		self.addSubview(self.devicePicker)

		self.devicePicker.snp.makeConstraints { (make) in
			make.bottom.equalToSuperview()
			make.left.equalToSuperview()
		}

		self.wantsLayer = true
		self.layer?.contentsGravity = kCAGravityResizeAspectFill

		self.addSubview(self.devicePicker)

		NotificationCenter.default.addObserver(forName: NSWindow.didResizeNotification, object: nil, queue: nil) { (note) in
			self.updatePreviewFrame()
		}
	}

	required init?(coder decoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@objc func didChangeInput(_ sender: NSPopUpButton){


		guard let deviceName = sender.selectedItem?.title,
			let device = AVCaptureDevice.devices(for: .video).first(where: { $0.localizedName == deviceName })
			else { return }

		self.switchTo(device: device)
	}

	private var currentInput: AVCaptureDeviceInput?
	func switchTo(device: AVCaptureDevice){

		debugPrint("Switching to \(device.localizedName)")
		guard let input = try? AVCaptureDeviceInput(device: device) else { return }

		self.session.stopRunning()

		self.previewLayer?.removeFromSuperlayer()

		if let currentInput = self.currentInput{
			self.session.removeInput(currentInput)
		}

		self.session.addInput(input)
		self.currentInput = input

		let layer = AVCaptureVideoPreviewLayer(session: self.session)
		layer.videoGravity = .resizeAspectFill
		self.layer?.addSublayer(layer)

		self.previewLayer = layer
		self.updatePreviewFrame()

		self.session.startRunning()
	}

	private func updatePreviewFrame(){

		let offset = self.devicePicker.frame.height
		let size = CGSize(width: self.bounds.width, height: self.bounds.height - offset)

		let origin = CGPoint(x: 0, y: offset)

		self.previewLayer?.frame = CGRect(origin: origin, size: size)
		self.previewLayer?.videoGravity = .resizeAspectFill
		self.previewLayer?.contentsGravity = kCAGravityBottomLeft
	}
}

extension VideoSource : AVCaptureVideoDataOutputSampleBufferDelegate{

	func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		debugPrint("dropped frames!")
	}

	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

		guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

		// Lock the base address of the pixel buffer
		CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly);

		defer{
			CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
		}

		// Get the number of bytes per row for the pixel buffer
		let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer);

		let width = CVPixelBufferGetWidth(pixelBuffer)
		let height = CVPixelBufferGetHeight(pixelBuffer)
		let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

		// Create a bitmap graphics context with the sample buffer data
		var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Little.rawValue
		bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue & CGBitmapInfo.alphaInfoMask.rawValue

		let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: self.colorSpace, bitmapInfo: bitmapInfo)

		// Create a Quartz image from the pixel data in the bitmap graphics context
		guard let image = context?.makeImage() else { return }

		DispatchQueue.main.async {
			self.layer?.contents = image
		}
	}
}
