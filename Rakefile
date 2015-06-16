task :default => [:"extract:pages", :"extract:languages", :"extract:redirects", :"extract:categories", :"extract:templates", :"extract:offsets", :"extract:disambiguation"]

desc "Compile content offset computer"
task :compile do
  `ragel utils/content_offset.rl`
  `g++ -o utils/content_offset utils/content_offset.c`
end


namespace :extract do
  def extract(script,source_name,target_name,path,config)
    unless File.exist?("#{path}/#{source_name}.sql")
      `gzip -c -d #{path}/#{source_name}.sql.gz > #{path}/#{source_name}.sql`
    end
    puts `ruby ./utils/#{script}.rb -f #{path}/#{source_name}.sql -o #{path}/#{target_name}.csv -c #{config}`
    `rm #{path}/#{source_name}.sql`
  end

  desc "Extract all"
  task :all => [:"extract:pages", :"extract:languages", :"extract:redirects", :"extract:categories", :"extract:templates", :"extract:offsets"]

  path = ENV['WIKI_DATA']
  if path.nil?
    puts "WIKI_DATA has to be set"
    exit
  end
  config = ENV['WIKI_CONFIG']
  if config.nil?
    puts "WIKI_CONFIG has to be set"
    exit
  end
  desc "Extract pages"
  task :pages do
    extract("convert_pages","page","page",path,config)
  end

  desc "Extract language links"
  task :languages do
    extract("convert_langlinks","langlinks","translations",path,config)
  end

  desc "Extract redirects"
  task :redirects do
    file_name = "redirect"
    `gzip -c -d #{path}/#{file_name}.sql.gz > #{path}/#{file_name}.sql`
    puts `ruby ./utils/convert_redirects.rb -f #{path}/#{file_name}.sql -t #{path}/redirectTargetsBySource.csv -s #{path}/redirectSourcesByTarget.csv`
    `rm #{path}/#{file_name}.sql`
  end

  desc "Extract category links"
  task :categories do
    file_name = "categorylinks"
    `gzip -c -d #{path}/#{file_name}.sql.gz > #{path}/#{file_name}.sql`
    puts `ruby ./utils/convert_category_links.rb -f #{path}/#{file_name}.sql -o #{path}/`
    `rm #{path}/#{file_name}.sql`
  end

  desc "Extract templates"
  task :templates do
    extract("convert_templates","templatelinks","templates",path,config)
  end

  desc "Extract page offsets"
  task :offsets do
    file_name = "pages-articles"
    `bzip2 -d #{path}/#{file_name}.xml.bz2` if File.exist?("#{path}/#{file_name}.xml.bz2")
    puts `./utils/content_offset #{path}/#{file_name}.xml > #{path}/offsets.csv`
  end

  desc "Extract disambiguation pages"
  task :disambiguation do
    puts `./utils/find_disambiguation.rb -f #{path}/page.csv -t #{path}/templates.csv -c #{config}`
  end
end
