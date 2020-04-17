//
//  GooglyEyeScene.swift
//  Googly Eyes
//
//  Created by Emily Blackwell on 11/04/2020.
//  Copyright © 2020 Emily Blackwell. All rights reserved.
//

import SpriteKit
import Vision


// Colour blending options
fileprivate let colourAveragingDistance: CGFloat = 250
fileprivate let colourAveragingSamples = 300


public final class GooglyEyeScene: SKScene {
    
    var photo: GEImage?
    
    // Colour blending properties
    private var appliesBlending: Bool = true
    private var cgImage: CGImage?
    private var photoData: Data?
    
    var completion: (() -> ())?
    
    /// The currently-running effects task
    private var task: DispatchWorkItem? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    // MARK: Scene
    
    public init(photo: GEImage?, blend: Bool = true, processingFinished completion: (() -> ())? = nil) {
        
        super.init(size: photo?.size ?? .zero)
        
        self.appliesBlending = blend
        self.completion = completion
        
        self.photo = photo
        self.cacheImage()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
    }
    
    override public func didMove(to view: SKView) {
        
        super.didMove(to: view)
        self.applyEffect()
    }
    
    // MARK: Actions
    
    private func cacheImage() {
        
        guard let photo = self.photo,
            let cgImage = CGImage.fromImage(photo),
            let data = cgImage.dataProvider?.data as Data? else {
                return
        }
        
        self.cgImage = cgImage
        self.photoData = data
    }
    
    // MARK: Effects
    
    public func applyEffect(photo effectPhoto: GEImage? = nil) {
        
        if let effectPhoto = effectPhoto {
            self.photo = effectPhoto
            self.cacheImage()
        }
        
        guard let photo = self.photo else {
            return
        }
        
        let photoSize = photo.size
        
        // Photo background
        let photoTexture = SKTexture(image: photo)
        let bg = SKSpriteNode(texture: photoTexture)
        
        bg.position = CGPoint(x: photoSize.width/2, y: photoSize.height/2)
        self.addChild(bg)
        
        self.task = DispatchWorkItem {
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
        }
        
        DispatchQueue.global(qos: .userInteractive)
            .async(execute: self.task!)
        
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
        
        // Try to blend it with the surrounding area
        if self.appliesBlending {
            
            let averageColour = self.getAverageColour(at: centre, size: photoSize)
            
            eye.color = averageColour
            eye.colorBlendFactor = 0.34
        }
        
        // Add it to our scene
        DispatchQueue.main.async {
            self.addChild(eye)
        }
    }
    
    // MARK: Colour Blending
    
    private func restrictedValue(_ value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        
        if          value >= max { return max }
        else if  value <= min { return min }
        return   value
    }
    
    private func getAverageColour(at point: CGPoint, size: CGSize) -> GEColour {
        
        var colourBlend: [CGFloat] = [0, 0, 0]
        
        let scale = (size.width / 1920.0)
        let distance = colourAveragingDistance * scale
        let colourAveragingRange = (-distance...distance)
        
        // Randomly pick spots around the point
        
        let points = (0 ..< colourAveragingSamples).map { _ -> CGPoint in
            
            let rx = point.x + CGFloat.random(in: colourAveragingRange)
            let ry = point.y + CGFloat.random(in: colourAveragingRange)
            
            let x = self.restrictedValue(rx, min: 0, max: size.width)
            let y = self.restrictedValue(ry, min: 0, max: size.height)
            
            return CGPoint(x: x, y: y)
        }
        
        // Get the area's average colour
        
        guard let colours = self.cgImage?.getColours(atPoints: points, dataCache: self.photoData) else {
            return .white
        }
        
        let colourCount = CGFloat(colours.count)
        
        for colour in colours {
            
            #if os(macOS)
            guard let colour = colour.usingColorSpace(.deviceRGB) else {
                continue
            }
            #endif
            
            colourBlend[0] += colour.redComponent
            colourBlend[1] += colour.greenComponent
            colourBlend[2] += colour.blueComponent
        }
        
        return GEColour(red: colourBlend[0] / colourCount,
                        green: colourBlend[1] / colourCount,
                        blue: colourBlend[2] / colourCount,
                        alpha: 1.0)
    }
}
