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
	
	// MARK: Scene
	
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
			
			for face in faces {
				let landmarks = face.landmarks

				self.addEye(landmarks?.leftEye, size: photoSize)
				self.addEye(landmarks?.rightEye, size: photoSize)
			}
			
			DispatchQueue.main.async {
				self.completion?()
			}
		}

		// Live view
		self.scaleMode = .aspectFill
	}
	
	private func addEye(_ landmark: VNFaceLandmarkRegion2D?, size photoSize: CGSize) {
		
		guard let landmark = landmark else {
			return
		}
		
		let points = landmark.pointsInImage(imageSize: photoSize)
		
		// Find its position and size
		let centre = findCentre(of: points)
		let size = getSize(of: points)
		let eye = GooglyEye(centre, size: size)
		
		// Add it to our scene
		DispatchQueue.main.async {
			self.addChild(eye)
		}
	}
}
