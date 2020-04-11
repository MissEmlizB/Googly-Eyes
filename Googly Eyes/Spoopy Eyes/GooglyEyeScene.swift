//
//  GooglyEyeScene.swift
//  Googly Eyes
//
//  Created by Emily Blackwell on 11/04/2020.
//  Copyright © 2020 Emily Blackwell. All rights reserved.
//

import SpriteKit
import Vision


public final class GooglyEyeScene: SKScene {
	
	var photo: GEImage?
	var completion: (() -> ())?
	
	public init(photo: GEImage?, processingFinished completion: (() -> ())?) {
		
		super.init(size: photo?.size ?? .zero)
		
		self.completion = completion
		self.photo = photo
	}
	
	required public init?(coder aDecoder: NSCoder) {
		super.init()
	}
	
	override public func didMove(to view: SKView) {
		
		super.didMove(to: view)
		self.applyEffect()
	}
	
	// MARK: Actions
	
	public func applyEffect() {
		
		guard let photo = self.photo else {
			return
		}
		
		// Change 'photo' to whatever picture you want to ruin (improve)
		let photoSize = photo.size

		// Photo background
		let photoTexture = SKTexture(image: photo)
		let bg = SKSpriteNode(texture: photoTexture)

		bg.position = CGPoint(x: photoSize.width/2, y: photoSize.height/2)
		self.addChild(bg)

		// Googly eyes
		findFace(in: photo) {
			
			guard let faces = $0.results as? [VNFaceObservation] else {
				return
			}
			
			self.addEyes(to: faces, size: photoSize)
			
			DispatchQueue.main.async {
				self.completion?()
			}
		}

		// Live view
		self.scaleMode = .aspectFill
	}
	
	private func addEyes(to faces: [VNFaceObservation], size photoSize: CGSize) {
		
		for face in faces {
			let landmarks = face.landmarks
			
			guard let lEye = landmarks?.leftEye,
				let rEye = landmarks?.rightEye else {
					return
			}
			
			// Place it at the centre of each eye
			let lPoints = lEye.pointsInImage(imageSize: photoSize)
			let rPoints = rEye.pointsInImage(imageSize: photoSize)
			
			let left = findCentre(of: lPoints, size: photoSize)
			let right = findCentre(of: rPoints, size: photoSize)
			
			// Try to find the best size for it
			let leftSize = getSize(of: lPoints)
			let rightSize = getSize(of: rPoints)
			
			DispatchQueue.main.async {
				self.addChild(GooglyEye(left, size: leftSize))
				self.addChild(GooglyEye(right, size: rightSize))
			}
		}
	}
}
