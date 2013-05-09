desc 'Update the database with newer records'
task :getNewRecords => :environment do
	require 'open-uri'
	open("#{Rails.root}/db/Map__Crime_Incidents_-_Previous_Three_Months.csv", 'wb') do |file|
  	file << open('http://data.sfgov.org/api/views/gxxq-x39z/rows.csv?accessType=DOWNLOAD').read
	end

	require 'csv'
	include ApplicationHelper

	csv_text = File.read("#{Rails.root}/db/Map__Crime_Incidents_-_Previous_Three_Months.csv")
	csv = CSV.parse(csv_text, :headers => true)

	csv.each_with_index do |crime, index|
	puts index
      Crime.create(:incidntnum => crime["IncidntNum"],
                   :category   => crime["Category"],
                   :descript   => crime["Descript"],
                   :dayofweek  => crime["DayOfWeek"],
                   :date       => DateTime.strptime(crime["Date"], "%m/%d/%Y %I:%M:%S %p %z").to_i,
                   :time       => mins_since_midnight(crime["Time"]),
                   :pddistrict => crime["PdDistrict"],
                   :resolution => crime["Resolution"],
                   :address    => crime["Address"],
                   :latitude   => crime["Location"].split(', ')[0].gsub(/\(/, ''),
                   :longitude  => crime["Location"].split(', ')[1].gsub(/\)/, '')
                   )
	end
	puts "#{csv.length}"
end

task :getTweets =>:environment do 
      require 'net/http'
      require 'uri'
      require 'rubygems'
      require 'nokogiri'

      def open(url)
        Net::HTTP.get(URI.parse(url))
      end

      page_content = open('http://search.twitter.com/search.json?q=SafeSF')
      parsed_page_content = JSON.parse(page_content)
      results = parsed_page_content["results"]
      id_array = []

      for i in 0..results.length-1
            id_array << results[i]["geo"]["coordinates"]
      end
end