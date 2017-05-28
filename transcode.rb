require 'aws'
AWS.config(:access_key_id => 'XXXXX', :secret_access_key => 'XXXXX')

pipeline_id = 'XXXXXXX'
preset_id   = 'XXXXXX'
output      = ''
key         = ''

s3    = AWS::S3.new
bin   = s3.buckets['XXXXXX-in']

transcoder = AWS::ElasticTranscoder::Client.new
jobs       = []

job = transcoder.create_job(
  pipeline_id: pipeline_id,
  input: {
    key: key,
    frame_rate: 'auto',
    resolution: 'auto',
    aspect_ratio: 'auto',
    interlaced: 'auto',
    container: 'auto'
  },
  output: {
    key: output,
    preset_id: preset_id,
    thumbnail_pattern: "", 
    rotate: '0' 
  }   
)[:job]

puts "[#{key}] Job Started: #{job[:id]}"

while tries < 1000
  response = transcoder.read_job(:id => job[:id])[:job]
  if response[:status] == "Error"
    puts "[#{key}] Transcoding Error #{response[:status_detail]}"
    break
  elsif response[:status] == "Complete"
    puts "[#{key}] Transcoding Completed in #{Time.now.to_i - done.to_i}s"
    break
  end
  tries += 1
  sleep 5
end

puts "Finished in #{Time.now.to_i - workstart.to_i}s"