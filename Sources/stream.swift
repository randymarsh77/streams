import Scope

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
