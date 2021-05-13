# ffmpeg_api

A flutter package that encode video to h264 type using [flutter_ffmpeg](https://pub.dev/packages/flutter_ffmpeg) "min-gpl" package. 

## Getting Started

### Installation

Add `ffmpeg_api` as a dependency in your `pubspec.yaml file`.
  ```
dependencies:
    flutter_ffmpeg:
      git:
        url: git://github.com/hyobbb/flutter_ffmpeg_api.git
  ```

##### Android

- Edit `android/build.gradle` file and specify the package name in `ext.flutterFFmpegPackage` variable.

    ```
    ext {
        flutterFFmpegPackage  = "min-gpl"
    }

    ```
##### iOS (Flutter >= 2.x)

- Edit `ios/Podfile`, add the following block **before** `target 'Runner do` :

    ```
    # "fork" of method flutter_install_plugin_pods (in fluttertools podhelpers.rb) to get lts version of ffmpeg
    def flutter_install_plugin_pods(application_path = nil, relative_symlink_dir, platform)
      # defined_in_file is set by CocoaPods and is a Pathname to the Podfile.
      application_path ||= File.dirname(defined_in_file.realpath) if self.respond_to?(:defined_in_file)
      raise 'Could not find application path' unless application_path

      # Prepare symlinks folder. We use symlinks to avoid having Podfile.lock
      # referring to absolute paths on developers' machines.

      symlink_dir = File.expand_path(relative_symlink_dir, application_path)
      system('rm', '-rf', symlink_dir) # Avoid the complication of dependencies like FileUtils.

      symlink_plugins_dir = File.expand_path('plugins', symlink_dir)
      system('mkdir', '-p', symlink_plugins_dir)

      plugins_file = File.join(application_path, '..', '.flutter-plugins-dependencies')
      plugin_pods = flutter_parse_plugins_file(plugins_file, platform)
      plugin_pods.each do |plugin_hash|
        plugin_name = plugin_hash['name']
        plugin_path = plugin_hash['path']
        if (plugin_name && plugin_path)
          symlink = File.join(symlink_plugins_dir, plugin_name)
          File.symlink(plugin_path, symlink)

          if plugin_name == 'flutter_ffmpeg'
            pod 'flutter_ffmpeg/min-gpl', :path => File.join(relative_symlink_dir, 'plugins', plugin_name, platform)
          else
            pod plugin_name, :path => File.join(relative_symlink_dir, 'plugins', plugin_name, platform)
          end
        end
      end
    end
    ```