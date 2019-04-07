namespace 'db' do
  task 'preinstall' do
    plugins = File.readlines('/shared/procourse-installer/plugins.txt') if File.exist?('/shared/procourse-installer/plugins.txt')
    puts plugins
    unless plugins.nil?
      plugins.each do |plugin| 
        begin
          sh "cd /var/www/discourse/plugins && git clone #{plugin}"
        rescue
          STDERR.puts 'Cannot clone directory'
        end
      end
    end
  end
end

Rake::Task['db:migrate'].enhance [:preinstall]
