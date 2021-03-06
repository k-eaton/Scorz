require 'unirest'
require 'httparty'
require 'dotenv'

get '/' do

  erb :index
end

# post '/' do
#   @marijuana = Report.where("description LIKE ?", '%MARIJUANA%')
#   latlong = []
#   @marijuana.each do |report|
#     latlong << [report.long, report.lat]
#   end

#   content_type :json
#   {reports: latlong}.to_json
# end

get '/drugs' do
  @transport = params[:drugs].to_s
  @dealer = params[:dealers].to_s
  puts @dealer
  puts @transport
  @drugs = Report.where("description LIKE ?", '%'+@transport+'%')
  scores = {}
  if @dealer == "false"
    @drugs.each do |report|
      # if report.sale == false
        latlong = [report.long.to_f, report.lat.to_f, "#{@transport}"]
        scores[report.id.to_i] = latlong
      # end
    end
  else
    @drugs.each do |report|
      if report.sale == true
        latlong = [report.long.to_f, report.lat.to_f, "#{@transport}"]
        scores[report.id.to_i] = latlong
      end
    end
  end
  content_type :json
  scores.to_json
end

# get '/crime-data' do

# 	latitude = 37.656
# 	longitude = -122.096

#   response = Unirest.get "https://jgentes-Crime-Data-v1.p.mashape.com/crime?enddate=4%2F20%2F2015&lat="+latitude.to_s+"&long="+longitude.to_s+"&startdate=+1%2F1%2F2009",
#   headers:{
#     "X-Mashape-Key" => ENV['citizenrequest'],
#     "Accept" => "application/json"
#   }
#   @data = response.body
#   @data.each do |crime|
#   	if crime["description"].include?("DRUG")
#   		Report.create(popo_id: crime["id"],
#   									description: crime["description"],
#   									lat: crime["lat"],
#   									long: crime["long"]
#   									)
#   	end
#     if crime["description"].include?("NARCOTIC")
#       Report.create(popo_id: crime["id"],
#                     description: crime["description"],
#                     lat: crime["lat"],
#                     long: crime["long"]
#                     )
#     end
#     if crime["description"].include?("POSSESSION")
#       Report.create(popo_id: crime["id"],
#                     description: crime["description"],
#                     lat: crime["lat"],
#                     long: crime["long"]
#                     )
#     end
#   end
# 	erb :seeding
# end

get '/sf' do

  response = HTTParty.get ("http://sanfrancisco.crimespotting.org/crime-data?format=json&count=5000&type=Na&dstart=2013-01-01")

  @data = response["features"]
  @data.each do |crime|
    unless crime["properties"]["description"].to_s.include? "PARAPHERNALIA"
      if crime["properties"]["description"].to_s.include? "SALE"
        Report.create(popo_id: crime["id"],
                      description: crime["properties"]["description"],
                      lat: crime["geometry"]["coordinates"][1],
                      long: crime["geometry"]["coordinates"][0],
                      datetime: crime["properties"]["date_time"],
                      sale: true)
      else
        Report.create(popo_id: crime["id"],
                      description: crime["properties"]["description"],
                      lat: crime["geometry"]["coordinates"][1],
                      long: crime["geometry"]["coordinates"][0],
                      datetime: crime["properties"]["date_time"],
                      sale: false)
      end
    end
  end

  erb :seeding
end
