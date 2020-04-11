//
//  DragAndDropView.swift
//  Googly Eyes
//
//  Created by Emily Blackwell on 11/04/2020.
//  Copyright © 2020 Emily Blackwell. All rights reserved.
//

import Cocoa

protocol DragAndDropViewDelegate {
	func imageDropped(image: NSImage)
}

class DragAndDropView: NSView {
	
	@IBOutlet weak var dropLabel: NSTextField?
	var delegate: DragAndDropViewDelegate?
	
	private var noAnimationMode: Bool {
		get {
			NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
		}
	}

	override func viewDidMoveToWindow() {
		
		super.viewDidMoveToWindow()
		
		self.registerForDraggedTypes([.tiff, .png, .fileURL])
		self.wantsLayer = true
	}
	
	// MARK: Animation
	func setOpacity(_ opacity: Float, from: Float) {
		
		dropLabel?.isHidden = (opacity == 1.0)
		
		guard !noAnimationMode else {
			
			// Immediately complete the animation if 'reduce motion' is enabled
			self.layer!.opacity = opacity
			return
		}
		
		CATransaction.begin()
		
		let animation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
		
		animation.isRemovedOnCompletion = true
		animation.duration = 0.25
		animation.fromValue = from
		animation.toValue = opacity
		
		self.layer!.opacity = opacity
		animation.run(forKey: "opacity", object: self.layer!, arguments: nil)
		
		CATransaction.commit()
	}
	
    // MARK: D&D Indicator
	
	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
		
		self.setOpacity(0.5, from: 1.0)
		return .link
	}
	
	override func draggingExited(_ sender: NSDraggingInfo?) {
		
		self.setOpacity(1.0, from: 0.5)
	}
	
	// MARK: Drag and Drop
	
	override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		
		if self.layer!.opacity != 1.0 {
			self.setOpacity(1.0, from: self.layer!.opacity)
		}
		
		let pasteboard = sender.draggingPasteboard
		
		// Images (in file form)
		if let fileURLs = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
			let firstURL = fileURLs.first,
			let image = NSImage(contentsOf: firstURL)
		
		{
			self.delegate?.imageDropped(image: image)
			return true
		}
		
		// Images (in data form)
		if let images = pasteboard.readObjects(forClasses: [NSImage.self], options: nil) as? [NSImage],
			let firstImage = images.first
		{
			self.delegate?.imageDropped(image: firstImage)
			return true
		}
		
		return false
	}
}
