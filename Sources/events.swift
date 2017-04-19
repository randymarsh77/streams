import Scope

public protocol IReadableEventingStream : IReadableStream
{
	associatedtype ChunkType
	associatedtype EventType

	func on(onEvent: @escaping (_ event: EventType) -> Void) -> Scope
}

public protocol IWriteableEventingStream : IWriteableStream
{
	associatedtype ChunkType
	associatedtype EventType

	func raise(_ event: EventType) -> Void
}

public protocol IEventingStream : IReadableEventingStream, IWriteableEventingStream
{
	associatedtype ChunkType
	associatedtype EventType
}

public struct ReadableEventingStream<S, T> : IReadableEventingStream
{
	public typealias EventType = S
	public typealias ChunkType = T

	public init<U: IReadableEventingStream>(_ delegate: U) where U.ChunkType == ChunkType, U.EventType == EventType {
		_subscribe = delegate.subscribe
		_on = delegate.on
	}

	public func subscribe(_ onChunk: @escaping (ChunkType) -> Void) -> Scope {
		return _subscribe(onChunk)
	}

	public func on(onEvent: @escaping (EventType) -> Void) -> Scope {
		return _on(onEvent)
	}

	let _subscribe: (_ onChunk: @escaping (ChunkType) -> Void) -> Scope
	let _on: (_ onEvent: @escaping (EventType) -> Void) -> Scope
}

public struct WriteableEventingStream<S, T> : IWriteableEventingStream
{
	public typealias EventType = S
	public typealias ChunkType = T

	public init<U: IWriteableEventingStream>(_ delegate: U) where U.ChunkType == ChunkType, U.EventType == EventType {
		_publish = delegate.publish
		_raise = delegate.raise
	}

	public func publish(_ chunk: ChunkType) -> Void {
		_publish(chunk)
	}

	public func raise(_ event: EventType) {
		_raise(event)
	}

	let _publish: (_ chunk: ChunkType) -> Void
	let _raise: (_ event: EventType) -> Void
}

public enum EventingStreamContext<S, T>
{
	case Event(S)
	case Data(T)
}

public class EventingStream<S, T> : IEventingStream
{
	public typealias EventType = S
	public typealias ChunkType = T

	let base: Stream<EventingStreamContext<S, T>>

	internal init(_ stream: Stream<EventingStreamContext<S, T>>) {
		base = stream
	}

	public func raise(_ event: EventType)
	{
		base.publish(.Event(event))
	}

	public func publish(_ chunk: ChunkType) -> Void
	{
		base.publish(.Data(chunk))
	}

	public func subscribe(_ onChunk: @escaping (_ chunk: ChunkType) -> Void) -> Scope
	{
		return base.subscribe { (context: EventingStreamContext<S, T>) in
			switch (context)
			{
			case .Data(let received):
				onChunk(received)
				break
			default:
				break
			}
		}
	}

	public func on(onEvent: @escaping (_ event: EventType) -> Void) -> Scope
	{
		return base.subscribe { (context: EventingStreamContext<S, T>) in
			switch (context)
			{
			case .Event(let received):
				onEvent(received)
				break
			default:
				break
			}
		}
	}
}

public extension IStream
{
	public func asEventing<T>() -> EventingStream<T, Self.ChunkType> {
		let proxy: Stream<EventingStreamContext<T, Self.ChunkType>> = Stream()
		_ = self.subscribe { (chunk) in
			proxy.publish(.Data(chunk))
		}
		return EventingStream(proxy)
	}
}
