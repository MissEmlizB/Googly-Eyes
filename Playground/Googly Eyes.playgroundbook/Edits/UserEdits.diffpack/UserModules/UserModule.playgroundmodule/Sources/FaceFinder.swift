import Vision

public func findFace(in image: GEImage, completion: (@escaping (VNRequest) -> ())) {
    
    let request = VNDetectFaceLandmarksRequest {
        guard $1 == nil else { return }
        completion($0)
    }
    
    // Set up our detection request
    guard let image = image.cgImage else { return }
    let handler = VNImageRequestHandler(cgImage: image, options: [:])
    
    try? handler.perform([request])
}

// MARK: Positioning Helpers

public func findCentre(of points: [CGPoint]) -> CGPoint {
    return points.reduce(.zero, +) / points.count
}

public func getSize(of points: [CGPoint], scale: CGFloat = 2.5) -> CGSize {
    
    guard let minPoint = points.min(), 
        let maxPoint = points.max() else { 
            return .zero 
    }
    
    let size = abs(maxPoint.x - minPoint.x) * scale
    return CGSize(width: size, height: size)
}

