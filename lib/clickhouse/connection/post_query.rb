module Clickhouse
  class Connection
    # By default Clickhouse uses GET request for query, but it has limitation for length on server side.
    # So we will allow to use POST request with query in a body.
    module PostQuery

      def post_query(query)
        query = Utils.extract_format(query)[0]
        query += ' FORMAT JSONCompact'
        parse_data post(nil, query)
      end

      def select_rows(options)
        post_query to_select_query(options)
      end

      def request(method, query, body = nil)
        raise ArgumentError, 'when query is omitted body must be passed' if query.nil? && body.nil?

        connect!
        body = body.strip unless body.nil?
        query = query.strip unless query.nil?

        start = Time.now

        headers = { 'Content-Type' => 'text/plain' }
        response = client.send(method, path(query), body, headers)
        status = response.status
        duration = Time.now - start
        if query.nil?
          query, format = Utils.extract_format(body)
        else
          query, format = Utils.extract_format(query)
        end
        response = parse_body(format, response.body)
        stats = parse_stats(response)

        write_log duration, query, stats
        raise QueryError, "Got status #{status} (expected 200): #{response}" unless status == 200
        response
      rescue Faraday::Error => e
        raise ConnectionError, e.message
      end

    end
  end
end
