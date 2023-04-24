require 'json'

# Utility class for processing ArcGIS Chef cookbooks attributes
class Attributes
  # Attributes that must not be changed.
  @ignored = [
    '.run_list',
    '.arcgis.version',
    '.java.version',
    '.java.tarball_path',
    '.tomcat.version',
    '.tomcat.tarball_path',
    '.tomcat.install_path',
    '.arcgis.web_server.webapp_dir'
  ]

  # Attributes of complex types that must be copied entirely.
  @complex = [
    '.arcgis.server.system_properties',
    '.arcgis.portal.system_properties',
    '.arcgis.fileserver.directories',
    '.arcgis.fileserver.shares'
  ]

  # Recursively updates values of dst attributes using values of src attributes.
  def self.copy(src, dst, add_new, prefix = '')
    src.each do |key, value|
      key_path = prefix + '.' + key
      unless @ignored.include? key_path
        if (value.class == Hash) && (!@complex.include? key_path)
          if !dst[key].nil? || add_new
            # Call Attributes.copy recursively.
            if dst[key].nil?
              dst[key] = {}
            end  
            copy value, dst[key], add_new, key_path
          end
        elsif value != dst[key]
          # Copy the modified value from src to dst attribute.
          if !dst[key].nil? || add_new 
            dst[key] = value
            if key_path.include?('password')
              puts "#{key_path} -> \"*****\""
            else
              puts "#{key_path} -> #{value.to_json}"
            end
          end
        end
      end
    end
  end
end

if ARGV.length < 2
  puts 'Copies attributes from source to destination JSON file.'
  puts 'Usage: chef-apply copy_attributes.rb <source file> <destination file> [(false|true)]'
  puts 'If the last parametr is not set or set to false, only attributes defined in the destination JSON file are copied.'
  exit 1
else
  src_file = ARGV[1]
  dst_file = ARGV[2]
  add_new = ARGV.length > 2 && ARGV[3] == 'true' ? true : false

  unless ::File.exist?(src_file)
    puts "File '#{src_file}' does not exist."
    exit 1
  end

  unless ::File.exist?(dst_file)
    puts "File '#{dst_file}' does not exist."
    exit 1
  end

  src_attrs = JSON.parse(::File.read(src_file))
  dst_attrs = JSON.parse(::File.read(dst_file))

  Attributes.copy src_attrs, dst_attrs, add_new

  ::File.write dst_file, JSON.pretty_generate(dst_attrs)

  puts "File '#{dst_file}' is updated."
end
