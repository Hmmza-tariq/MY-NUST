#!/usr/bin/env ruby
# Usage: ruby tool/check_android_native.rb path/to/app-release.aab path/to/llvm-readelf
require 'open3'
require 'tmpdir'
artifact, readelf = ARGV
abort 'Provide an AAB/APK and llvm-readelf path' unless artifact && readelf
artifact = File.expand_path(artifact)
Dir.mktmpdir('mynust-native-') do |directory|
  output, status = Open3.capture2e('unzip', '-q', artifact, '*lib/arm64-v8a/*.so', '*lib/x86_64/*.so', '-d', directory)
  abort output unless status.success?
  files = Dir.glob("#{directory}/**/*.so")
  abort 'No native libraries found' if files.empty?
  files.each do |file|
    output, status = Open3.capture2e(readelf, '-l', '-n', file)
    abort output unless status.success?
    loads = output.lines.select { |line| line.strip.start_with?('LOAD ') }
    abort "Bad LOAD alignment: #{file}" if loads.empty? || loads.any? { |line| line.split.last.to_i(16) < 16384 }
    if File.basename(file) == 'libdatastore_shared_counter.so'
      abort "Counter still uses an older NDK: #{file}" unless output.include?('72 32 38 63')
      puts "#{File.basename(File.dirname(file))}: counter NDK r28c, 16 KB aligned"
    end
  end
  puts "PASS: #{files.length} 64-bit native libraries have 16 KB LOAD alignment"
end
