import IDisposable
import Scope

public protocol IReadableStream : IDisposable
{
	associatedtype ChunkType

	func subscribe(_ onChunk: @escaping (_ chunk: ChunkType) -> Void) -> Scope

	func addDownstreamDisposable(_ disposable: IDisposable)
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

public struct ReadableStream<T>: IReadableStream
{
	public typealias ChunkType = T

	public init<S: IReadableStream>(_ delegate: S) where S.ChunkType == T {
		_subscribe = delegate.subscribe
		_addDownstreamDisposable = delegate.addDownstreamDisposable
		_dispose = delegate.dispose
	}

	public func dispose() {
		_dispose()
	}

	public func subscribe(_ onChunk: @escaping (T) -> Void) -> Scope {
		return _subscribe(onChunk)
	}

	public func addDownstreamDisposable(_ disposable: IDisposable) {
		_addDownstreamDisposable(disposable)
	}

	let _subscribe: (_ onChunk: @escaping (T) -> Void) -> Scope
	let _addDownstreamDisposable: (IDisposable) -> ()
	let _dispose: () -> ()
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
