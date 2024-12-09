import IDisposable
import Scope

public protocol IReadableEventingStream: IReadableStream {
	associatedtype ChunkType
	associatedtype EventType

	func on(onEvent: @escaping (_ event: EventType) -> Void) -> Scope
}

public protocol IWriteableEventingStream: IWriteableStream {
	associatedtype ChunkType
	associatedtype EventType

	func raise(_ event: EventType)
}

public protocol IEventingStream: IReadableEventingStream, IWriteableEventingStream {
	associatedtype ChunkType
	associatedtype EventType
}

public struct ReadableEventingStream<S, T>: IReadableEventingStream {
	public typealias EventType = S
	public typealias ChunkType = T

	public init<U: IReadableEventingStream>(_ delegate: U)
	where U.ChunkType == ChunkType, U.EventType == EventType {
		_subscribe = delegate.subscribe
		_on = delegate.on
		_addDownstreamDisposable = delegate.addDownstreamDisposable
		_addUpstreamDisposable = delegate.addUpstreamDisposable
		_addDisposable = delegate.addDisposable
		_dispose = delegate.dispose
		_configureOwnershipSemantic = delegate.configureOwnershipSemantic
	}

	public func dispose() {
		_dispose()
	}

	public func subscribe(_ onChunk: @escaping (ChunkType) -> Void) -> Scope {
		return _subscribe(onChunk)
	}

	public func on(onEvent: @escaping (EventType) -> Void) -> Scope {
		return _on(onEvent)
	}

	public func addDownstreamDisposable(_ disposable: IDisposable) {
		_addDownstreamDisposable(disposable)
	}

	public func addUpstreamDisposable(_ disposable: IDisposable) {
		_addUpstreamDisposable(disposable)
	}

	public func addDisposable(_ disposable: IDisposable) {
		_addDisposable(disposable)
	}

	public func configureOwnershipSemantic(_ semantic: OwnershipSemantic) {
		_configureOwnershipSemantic(semantic)
	}

	let _subscribe: (_ onChunk: @escaping (ChunkType) -> Void) -> Scope
	let _on: (_ onEvent: @escaping (EventType) -> Void) -> Scope
	let _addDownstreamDisposable: (IDisposable) -> Void
	let _addUpstreamDisposable: (IDisposable) -> Void
	let _addDisposable: (IDisposable) -> Void
	let _dispose: () -> Void
	let _configureOwnershipSemantic: (_ semantic: OwnershipSemantic) -> Void
}

public struct WriteableEventingStream<S, T>: IWriteableEventingStream {
	public typealias EventType = S
	public typealias ChunkType = T

	public init<U: IWriteableEventingStream>(_ delegate: U)
	where U.ChunkType == ChunkType, U.EventType == EventType {
		_publish = delegate.publish
		_raise = delegate.raise
	}

	public func publish(_ chunk: ChunkType) {
		_publish(chunk)
	}

	public func raise(_ event: EventType) {
		_raise(event)
	}

	let _publish: (_ chunk: ChunkType) -> Void
	let _raise: (_ event: EventType) -> Void
}

public enum EventingStreamContext<S, T> {
	case event(S)
	case data(T)
}

public class EventingStream<S, T>: IEventingStream {
	public typealias EventType = S
	public typealias ChunkType = T

	let base: Stream<EventingStreamContext<S, T>>

	internal init(_ stream: Stream<EventingStreamContext<S, T>>) {
		base = stream
	}

	public func dispose() {
		base.dispose()
	}

	public func raise(_ event: EventType) {
		base.publish(.event(event))
	}

	public func publish(_ chunk: ChunkType) {
		base.publish(.data(chunk))
	}

	public func subscribe(_ onChunk: @escaping (_ chunk: ChunkType) -> Void) -> Scope {
		return base.subscribe { (context: EventingStreamContext<S, T>) in
			switch context
			{
			case .data(let received):
				onChunk(received)
			default:
				break
			}
		}
	}

	public func on(onEvent: @escaping (_ event: EventType) -> Void) -> Scope {
		return base.subscribe { (context: EventingStreamContext<S, T>) in
			switch context
			{
			case .event(let received):
				onEvent(received)
			default:
				break
			}
		}
	}

	public func addDownstreamDisposable(_ disposable: IDisposable) {
		base.addDownstreamDisposable(disposable)
	}

	public func addUpstreamDisposable(_ disposable: IDisposable) {
		base.addUpstreamDisposable(disposable)
	}

	public func addDisposable(_ disposable: IDisposable) {
		base.addDisposable(disposable)
	}

	public func disposeWith(_ disposable: IDisposable) -> EventingStream<S, T> {
		base.addDisposable(disposable)
		return self
	}

	public func configureOwnershipSemantic(_ semantic: OwnershipSemantic) {
		base.configureOwnershipSemantic(semantic)
	}
}

extension IStream {
	public func asEventing<T>() -> EventingStream<T, Self.ChunkType> {
		let proxy: Stream<EventingStreamContext<T, Self.ChunkType>> = Stream()
		let unsubscribe = self.subscribe { (chunk) in
			proxy.publish(.data(chunk))
		}
		return EventingStream(proxy)
			.disposeWith(unsubscribe)
	}
}
