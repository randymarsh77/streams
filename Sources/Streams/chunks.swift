public enum StreamConfigurationError: Error {
	case InvalidChunkSize
	case InvalidOverlap
}

extension IReadableStream {
	public func chunks(of: Int) throws -> ReadableStream<[Self.ChunkType]> {
		guard of > 0 else {
			throw StreamConfigurationError.InvalidChunkSize
		}

		let chunks = self.map { (elements: [ChunkType]) in
			return elements.count == of ? (elements, []) : (nil, elements)
		}
		return chunks
	}

	public func overlappingChunks(of: Int, advancingBy: Int) throws -> ReadableStream<
		[Self.ChunkType]
	> {
		guard advancingBy > 0 && advancingBy < of else {
			throw StreamConfigurationError.InvalidOverlap
		}

		return try configureDisposal(OverlappingChunkStream<ChunkType>(of, advancingBy)) {
			overlappingChunkStream in
			try self.chunks(of: advancingBy).subscribe {
				overlappingChunkStream.accumulate($0)
			}
		}
	}
}

internal class OverlappingChunkStream<T>: Stream<[T]> {
	internal init(_ chunkSize: Int, _ advanceBy: Int) {
		_chunkSize = chunkSize
		_advanceBy = advanceBy
	}

	func accumulate(_ data: [T]) {
		let toFill = min(data.count, _chunkSize - _accumulator.count)
		let leftovers = toFill < data.count ? data[toFill...data.count - 1] : []
		_accumulator.append(contentsOf: data[0...toFill - 1])
		if _accumulator.count == _chunkSize {
			publish(_accumulator)
			_accumulator = Array(_accumulator[_advanceBy..._chunkSize - 1])
		}

		if leftovers.count != 0 {
			accumulate(Array(leftovers))
		}
	}

	let _chunkSize: Int
	let _advanceBy: Int
	var _accumulator: [T] = []
}
