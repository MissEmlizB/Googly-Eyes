import Vision
import UIKit


extension CGPoint: Comparable {
    
    public static func < (lhs: CGPoint, rhs: CGPoint) -> Bool {
        return (lhs.x + lhs.y) < (rhs.x + rhs.y)
    }
}

public func findFace(in image: UIImage, completion: (@escaping (VNRequest) -> ())) {
    
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

public func findCentre(of points: [CGPoint], size: CGSize) -> CGPoint {
    
    var centre = CGPoint(x: 0, y: 0)
    
    for point in points {
        centre.x += point.x
        centre.y += point.y
    }
    
    let count = CGFloat(points.count)
    
    centre.x = (centre.x / count)
    centre.y = (centre.y / count)
    
    return centre
}

public func getSize(of points: [CGPoint], scale: CGFloat = 2.5) -> CGSize {
    
    guard let minPoint = points.min(), 
        let maxPoint = points.max() else { 
            return .zero 
    }
    
    let size = abs(maxPoint.x - minPoint.x) * scale
    
    return CGSize(width: size, height: size)
}
