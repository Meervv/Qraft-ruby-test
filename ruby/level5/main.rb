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
  days_rented = (Date.parse(end_date) - Date.parse(start_date)).to_i + 1 # +1 to include the last day
  days_rented * car['price_per_day'] + distance * car['price_per_km']
end


# Add actions to the result
def generate_actions(rental_price, days_rented)
  insurance = ((rental_price * 0.3) / 2).to_i
  assistance = (days_rented * 100).to_i
  drivy = ((rental_price * 0.3).to_i - (insurance + assistance)).to_i

  [
    { "who" => "driver", "type" => "debit", "amount" => rental_price },
    { "who" => "owner", "type" => "credit", "amount" => rental_price - insurance - assistance - drivy },
    { "who" => "insurance", "type" => "credit", "amount" => insurance },
    { "who" => "assistance", "type" => "credit", "amount" => assistance },
    { "who" => "drivy", "type" => "credit", "amount" => drivy }
  ]
end

# Generate the result to be written in the output file
def generate_result(cars, rentals, options)
  result = { "rentals" => [] }

  rentals.each do |rental|
    car = cars.find { |car| car['id'] == rental['car_id'] }
    rental_price = calculate_total_price(rental['start_date'], rental['end_date'], rental['distance'], car)
    days_rented = (Date.parse(rental['end_date']) - Date.parse(rental['start_date'])).to_i + 1

    rental_options = options.select { |option| option['rental_id'] == rental['id'] }.map { |option| option['type'] }

    actions = generate_actions(rental_price, days_rented)

    result["rentals"] << {
      "id" => rental['id'],
      "price" => rental_price,
      "options" => rental_options,
      "actions" => actions
    }
  end

  result
end


# MAIN
def main
  file_path = './data/input.json'
  data = read_json_file(file_path)

  cars = data['cars']
  rentals = data['rentals']
  options = data['options']

  result = generate_result(cars, rentals, options)

  puts JSON.pretty_generate(result)
end

main
