module SimLauncher

class Simulator

  def initialize( iphonesim_path_external = nil )
    @iphonesim_path = iphonesim_path_external || iphonesim_path
  end

  def showsdks
    run_synchronous_command( 'showsdks' )
  end

  def start_simulator()
    run_synchronous_command('fbsimctl','boot', '25A008D8-F68C-414B-9D90-671B5290BBFB')
  end


  def rotate_left
    script_dir = File.join(File.dirname(__FILE__),"..","..","scripts")
    rotate_script = File.expand_path("#{script_dir}/rotate_simulator_left.applescript")
    system("osascript #{rotate_script}")
  end

  def rotate_right
    script_dir = File.join(File.dirname(__FILE__),"..","..","scripts")
    rotate_script = File.expand_path("#{script_dir}/rotate_simulator_right.applescript")
    system("osascript #{rotate_script}")
  end

  def reset(sdks=nil)
  end

  def launch_ios_app(app_path)
    if problem = SimLauncher.check_app_path( app_path )
      bangs = '!'*80
      raise "\n#{bangs}\nENCOUNTERED A PROBLEM WITH THE SPECIFIED APP PATH:\n\n#{problem}\n#{bangs}"
    end
    run_synchronous_command('fbsimctl', 'install', app_path, '--name','--udid','25A008D8-F68C-414B-9D90-671B5290BBFB')
  end

  def launch_ipad_app( app_path, sdk )
    launch_ios_app(app_path)
  end

  def launch_ipad_app_with_name( app_name, sdk )
    app_path = SimLauncher.app_bundle_or_raise(app_name)
    launch_ios_app( app_path, sdk, 'iphone' )
  end

  def launch_iphone_app( app_path, sdk )
    launch_ios_app(app_path)
  end

  def launch_iphone_app_with_name( app_name, sdk )
    app_path = SimLauncher.app_bundle_or_raise(app_name)
    launch_ios_app(app_path)
  end

  def quit_simulator
    run_synchronous_command('fbsimctl', 'shutdown', '--udid','25A008D8-F68C-414B-9D90-671B5290BBFB')
  end

  def run_synchronous_command( *args )
    args.compact!
    cmd = cmd_line_with_args( args )
    puts "executing #{cmd}" if $DEBUG
    `#{cmd}`
  end

  def cmd_line_with_args( args )
    cmd_sections = [@iphonesim_path] + args.map{ |x| "\"#{x.to_s}\"" } << '2>&1'
    cmd_sections.join(' ')
  end

  def xcode_version
    version_out = `xcodebuild -version`
    begin
      Float(version_out[/([0-9]\.[0-9])/, 1])
    rescue => ex
      raise "Cannot determine xcode version: #{ex}"
    end
  end

  def iphonesim_path
    installed = `which ios-sim`
    if installed =~ /(.*ios-sim)/
      puts "Using installed ios-sim at #{$1}" if $DEBUG
      return $1
    end

    raise "Didn't find the ios-sim binary in your $PATH.\n\nPlease install, e.g. using Homebrew:\n\tbrew install ios-sim\n\n"
  end
end
end
