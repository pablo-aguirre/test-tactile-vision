import CoreGraphics

extension CGPoint {
    var formatted: String {
        let xFormatted = String(format: "%.2f", x)
        let yFormatted = String(format: "%.2f", y)
        return "(\(xFormatted), \(yFormatted))"
    }
    
    func distance(from point: CGPoint) -> CGFloat {
        let deltaX = point.x - self.x
        let deltaY = point.y - self.y
        return sqrt(deltaX * deltaX + deltaY * deltaY)
    }
}
