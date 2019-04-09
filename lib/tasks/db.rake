namespace 'db' do
  task 'preinstall' do
    plugins = File.readlines('/shared/tmp/procourse-installer/plugins.txt') if File.exist?('/shared/tmp/procourse-installer/plugins.txt')
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
