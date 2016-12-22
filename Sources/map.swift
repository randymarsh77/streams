public typealias SingleValueMapper<S, T> = (S) -> T

public typealias MultipleValueMapper<S, T> = ([S]) -> (T?, [S])

public extension IReadableStream
{
	public func map<T: IReadableStream>(_ mapper: @escaping SingleValueMapper<ChunkType, T.ChunkType>) -> T {
		let s = SingleValueMappingStream(self, mapper)
		_ = self.subscribe { data in
			s.publish(mapper(data))
		}
		return s as! T
	}

	public func map<T: IReadableStream>(_ mapper: @escaping MultipleValueMapper<ChunkType, T.ChunkType>) -> T {
		let s = MultipleValueMappingStream(self, mapper)
		_ = self.subscribe { data in
			s.accumulate(data)
		}
		return s as! T
	}
}

internal class SingleValueMappingStream<S: IReadableStream, T> : Stream<T>
{
	internal init(_ source: S, _ map: @escaping SingleValueMapper<S.ChunkType, T>) {
	}
}

internal class MultipleValueMappingStream<S: IReadableStream, T> : Stream<T>
{
	internal init(_ source: S, _ map: @escaping MultipleValueMapper<S.ChunkType, T>) {
		_map = map
	}

	internal func accumulate(_ data: S.ChunkType) {
		_accumulator.append(data)
		let (result, leftovers) = _map(_accumulator)
		_accumulator = leftovers
		if (result != nil) {
			publish(result!)
		}
	}

	var _accumulator: [S.ChunkType] = []
	var _map: MultipleValueMapper<S.ChunkType, T>
}
