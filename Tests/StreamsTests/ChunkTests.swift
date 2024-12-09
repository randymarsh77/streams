import XCTest

@testable import Streams

class ChunkTests: XCTestCase {
	func testChunks() {
		var capturedChunks: [[Int]] = []
		let stream = Streams.Stream<Int>()
		_ =
			try? stream
			.chunks(of: 2)
			.subscribe { chunk in
				capturedChunks.append(chunk)
			}
		for i in 1...10 {
			stream.publish(i)
		}
		XCTAssertEqual(capturedChunks, [[1, 2], [3, 4], [5, 6], [7, 8], [9, 10]])
	}
}
