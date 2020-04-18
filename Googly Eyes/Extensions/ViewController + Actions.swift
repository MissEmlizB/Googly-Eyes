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
	
	@IBAction func togglePause(sender: AnyObject) {
		
		guard let isPaused = sceneView.scene?.isPaused else {
			return
		}
		
		sceneView.scene?.isPaused = !isPaused
		
		// Show/hide our pause indicator
		self.setPaused(!isPaused)
	}
	
	@IBAction func savePhoto(sender: AnyObject) {
		
		guard sceneView.scene != nil else {
			return
		}
		
		let savePanel = NSSavePanel()
		savePanel.allowedFileTypes = ["png"]
		
		savePanel.beginSheetModal(for: self.view.window!) {
			
			guard $0 == .OK, let url = savePanel.url else {
				return
			}
			
			self.setBusy(true)
			
			// Get our current scene's texture
			self.getCurrentSceneTexture {
		
				DispatchQueue.main.async {
					self.setBusy(false)
				}
				
				try? $0?.write(to: url)
			}
		}
	}
	
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
		
		let scene = GooglyEyeScene(photo: photo, blend: true) {
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
		self.setPaused(false)
	}
	
	func setBusy(_ busy: Bool) {
		
		processingBackground.isHidden = !busy
		processingIndicator.isHidden = !busy
		
		(busy ? processingIndicator.startAnimation(self)
			  : processingIndicator.stopAnimation(self))
	}
	
	private func setPaused(_ isPaused: Bool) {
		
		CATransaction.begin()
		
		if isPaused {
			pauseIndicator.isHidden = false
		}
		else {
			CATransaction.setCompletionBlock {
				self.pauseIndicator.isHidden = true
			}
		}
		
		let animation = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
		animation.isRemovedOnCompletion = true
		
		let t1 = CATransform3DMakeTranslation(0.0, 100.0, 0.0)
		let t2 = CATransform3DMakeTranslation(0.0, 0.0, 0.0)
		
		animation.fromValue = isPaused ? t1 : t2
		animation.toValue = isPaused ? t2 : t1
		
		pauseIndicator.layer!.transform = animation.toValue as! CATransform3D
		animation.run(forKey: "transform", object: pauseIndicator.layer!, arguments: nil)
		
		CATransaction.commit()
	}
	
	private func getCurrentSceneTexture(completion: ((Data?) -> ())) {
		
		guard let scene = sceneView.scene,
			let texture = sceneView.texture(from: scene),
			let data = texture.cgImage().image.tiffRepresentation,
			let pngData = NSBitmapImageRep(data: data)?.representation(using: .png, properties: [:]) else {
				
				completion(nil)
				return
		}
		
		completion(pngData)
	}
}
