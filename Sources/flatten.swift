public extension IReadableStream where Self.ChunkType: Sequence
{
	public func flatten() -> ReadableStream<Self.ChunkType.Iterator.Element> {
		let mapped: Stream<Self.ChunkType.Iterator.Element> = Stream()
		_ = self.subscribe { data in
			for item in data {
				mapped.publish(item)
			}
		}
		return ReadableStream(mapped)
	}
}
