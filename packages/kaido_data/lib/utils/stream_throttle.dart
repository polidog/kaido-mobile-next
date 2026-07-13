import 'dart:async';

/// Rate-limits a stream: the first event is emitted immediately, then at
/// most one event per [interval], always using the latest value received
/// (trailing edge). Used to tame high-frequency sensor streams (compass,
/// GPS) that would otherwise trigger work on every reading.
StreamTransformer<T, T> throttleLatest<T>(Duration interval) {
  return StreamTransformer<T, T>.fromBind((source) {
    late StreamController<T> controller;
    StreamSubscription<T>? subscription;
    Timer? timer;
    T? pending;
    var hasPending = false;
    var done = false;

    void flushPending() {
      timer = null;
      if (done) return;
      if (hasPending) {
        final value = pending as T;
        hasPending = false;
        pending = null;
        controller.add(value);
        timer = Timer(interval, flushPending);
      }
    }

    controller = StreamController<T>(
      onListen: () {
        subscription = source.listen(
          (event) {
            if (timer == null) {
              controller.add(event);
              timer = Timer(interval, flushPending);
            } else {
              pending = event;
              hasPending = true;
            }
          },
          onError: controller.addError,
          onDone: () {
            done = true;
            timer?.cancel();
            unawaited(controller.close());
          },
        );
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () {
        done = true;
        timer?.cancel();
        return subscription?.cancel();
      },
    );
    return controller.stream;
  });
}
