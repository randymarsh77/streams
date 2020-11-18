import IDisposable
import Scope

public protocol IReadableStream : IDisposable
{
	associatedtype ChunkType

	func subscribe(_ onChunk: @escaping (_ chunk: ChunkType) -> Void) -> Scope

	func addDownstreamDisposable(_ disposable: IDisposable)

	func addUpstreamDisposable(_ disposable: IDisposable)

	func addDisposable(_ disposable: IDisposable)

	func configureOwnershipSemantic(_ semantic: OwnershipSemantic)
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
		_addUpstreamDisposable = delegate.addUpstreamDisposable
		_addDisposable = delegate.addDisposable
		_dispose = delegate.dispose
		_configureOwnershipSemantic = delegate.configureOwnershipSemantic
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

	public func addUpstreamDisposable(_ disposable: IDisposable) {
		_addUpstreamDisposable(disposable)
	}

	public func addDisposable(_ disposable: IDisposable) {
		_addDisposable(disposable)
	}

	public func disposeWith(_ disposable: IDisposable) -> ReadableStream<T> {
		_addDisposable(disposable)
		return self
	}

	public func configureOwnershipSemantic(_ semantic: OwnershipSemantic) {
		_configureOwnershipSemantic(semantic)
	}

	let _subscribe: (_ onChunk: @escaping (T) -> Void) -> Scope
	let _addDownstreamDisposable: (IDisposable) -> ()
	let _addUpstreamDisposable: (IDisposable) -> ()
	let _addDisposable: (IDisposable) -> ()
	let _dispose: () -> ()
	let _configureOwnershipSemantic: (_ semantic: OwnershipSemantic) -> ()
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
