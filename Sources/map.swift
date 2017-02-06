public typealias OneToOneMapping<S, T> = (S) -> T

public typealias ManyToOneMapping<S, T> = ([S]) -> (T?, [S])

public typealias OneToManyMapping<S, T> = (S) -> [T]

public typealias MutatingMapping<S> = (_ :inout S) -> ()

public typealias MutatingOneToOneMapping<S, T> = (_ :inout S) -> T

public extension IReadableStream
{
	public func map<T>(_ mapping: @escaping OneToOneMapping<ChunkType, T>) -> ReadableStream<T> {
		let mapped: Stream<T> = Stream()
		_ = self.subscribe { data in
			mapped.publish(mapping(data))
		}
		addDownstreamDisposable(mapped)
		return ReadableStream(mapped)
	}

	public func map<T>(_ mapping: @escaping ManyToOneMapping<ChunkType, T>) -> ReadableStream<T> {
		let mapped = ManyToOneMappingStream(mapping)
		_ = self.subscribe { data in
			mapped.accumulate(data)
		}
		addDownstreamDisposable(mapped)
		return ReadableStream(mapped)
	}

	public func map<T>(_ mapping: @escaping OneToManyMapping<ChunkType, T>) -> ReadableStream<T> {
		let mapped: Stream<T> = Stream()
		_ = self.subscribe { data in
			let many = mapping(data)
			for item in many {
				mapped.publish(item)
			}
		}
		addDownstreamDisposable(mapped)
		return ReadableStream(mapped)
	}

	public func map(_ mapping: @escaping MutatingMapping<ChunkType>) -> ReadableStream<ChunkType> {
		let mapped: Stream<ChunkType> = Stream()
		_ = self.subscribe { data in
			var mutableData = data
			mapping(&mutableData)
			mapped.publish(mutableData)
		}
		addDownstreamDisposable(mapped)
		return ReadableStream(mapped)
	}

	public func map<T>(_ mapping: @escaping MutatingOneToOneMapping<ChunkType, T>) -> ReadableStream<T> {
		let mapped: Stream<T> = Stream()
		_ = self.subscribe { data in
			var mutableData = data
			mapped.publish(mapping(&mutableData))
		}
		addDownstreamDisposable(mapped)
		return ReadableStream(mapped)
	}
}

internal class ManyToOneMappingStream<S, T> : Stream<T>
{
	internal init(_ map: @escaping ManyToOneMapping<S, T>) {
		_map = map
	}

	internal func accumulate(_ data: S) {
		_accumulator.append(data)
		let (result, leftovers) = _map(_accumulator)
		_accumulator = leftovers
		if (result != nil) {
			publish(result!)
		}
	}

	var _accumulator: [S] = []
	var _map: ManyToOneMapping<S, T>
}
