# frozen_string_literal: true

require 'bundler'
Bundler.require

get '/' do
  'Hi'
end

def latest_amesh
  date = RestClient.get('https://tokyo-ame.jwa.or.jp/scripts/mesh_index.js').body.chomp.chomp
                   .sub('Amesh.setIndexList(', '').sub(');', '').split('"')[1]
  url = "https://tokyo-ame.jwa.or.jp/mesh/050/#{date}.gif"
  Magick::Image.from_blob(RestClient.get(url).body).first
end

def amesh
  map = Magick::Image.from_blob(RestClient.get('https://tokyo-ame.jwa.or.jp/map/map050.jpg').body).first
  mask = Magick::Image.from_blob(RestClient.get('https://tokyo-ame.jwa.or.jp/map/msk050.png').body).first

  map.composite!(latest_amesh, Magick::SouthWestGravity, Magick::OverCompositeOp)
  map.composite!(mask, Magick::SouthWestGravity, Magick::OverCompositeOp)
  map.to_blob
end

get '/amesh.png' do
  content_type :png

  amesh
end

get '/gyazosh' do
  content_type :text
  b = Tempfile.new('a.png')
  b.write amesh
  gyazo_token = params[:token]
  gyazo = Gyazo::Client.new(access_token: gyazo_token)
  gyazo.upload(imagefile: b.path)[:permalink_url]
end
