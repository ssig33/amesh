# frozen_string_literal: true

require 'bundler'
Bundler.require

get '/' do
  'Hi'
end

get '/amesh.png' do
  map = Magick::Image.from_blob(RestClient.get('https://tokyo-ame.jwa.or.jp/map/map050.jpg').body).first
  mask = Magick::Image.from_blob(RestClient.get('https://tokyo-ame.jwa.or.jp/map/msk050.png').body).first

  date = RestClient.get('https://tokyo-ame.jwa.or.jp/scripts/mesh_index.js').body.chomp.chomp
                   .sub('Amesh.setIndexList(', '').sub(');', '').split('"')[1]
  url = "https://tokyo-ame.jwa.or.jp/mesh/050/#{date}.gif"

  amesh = Magick::Image.from_blob(RestClient.get(url).body).first

  map.composite!(amesh, Magick::SouthWestGravity, Magick::OverCompositeOp)
  map.composite!(mask, Magick::SouthWestGravity, Magick::OverCompositeOp)

  content_type :png

  map.to_blob
end
