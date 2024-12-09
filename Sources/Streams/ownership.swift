public enum OwnershipSemantic {
	case chained
	case source
	case sink
	case orphaned
}

extension IReadableStream {
	public func withOwnershipSemantic<T>(_ semantic: OwnershipSemantic) -> ReadableStream<T>
	where T == Self.ChunkType {
		self.configureOwnershipSemantic(semantic)
		return ReadableStream(self)
	}

	public func asSource<T>() -> ReadableStream<T> where T == Self.ChunkType {
		let input = Stream<T>()
		let unsubscribe = self.pipe(to: input)
		return ReadableStream(input)
			.withOwnershipSemantic(.source)
			.disposeWith(unsubscribe)
	}
}
