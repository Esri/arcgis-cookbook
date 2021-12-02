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
  def self.copy(src, dst, prefix = '')
    dst.each do |key, value|
      key_path = prefix + '.' + key
      unless @ignored.include? key_path
        if (value.class == Hash) && (!@complex.include? key_path)
          # Call Attributes.copy recursively.
          copy src[key], value, key_path
        elsif !src[key].nil? && (value != src[key])
          # Copy the modified value from src to dst attribute.
          dst[key] = src[key]
          puts "#{key_path} -> #{src[key].to_json}"
        end
      end
    end
  end
end

if ARGV.length < 2
  puts 'Copies attributes from source to destination JSON file.'
  puts 'Only attributes defined in the destination JSON file are copied.'
  puts 'Usage: chef-apply copy_attributes.rb <source file> <destination file>'
  exit 1
else
  src_file = ARGV[1]
  dst_file = ARGV[2]

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

  Attributes.copy src_attrs, dst_attrs

  ::File.write dst_file, JSON.pretty_generate(dst_attrs)

  puts "File '#{dst_file}' is updated."
end
