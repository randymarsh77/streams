public enum OwnershipSemantic {
	case Chained
	case Source
	case Sink
	case Orphaned
}

public extension IReadableStream
{
	func withOwnershipSemantic<T>(_ semantic: OwnershipSemantic) -> ReadableStream<T> where T == Self.ChunkType {
		self.configureOwnershipSemantic(semantic)
		return ReadableStream(self)
	}

	func asSource<T>() -> ReadableStream<T> where T == Self.ChunkType {
		let input = Stream<T>()
		let unsubscribe = self.pipe(to: input)
		return ReadableStream(input)
			.withOwnershipSemantic(.Source)
			.disposeWith(unsubscribe)
	}
}
