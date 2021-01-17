require 'bundler/setup'
require 'jimson'
require 'json'
require "open3"

class MyHandler
  extend Jimson::Handler 

  def shell *params
    params.collect { |param|
      c = param["command"]
      o, e, s = Open3.capture3(c, stdin_data: param["stdin"])
      json = JSON.parse(o) rescue nil 
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

