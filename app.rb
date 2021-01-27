require 'bundler/setup'
require 'jimson'
require 'json'
require "open3"
require 'base64'

# https://github.com/djberg96/ptools/blob/master/lib/ptools.rb#L77
def binary?(s, percentage = 0.30)
  s = s.encode('US-ASCII', :undef => :replace).split(//)
  ((s.size - s.grep(" ".."~").size) / s.size.to_f) > percentage
rescue Encoding::InvalidByteSequenceError =>e
  true
end

class MyHandler
  extend Jimson::Handler 

  def shell *params
    params.collect { |param|
      c = param["command"]
      i = if param["stdin_binary"]
            Base64.decode64(param["stdin"])
          else
            param["stdin"]
          end
      o, e, s = Open3.capture3(c, stdin_data: i)

      if binary?(o)
        o = Base64.encode64(o) 
      else
        json = JSON.parse(o) rescue nil
      end
      { command: c, "stdout.json": json, stdout: o, stderr: e, status: { exitstatus: s.to_i, pid: s.pid } }
    }
  rescue =>e
    p e
    p e.backtrace
    raise
  end
end

server = Jimson::Server.new(MyHandler.new)
server.start # serve with webrick on http://0.0.0.0:8999/

