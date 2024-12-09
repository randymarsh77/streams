extension IReadableStream where Self.ChunkType: Sequence {
	public func flatten() -> ReadableStream<Self.ChunkType.Iterator.Element> {
		configureDisposal(Stream()) { mapped in
			self.subscribe { data in
				for item in data {
					mapped.publish(item)
				}
			}
		}
	}
}
