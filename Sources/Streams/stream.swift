import IDisposable
import Scope

open class Stream<T>: IStream {
	public typealias ChunkType = T

	public init() {
	}

	public func dispose() {
		let disposables =
			self.disposables
			+ (ownershipSemantic == .chained || ownershipSemantic == .source
				? self.downstreamDisposables : [])
			+ (ownershipSemantic == .chained || ownershipSemantic == .sink
				? self.upstreamDisposables : [])

		self.subscribers = [Subscriber<ChunkType>]()
		self.downstreamDisposables = [IDisposable]()
		self.upstreamDisposables = [IDisposable]()
		self.disposables = [IDisposable]()

		for disposable in disposables {
			disposable.dispose()
		}
	}

	public func publish(_ chunk: ChunkType) {
		for subscriber in self.subscribers {
			subscriber.publish(chunk)
		}
	}

	public func subscribe(_ onChunk: @escaping (_ chunk: ChunkType) -> Void) -> Scope {
		let subscriber = Subscriber(callback: onChunk)
		self.subscribers.append(subscriber)
		return Scope(dispose: { self.removeSubscriber(subscriber: subscriber) })
	}

	func removeSubscriber(subscriber: Subscriber<ChunkType>) {
		if let i = self.subscribers.firstIndex(where: { (x) -> Bool in
			return x === subscriber
		}) {
			self.subscribers.remove(at: i)
		}
	}

	public func addDownstreamDisposable(_ disposable: IDisposable) {
		downstreamDisposables.append(disposable)
	}

	public func addUpstreamDisposable(_ disposable: IDisposable) {
		upstreamDisposables.append(disposable)
	}

	public func addDisposable(_ disposable: IDisposable) {
		disposables.append(disposable)
	}

	public func configureOwnershipSemantic(_ semantic: OwnershipSemantic) {
		ownershipSemantic = semantic
	}

	var subscribers: [Subscriber<ChunkType>] = [Subscriber<ChunkType>]()
	var disposables: [IDisposable] = [IDisposable]()
	var downstreamDisposables: [IDisposable] = [IDisposable]()
	var upstreamDisposables: [IDisposable] = [IDisposable]()
	var ownershipSemantic = OwnershipSemantic.chained
}

internal class Subscriber<T> {
	var callback: (_ chunk: T) -> Void

	internal init(callback: @escaping (_ chunk: T) -> Void) {
		self.callback = callback
	}

	internal func publish(_ chunk: T) {
		self.callback(chunk)
	}
}
