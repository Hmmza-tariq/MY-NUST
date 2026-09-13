# DataStore counter

These three Apache-2.0 source files are from AndroidX, unchanged:
https://github.com/androidx/androidx/tree/7b98befbd845bf5bfe804a3dca2cdec0d7804087/datastore/datastore-core/src/androidMain/cpp

DataStore 1.2.1 ships a 16 KB-aligned counter whose Android note still reports NDK r20.
We compile the same JNI API with NDK 28.2 instead. The app's CMake output takes
precedence over the duplicate AAR library. Verify the packaged counter after
every AGP or DataStore update; do not assume `pickFirsts` selected the right copy.

Check both arm64-v8a and x86_64 with `llvm-readelf -l -n`: every LOAD segment
must have alignment at least 0x4000, and the Android note must report r28.
Also test a real 16 KB runtime before considering store compatibility proven.
