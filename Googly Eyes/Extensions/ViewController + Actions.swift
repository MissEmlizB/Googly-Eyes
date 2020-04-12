//
//  ViewController + Actions.swift
//  Googly Eyes
//
//  Created by Emily Blackwell on 11/04/2020.
//  Copyright © 2020 Emily Blackwell. All rights reserved.
//

import Cocoa


extension ViewController {
	
	// MARK: Actions
	
	@IBAction func openPhoto(sender: AnyObject) {
		
		let openPanel = NSOpenPanel()
		openPanel.allowsMultipleSelection = false
		openPanel.resolvesAliases = true
		openPanel.allowedFileTypes = NSImage.imageTypes
		
		openPanel.beginSheetModal(for: view.window!) {
			
			guard $0 == .OK, let url = openPanel.url else {
				return
			}
			
			let photo = NSImage(contentsOf: url)
			self.setPhoto(photo: photo)
		}
	}
	
	func setPhoto(photo: NSImage?) {
		
		let scene = GooglyEyeScene(photo: photo) {
			self.setBusy(false)
		}
		
		self.setBusy(true)
		
		// Update its size
		sceneView.presentScene(scene)
		
		if let size = photo?.size {
			sceneView.frame.size = size
		}
		
		// Make sure our scroll view focuses on it
		scrollView.magnify(toFit: sceneView.frame)
	}
	
	func setBusy(_ busy: Bool) {
		
		processingBackground.isHidden = !busy
		processingIndicator.isHidden = !busy
		
		(busy ? processingIndicator.startAnimation(self)
			  : processingIndicator.stopAnimation(self))
	}
}
