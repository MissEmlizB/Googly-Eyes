import SpriteKit


let textures = (1...8)
    .map { SKTexture(imageNamed: "eye\($0)") }

let first = textures.first
let firstSize = first?.size() ?? .zero

public final class GooglyEye: SKSpriteNode {
	
    public init(_ pos: CGPoint, size: CGSize) {
        
        super.init(texture: first, color: .clear, size: firstSize)
        
        // Loop its animation forever
        let speed = Double.random(in: 0.05...0.25)
        
        let animate = SKAction.repeatForever(
            SKAction.animate(with: textures, timePerFrame: speed))
        
        self.run(SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval.random(in: 0.1...1.0)),
            animate
        ]))
        
        // Set its position
        self.position = pos
        self.size = size
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

