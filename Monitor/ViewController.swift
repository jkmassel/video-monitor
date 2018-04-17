//
//  ViewController.swift
//  Monitor
//
//  Created by Jeremy Massel on 2018-04-12.
//  Copyright © 2018 Massel Industries. All rights reserved.
//

import Cocoa
import AVFoundation
import SnapKit

class ViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
//		AVCaptureDevice.devices(for: .video).forEach { (device) in
//
//			debugPrint(device.localizedName)
//
//			if let input = try? AVCaptureDeviceInput(device: device){
//				session.addInput(input)
//			}
//		}

		self.view.layer?.backgroundColor = NSColor.black.cgColor

		let primarySource = VideoSource()
		let secondarySource = VideoSource()

		self.view.addSubview(primarySource)
		primarySource.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.left.equalToSuperview()
			make.right.equalTo(self.view.snp.centerX)
			make.bottom.equalTo(self.view.snp.centerY)
		}

		self.view.addSubview(secondarySource)
		secondarySource.snp.makeConstraints { (make) in
			make.top.equalToSuperview()
			make.right.equalToSuperview()
			make.bottom.equalTo(self.view.snp.centerY)
			make.left.equalTo(self.view.snp.centerX)
		}

		let bottomLeft = VideoSource()
		self.view.addSubview(bottomLeft)
		bottomLeft.snp.makeConstraints { (make) in
			make.top.equalTo(self.view.snp.centerY)
			make.right.equalTo(self.view.snp.centerX)
			make.bottom.equalToSuperview()
			make.left.equalToSuperview()
		}

		let bottomRight = VideoSource()
		self.view.addSubview(bottomRight)
		bottomRight.snp.makeConstraints { (make) in
			make.top.equalTo(self.view.snp.centerY)
			make.right.equalToSuperview()
			make.left.equalTo(self.view.snp.centerX)
			make.bottom.equalToSuperview()
		}

		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:theWindow];
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	override func viewWillTransition(to newSize: NSSize) {
		super.viewWillTransition(to: newSize)
//		self.previewLayer.frame = CGRect(origin: .zero, size: newSize)
	}
}
