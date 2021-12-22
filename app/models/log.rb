class Log < ApplicationRecord
  def props
    # '24.6.96.54 - - [09/Jan/2021:20:38:56 0000] "GET /packs/js/application-1a4310e423af5baaf2ff.js HTTP/1.1" 304 0 "https://awklog.com/?2" "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_1_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.88 Safari/537.36"'
    pieces = raw.scan(/([\d\.]*?) \- (.*?) \[(.*?)\] "(.*)" (\d+?) (\d+?) "(.*?)" "(.*?)"/)[0]
    return {raw: raw} if !pieces || pieces.size < 7
    request_method = pieces[3].scan(/^([A-Z]+)/)[0][0]
    request_path = pieces[3].scan(/^[A-Z]+ ([^\s]+) /)[0][0]
    {
      remote_ip: pieces[0],
      remote_user: pieces[1],
      time_local: DateTime.strptime(pieces[2], '%d/%b/%Y:%H:%M:%S'),
      request: pieces[3],
      method: request_method,
      path: request_path,
      status: pieces[4].to_i,
      bytes_sent: pieces[5].to_i,
      http_referer: pieces[6],
      http_user_agent: pieces[7],
    }
  end

  def parse_ua(str)
    ua = UserAgent.parse(str).map do |x|
      {
        product: x.product,
        version: x.version.to_s.to_f,
        comments: x.comment,
      }
    end
    ua
  end

  def index
    body = props
    body[:log_id] = self.id
    body[:user_id] = begin
      User.find_by(api_key: self.api_key).id
    rescue
    end
    body[:created_at] = self.created_at
    begin
      body[:top] = parse_top
    rescue
    end
    body[:host_ip] = self.host_ip
    body[:hostname] = self.hostname
    $es_client.index index: 'logs', type: 'log', id: self.id, body: body
  end

  def parse_top
#     top = <<-ENDL
# top - 04:20:24 up 3 days, 11:07,  1 user,  load average: 0.00, 0.03, 0.06
# Tasks: 111 total,   1 running, 110 sleeping,   0 stopped,   0 zombie
# %Cpu(s):  3.2 us,  0.0 sy,  0.0 ni, 96.8 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
# MiB Mem :   3935.4 total,    784.7 free,    720.6 used,   2430.1 buff/cache
# MiB Swap:      0.0 total,      0.0 free,      0.0 used.   2922.4 avail Mem
# ENDL
    parser = []
    parser << [
      {regex: '(\d+\:\d+\:\d+) up', name: :time, to: :to_s},
      {regex: 'up ([0-9,\:]+)', name: :up, to: :to_s},
      {regex: ' ([0-9,\:]+)\,', name: :up_hours, to: :to_s},
      {regex: ' (\d+) days', name: :up_days},
      {regex: '(\d+) user', name: :users},
      {regex: 'load average: (\d+\.\d+)\, \d+\.\d+\, \d+\.\d+', name: :load_average1, to: :to_f},
      {regex: 'load average: \d+\.\d+\, (\d+\.\d+)\, \d+\.\d+', name: :load_average2, to: :to_f},
      {regex: 'load average: \d+\.\d+\, \d+\.\d+\, (\d+\.\d+)', name: :load_average3, to: :to_f},
    ]
    parser << [
      {regex: '(\d+) total', name: :total},
      {regex: '(\d+) running', name: :running},
      {regex: '(\d+) sleeping', name: :sleeping},
      {regex: '(\d+) stopped', name: :stopped},
      {regex: '(\d+) zombie', name: :zombie},
    ]
    parser << [
      {regex: '(\d+\.\d) us', name: :us, to: :to_f},
      {regex: '(\d+\.\d) sy', name: :sy, to: :to_f},
      {regex: '(\d+\.\d) ni', name: :ni, to: :to_f},
      {regex: '(\d+\.\d) id', name: :id, to: :to_f},
      {regex: '(\d+\.\d) wa', name: :wa, to: :to_f},
      {regex: '(\d+\.\d) hi', name: :hi, to: :to_f},
      {regex: '(\d+\.\d) si', name: :si, to: :to_f},
      {regex: '(\d+\.\d) st', name: :st, to: :to_f},
    ]
    parser << [
      {regex: '(\d+) total', name: :mem_total},
      {regex: '(\d+) used', name: :mem_used},
      {regex: '(\d+) free', name: :mem_free},
      {regex: '(\d+) buffers', name: :buffers},
      {regex: '(\d+) buff\/cache', name: :buff_cache},
    ]
    parser << [
      {regex: '(\d+) total', name: :swap_total},
      {regex: '(\d+) used', name: :swap_used},
      {regex: '(\d+) free', name: :swap_free},
      {regex: '(\d+) cached Mem', name: :cached_mem},
      {regex: '(\d+) avail Mem', name: :avail_mem},
    ]
    result = {}
    top.split("\n").each_with_index do |line, i|
      result.merge! parse_top_line(parser[i], line)
    end
    result
  end

  def parse_top_line(parser, line)
    result = {}
    parser.each do |prop|
      result[prop[:name]] = line.scan(/#{prop[:regex]}/)[0][0] rescue nil
      result[prop[:name]] = result[prop[:name]].send(prop[:to] ? prop[:to] : :to_i) rescue result[prop[:name]]
    end
    result
  end
end
