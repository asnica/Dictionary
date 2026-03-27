tmp_port = 8400  

app_dir = "/var/www/Dictionary"

pid "#{app_dir}/tmp/pids/unicorn_#{tmp_port}.pid"
stderr_path "#{app_dir}/log/unicorn_#{tmp_port}.log"
stdout_path "#{app_dir}/log/unicorn_#{tmp_port}.log"

worker_processes 2   
working_directory app_dir
listen tmp_port
timeout 4000  
preload_app true

before_fork do |server, worker|
    defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
    old_pid = "#{ server.config[:pid] }.oldbin"
    unless old_pid == server.pid
        begin
            Process.kill :QUIT, File.read(old_pid).to_i
        rescue Errno::ENOENT, Errno::ESRCH
        end
    end
end

after_fork do |server, worker|
    defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
