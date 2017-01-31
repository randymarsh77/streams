public extension IReadableStream
{
	public func pipe<T: IWriteableStream>(to: T) -> ReadableStream<Self.ChunkType> where T.ChunkType == Self.ChunkType {
		_ = self.subscribe { chunk in
			to.publish(chunk)
		}
		return ReadableStream(self)
	}
}

public extension IWriteableStream
{
	public func pipe<T: IReadableStream>(from: T) -> WriteableStream<Self.ChunkType> where T.ChunkType == Self.ChunkType {
		_ = from.subscribe { chunk in
			self.publish(chunk)
		}
		return WriteableStream(self)
	}
}
