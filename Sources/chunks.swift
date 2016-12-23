public extension IReadableStream
{
	public func chunks(of: Int) -> ReadableStream<Array<Self.ChunkType>> {
		let chunks = self.map { (elements: [ChunkType]) in
			return elements.count == of ? (elements, []) : (nil, elements)
		}
		return chunks
	}
}
