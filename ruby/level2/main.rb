require 'json'
require 'date'

# Load the data from the input file
def read_json_file(file_path)
  JSON.parse(File.read(file_path))

  rescue Errno::ENOENT
    puts "The file doesn't exist."
    exit
  rescue JSON::ParserError
    puts "The file is not a valid JSON file."
    exit
end

# Calculate the total price for each rental
def calculate_total_price(start_date, end_date, distance, car)
  days_rented = (Date.parse(end_date) - Date.parse(start_date)).to_i + 1
  days_rented * car['price_per_day'] + distance * car['price_per_km']
end

# Generate the result to be written in the output file
def generate_result(cars, rentals)
  result = { "rentals" => [] }

  rentals.each do |rental|
    car = cars.find { |car| car['id'] == rental['car_id'] }
    total_price = calculate_total_price(rental['start_date'], rental['end_date'], rental['distance'], car)

    result["rentals"] << { "id" => rental['id'], "price" => total_price }
  end
  result
end

# MAIN
def main
  file_path = './data/input.json'
  data = read_json_file(file_path)
  cars = data['cars']
  rentals = data['rentals']
  result = generate_result(cars, rentals)

  puts JSON.pretty_generate(result)
end

main
