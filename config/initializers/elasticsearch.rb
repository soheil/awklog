es = {
  host: '35.225.96.254:19100',
  transport_options: {
    request: { timeout: 90 }
  },
  log: false
}

$es_client = Elasticsearch::Client.new(es)
