class IspSnitch < Formula
  desc "Lightweight ISP service monitor for macOS"
  homepage "https://github.com/isp-snitch/isp-snitch"
  url "https://github.com/isp-snitch/isp-snitch/archive/refs/heads/main.tar.gz"
  sha256 "placeholder-sha256-will-be-updated"
  license "MIT"
  version "1.0.0"
  
  depends_on "swift" => :build
  depends_on "sqlite"
  
  # Optional dependencies for enhanced testing
  depends_on "speedtest-cli" => :recommended
  depends_on "curl" => :recommended
  depends_on "bind" => :recommended
  
  def install
    # Build the application
    system "swift", "build", "--configuration", "release"
    
    # Install the binary
    bin.install ".build/release/isp-snitch"
    
    # Install configuration files
    etc.install "config/config.json" => "isp-snitch/config.json" if File.exist?("config/config.json")
    etc.install "config/targets.json" => "isp-snitch/targets.json" if File.exist?("config/targets.json")
    
    # Create data directories
    (var/"isp-snitch").mkpath
    (var/"isp-snitch/data").mkpath
    (var/"isp-snitch/logs").mkpath
    (var/"isp-snitch/backups").mkpath
    (var/"isp-snitch/exports").mkpath
    
    # Create log directory
    (var/"log/isp-snitch").mkpath
    
    # Install LaunchAgent
    (prefix/"Library/LaunchAgents").install "Resources/com.isp-snitch.monitor.plist"
    
    # Install service management scripts
    (prefix/"Scripts").install "Scripts/install-service.sh"
    (prefix/"Scripts").install "Scripts/uninstall-service.sh"
    (prefix/"Scripts").install "Scripts/start-service.sh"
    (prefix/"Scripts").install "Scripts/stop-service.sh"
    (prefix/"Scripts").install "Scripts/health-check.sh"
    (prefix/"Scripts").install "Scripts/resource-monitor.sh"
    (prefix/"Scripts").install "Scripts/setup-directories.sh"
    (prefix/"Scripts").install "Scripts/test-service.sh"
    
    # Make scripts executable
    chmod 0755, Dir[prefix/"Scripts/*.sh"]
  end
  
  def post_install
    # Set up directories with proper permissions
    system "#{prefix}/Scripts/setup-directories.sh"
    
    # Load LaunchAgent
    system "launchctl", "load", "#{prefix}/Library/LaunchAgents/com.isp-snitch.monitor.plist"
    
    # Start the service
    system "launchctl", "start", "com.isp-snitch.monitor"
    
    # Wait a moment for service to start
    sleep 2
    
    # Verify service is running
    if system("launchctl", "list", "com.isp-snitch.monitor", out: File::NULL, err: File::NULL)
      ohai "ISP Snitch service started successfully!"
      ohai "Web interface available at: http://localhost:8080"
      ohai "Service management scripts available in: #{prefix}/Scripts/"
    else
      opoo "Service may not have started properly. Check logs: tail -f #{var}/log/isp-snitch/error.log"
    end
  end
  
  def uninstall
    # Stop and unload LaunchAgent
    system "launchctl", "stop", "com.isp-snitch.monitor"
    system "launchctl", "unload", "#{prefix}/Library/LaunchAgents/com.isp-snitch.monitor.plist"
    
    # Remove LaunchAgent file
    rm_f "#{prefix}/Library/LaunchAgents/com.isp-snitch.monitor.plist"
    
    # Remove service management scripts
    rm_rf "#{prefix}/Scripts"
  end
  
  service do
    run [opt_bin/"isp-snitch", "start", "--background"]
    working_dir var/"isp-snitch"
    log_path var/"log/isp-snitch/out.log"
    error_log_path var/"log/isp-snitch/error.log"
    environment_variables({
      "ISP_SNITCH_CONFIG" => etc/"isp-snitch/config.json",
      "ISP_SNITCH_DATA" => var/"isp-snitch/data"
    })
  end
  
  test do
    # Test binary execution
    assert_match "ISP Snitch", shell_output("#{bin}/isp-snitch --help")
    
    # Test CLI commands
    assert_match "status", shell_output("#{bin}/isp-snitch status --help")
    assert_match "config", shell_output("#{bin}/isp-snitch config --help")
    assert_match "report", shell_output("#{bin}/isp-snitch report --help")
    assert_match "service", shell_output("#{bin}/isp-snitch service --help")
    
    # Test service management scripts
    assert_predicate prefix/"Scripts/install-service.sh", :executable?
    assert_predicate prefix/"Scripts/uninstall-service.sh", :executable?
    assert_predicate prefix/"Scripts/start-service.sh", :executable?
    assert_predicate prefix/"Scripts/stop-service.sh", :executable?
    assert_predicate prefix/"Scripts/health-check.sh", :executable?
    assert_predicate prefix/"Scripts/resource-monitor.sh", :executable?
  end
end
