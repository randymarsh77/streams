public extension IReadableStream
{
	public func pipe<S: IWriteableStream>(to: S) where S.ChunkType == Self.ChunkType {
		_ = self.subscribe { chunk in
			to.publish(chunk)
		}
	}
}

public extension IWriteableStream
{
	public func pipe<S: IReadableStream>(from: S) where S.ChunkType == Self.ChunkType {
		_ = from.subscribe { chunk in
			self.publish(chunk)
		}
	}
}
