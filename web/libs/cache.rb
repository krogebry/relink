module DevOps
  ## Simple file-based cache handler.
  class Cache
    CACHE_TYPE_FILE = :file
    FS_CACHE_DIR = File.join('/', 'tmp', 'devops', 'cache')

    CACHE_EXPIRE = 3600

    def initialize
      init_cache
    end

    def init_cache
      FileUtils.mkdir_p FS_CACHE_DIR
    end

    def del_key(key)
      system(format('rm -rf %s', File.join(FS_CACHE_DIR, key)))
    end

    def self.flush
      system(format('rm -rf %s/*', FS_CACHE_DIR))
    end

    def cached(key)
      fs_cache_file = File.join(FS_CACHE_DIR, key)
      FileUtils.mkdir_p(File.dirname(fs_cache_file)) unless File.exist?(File.dirname(fs_cache_file))
      if File.exist?(fs_cache_file)
        s = File::Stat.new(fs_cache_file)
        ctime = s.ctime
        delta = Time.new.to_f - ctime.to_f
        if delta > CACHE_EXPIRE
          LOG.debug(format('Expiring cache: %.2f', delta).yellow)
          del_key key
        end
      end

      if File.exist?(fs_cache_file)
        data = File.read(fs_cache_file)
      else
        LOG.debug(format('Getting from source: %s', key).yellow)
        data = yield
        File.open(fs_cache_file, 'w') do |f|
          f.puts data
        end
      end
      data
    end

    def set(key, data)
      fs_cache_file = File.join(FS_CACHE_DIR, key)
      File.open(fs_cache_file, 'w') do |f|
        f.puts data
      end
    end

    def cached_json(key)
      fs_cache_file = File.join(FS_CACHE_DIR, key)
      FileUtils.mkdir_p(File.dirname(fs_cache_file)) unless File.exist?(File.dirname(fs_cache_file))

      if File.exist?(fs_cache_file)
        s = File::Stat.new(fs_cache_file)
        ctime = s.ctime
        delta = Time.new.to_f - ctime.to_f
        if delta > CACHE_EXPIRE
          LOG.debug(format('Expiring cache: %.2f', delta).yellow)
          del_key key
        end
      end

      if File.exist?(fs_cache_file)
        data = File.read(fs_cache_file)

      else
        LOG.debug(format('Getting from source: %s', key).yellow)
        data = yield
        File.open(fs_cache_file, 'w') do |f|
          f.puts data
        end

      end

      begin
        JSON.parse(data)
      rescue JSON::ParserError
        return {}
      end
    end
  end
end
