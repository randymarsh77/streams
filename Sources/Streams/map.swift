public typealias OneToOneMapping<S, T> = (S) -> T

public typealias ManyToOneMapping<S, T> = ([S]) -> (T?, [S])

public typealias OneToManyMapping<S, T> = (S) -> [T]

public typealias MutatingMapping<S> = (_: inout S) -> Void

public typealias MutatingOneToOneMapping<S, T> = (_: inout S) -> T

extension IReadableStream {
	public func map<T>(_ mapping: @escaping OneToOneMapping<ChunkType, T>) -> ReadableStream<T> {
		configureDisposal(Stream()) { mapped in
			self.subscribe { data in
				mapped.publish(mapping(data))
			}
		}
	}

	public func map<T>(_ mapping: @escaping ManyToOneMapping<ChunkType, T>) -> ReadableStream<T> {
		configureDisposal(ManyToOneMappingStream(mapping)) { mapped in
			self.subscribe { data in
				mapped.accumulate(data)
			}
		}
	}

	public func map<T>(_ mapping: @escaping OneToManyMapping<ChunkType, T>) -> ReadableStream<T> {
		configureDisposal(Stream()) { mapped in
			self.subscribe { data in
				let many = mapping(data)
				for item in many {
					mapped.publish(item)
				}
			}
		}
	}

	public func map(_ mapping: @escaping MutatingMapping<ChunkType>) -> ReadableStream<ChunkType> {
		configureDisposal(Stream()) { mapped in
			self.subscribe { data in
				var mutableData = data
				mapping(&mutableData)
				mapped.publish(mutableData)
			}
		}
	}

	public func map<T>(_ mapping: @escaping MutatingOneToOneMapping<ChunkType, T>)
		-> ReadableStream<T>
	{
		configureDisposal(Stream()) { mapped in
			self.subscribe { data in
				var mutableData = data
				mapped.publish(mapping(&mutableData))
			}
		}
	}
}

internal class ManyToOneMappingStream<S, T>: Stream<T> {
	internal init(_ map: @escaping ManyToOneMapping<S, T>) {
		_map = map
	}

	internal func accumulate(_ data: S) {
		_accumulator.append(data)
		let (result, leftovers) = _map(_accumulator)
		_accumulator = leftovers
		if result != nil {
			publish(result!)
		}
	}

	var _accumulator: [S] = []
	var _map: ManyToOneMapping<S, T>
}
