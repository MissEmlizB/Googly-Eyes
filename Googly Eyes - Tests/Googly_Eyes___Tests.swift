//___FILEHEADER___

import XCTest

class GooglyEyesTest: XCTestCase {

	func testMakeScene() {
		
		let expectation = XCTestExpectation(description: "Googly Eyes - make scene")
		
		guard let photo = NSImage(named: "photo-test") else {
			XCTFail()
			return
		}
		
		let scene = GooglyEyeScene(photo: photo, blend: true) {
			expectation.fulfill()
		}
		
		scene.blendAveragingSamples = 1_000
		scene.applyEffect()
		
		wait(for: [expectation], timeout: 5.0)
	}
	
	func testMakeScenePerformance() {
		measure { testMakeScene() }
	}
}
