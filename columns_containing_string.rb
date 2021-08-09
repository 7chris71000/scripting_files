require "csv"

# Ruby script to find all attributes in a table containing a string.
# Pre-requisite:
## a folder containing .csv files of the tables you would like to search

# Args:
## ARGV 0: relative folder path of csv table files with following /, eg: ../../Desktop/postgres_dump/
## ARGV 1: search term, eg: "Test"

# Execution Example:
## $ ruby columns_containing_string.rb ../../../Desktop/postgres_dump/ "DRÄGER"

def get_columns_of_files(folder_paths, table_csv_folder_path)
  columns_hash = {}

  folder_paths.each do |file_path|
    column_names_string = File.open(file_path, &:readline)
    csv_parse = CSV.parse(column_names_string, col_sep: ";")
    file_name = file_path.gsub(table_csv_folder_path, "")
    columns_hash[file_name] = csv_parse[0]
  end

  columns_hash
end

def get_result_column_from_search(table_csv_folder_path, file_paths, search_term)
  number_of_files = file_paths.length

  file_paths.each.with_index(1) do |file_path, index_i|
    now = Time.now
    puts "(#{index_i}/#{number_of_files}) searching #{file_path}."

    db_csv_file = CSV.read(file_path, quote_char: '"', col_sep: ";", row_sep: :auto)

    db_csv_file.each_with_index do |elem, index_j|
      elem.each_with_index do |x, index_k|
        if x != nil && x.include?(search_term)
          file_name = file_path.gsub(table_csv_folder_path, "")
          $result_columns["#{file_name}"] = [
            *$result_columns["#{file_name}"],
            find_from_columns_list(file_name, index_k),
          ].uniq
        end
      end
    end

    later = Time.now
    puts "#{later - now}s"
  end
end

def find_from_columns_list(file_name, index)
  column_name = $columns["#{file_name}"][index]
  return column_name
end

# main
total_now = Time.now
files_in_folder = Dir["#{ARGV[0]}*.csv"]
search_term = ARGV[1]
$result_columns = {}
$columns = get_columns_of_files(files_in_folder, ARGV[0])
get_result_column_from_search(ARGV[0], files_in_folder, search_term)
total_later = Time.now

puts "Total Execution #{total_later - total_now}s"
puts ""
puts $result_columns
