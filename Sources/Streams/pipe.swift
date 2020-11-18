public extension IReadableStream
{
	func pipe<T: IWriteableStream>(to: T) -> ReadableStream<Self.ChunkType> where T.ChunkType == Self.ChunkType {
		let unsubscribe = self.subscribe { chunk in
			to.publish(chunk)
		}
		return ReadableStream(self)
			.disposeWith(unsubscribe)
	}
}

public extension IWriteableStream
{
	func pipe<T: IReadableStream>(from: T) -> WriteableStream<Self.ChunkType> where T.ChunkType == Self.ChunkType {
		let unsubscribe = from.subscribe { chunk in
			self.publish(chunk)
		}
		from.addDisposable(unsubscribe)
		return WriteableStream(self)
	}
}
