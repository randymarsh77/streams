public extension IReadableStream
{
	public func pipe<S: IWriteableStream, T: IReadableStream>(to: S) -> T where S.ChunkType == Self.ChunkType, T.ChunkType == Self.ChunkType {
		_ = self.subscribe { chunk in
			to.publish(chunk)
		}
		return self as! T
	}
}

public extension IWriteableStream
{
	public func pipe<S: IReadableStream, T: IWriteableStream>(from: S) -> T where S.ChunkType == Self.ChunkType, T.ChunkType == Self.ChunkType {
		_ = from.subscribe { chunk in
			self.publish(chunk)
		}
		return self as! T
	}
}
