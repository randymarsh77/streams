import Scope

public protocol IReadableStream
{
	associatedtype ChunkType

	func subscribe(_ onChunk: @escaping (_ chunk: ChunkType) -> Void) -> Scope
}

public protocol IWriteableStream
{
	associatedtype ChunkType

	func publish(_ chunk: ChunkType) -> Void
}

public protocol IStream : IReadableStream, IWriteableStream
{
	associatedtype ChunkType
}

public class Stream<T> : IStream
{
	public typealias ChunkType = T

	public init() {
	}

	public func publish(_ chunk: ChunkType) -> Void {
		for subscriber in self.subscribers {
			subscriber.publish(chunk)
		}
	}

	public func subscribe(_ onChunk: @escaping (_ chunk: ChunkType) -> Void) -> Scope
	{
		let subscriber = Subscriber(callback: onChunk)
		self.subscribers.append(subscriber)
		return Scope(dispose: { self.removeSubscriber(subscriber: subscriber) })
	}

	func removeSubscriber(subscriber: Subscriber<ChunkType>) -> Void
	{
		let i = self.subscribers.index(where: { (x) -> Bool in
			return x === subscriber
		})
		self.subscribers.remove(at: i!)
	}

	var subscribers: [Subscriber<ChunkType>] = [Subscriber<ChunkType>]()
}

public struct ReadableStream<T>: IReadableStream
{
	public typealias ChunkType = T

	public init<S: IReadableStream>(_ delegate: S) where S.ChunkType == T {
		_subscribe = delegate.subscribe
	}

	public func subscribe(_ onChunk: @escaping (T) -> Void) -> Scope {
		return _subscribe(onChunk)
	}

	let _subscribe: (_ onChunk: @escaping (T) -> Void) -> Scope
}

public struct WriteableStream<T>: IWriteableStream
{
	public typealias ChunkType = T

	public init<S: IWriteableStream>(_ delegate: S) where S.ChunkType == T {
		_publish = delegate.publish
	}

	public func publish(_ chunk: T) -> Void {
		_publish(chunk)
	}

	let _publish: (_ chunk: T) -> Void
}

internal class Subscriber<T>
{
	var callback: (_ chunk: T) -> Void

	internal init(callback: @escaping (_ chunk: T) -> Void)
	{
		self.callback = callback
	}

	internal func publish(_ chunk: T) -> Void
	{
		self.callback(chunk)
	}
}
