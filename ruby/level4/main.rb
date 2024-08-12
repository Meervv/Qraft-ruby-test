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


# Calculate the commission for each rental
def calculate_commission(rental_price, days_rented)
  commission = {}

  commission['insurance_fee'] = ((rental_price * 0.3) / 2).to_i # 50% of the commission goes to the insurance
  commission['assistance_fee'] = (days_rented * 100).to_i # 1€ per day goes to the roadside assistance
  commission['drivy_fee'] = ((rental_price * 0.3) - (commission['insurance_fee'] + commission['assistance_fee'])).to_i # The rest goes to drivy

  commission
end

# Add actions to the result
def add_actions(result, rental, rental_price, insurance, assistance, drivy)
  action = []
  action << { "who" => "driver", "type" => "debit", "amount" => rental_price }
  action << { "who" => "owner", "type" => "credit", "amount" => rental_price - insurance - assistance - drivy }
  action << { "who" => "insurance", "type" => "credit", "amount" => insurance }
  action << { "who" => "assistance", "type" => "credit", "amount" => assistance }
  action << { "who" => "drivy", "type" => "credit", "amount" => drivy }

  action
end

# Generate the result to be written in the output file
def generate_result(cars, rentals)
  result = { "rentals" => [] }

  rentals.each do |rental|
    car = cars.find { |car| car['id'] == rental['car_id'] }
    total_price = calculate_total_price(rental['start_date'], rental['end_date'], rental['distance'], car)

    commission = calculate_commission(total_price, (Date.parse(rental['end_date']) - Date.parse(rental['start_date'])).to_i + 1)
    action = add_actions(result, rental, total_price, commission['insurance_fee'], commission['assistance_fee'], commission['drivy_fee'])

    result["rentals"] << { "id" => rental['id'], "actions" => action}
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