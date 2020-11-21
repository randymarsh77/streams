import IDisposable

internal extension IReadableStream
{
	func configureDisposal<S, T>(_ mapped: S, _ subscribe: (_ mapped: S) throws -> IDisposable) rethrows -> ReadableStream<T> where S: Stream<T> {
		addDownstreamDisposable(mapped)
		mapped.addUpstreamDisposable(self)

		return ReadableStream(mapped)
			.disposeWith(try subscribe(mapped))
	}
}
