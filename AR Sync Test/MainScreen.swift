import SwiftUI

struct MainScreen: View {
    @StateObject private var session: MultipeerSession
    @State private var testData: TestData
    @State private var imageSize: CGSize = .zero
    @State private var ipad2D: CGPoint = .zero
    @Environment(\.scenePhase) private var scenePhase
    private let fileLogger: FileLogger
    
    let normalizedPoints: [CGPoint]
    
    init(xPoints: Int = 5, yPoints: Int = 5) {
        let testData: TestData = .init(iphone2D: .zero, iphone3D: .zero, handPoint: .zero, underHandPoint: .zero, status: "")
        self.testData = testData
        //self._testData = StateObject(wrappedValue: testData)
        self._session = StateObject(wrappedValue: MultipeerSession(testData: testData))
        self.fileLogger = FileLogger()
        
        self.normalizedPoints = {
            var points: [CGPoint] = []
            for y in 0..<yPoints {
                for x in 0..<xPoints {
                    points.append(
                        CGPoint(
                            x: xPoints > 1 ? (Double(x) / Double(xPoints - 1) * 0.8 + 0.1) : 0.5,
                            y: yPoints > 1 ? (Double(y) / Double(yPoints - 1) * 0.8 + 0.1) : 0.5
                        )
                    )
                }
            }
            return points
        }()
    }
    
    var body: some View {
        ZStack {
            Image("united kingdom model")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                imageSize = geometry.size
                            }
                    }
                )
                .onTapGesture { point in
                    guard point.x >= 0, point.x <= imageSize.width,
                          point.y >= 0, point.y <= imageSize.height else { return }
                    
                    self.ipad2D = .init(x: point.x / imageSize.width, y: point.y / imageSize.height)
                    //session.send(point: ipad2D)
                    
                    var logEntry: String
                    
                    if let lastTimePointing = session.lastTimePointing {
                        let delta = Date().timeIntervalSince1970 - lastTimePointing
                        
                        logEntry = "\(testData.status),\(delta),\(testData.iphone2D.dataDescription),\(ipad2D.dataDescription),\(testData.distance),\(testData.iphone3D.dataDescription),\(testData.handPoint.dataDescription),\(testData.underHandPoint.dataDescription)"
                        session.lastTimePointing = nil
                    } else {
                        logEntry = "\(testData.status),,\(testData.iphone2D.dataDescription),\(ipad2D.dataDescription),\(testData.distance),\(testData.iphone3D.dataDescription),\(testData.handPoint.dataDescription),\(testData.underHandPoint.dataDescription)"
                    }
                    
                    fileLogger.log(entry: logEntry)
                }
            ForEach(normalizedPoints.indices, id: \.self) { index in
                let point = normalizedPoints[index]
                Circle()
                    .fill(.black)
                    .frame(width: 5, height: 5)
                    .position(
                        x: point.x * imageSize.width,
                        y: point.y * imageSize.height
                    )
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                fileLogger.saveToFile()
            }
        }
    }
}

#Preview {
    MainScreen(xPoints: 5, yPoints: 5)
}
