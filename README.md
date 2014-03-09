# clickstream-rb

The *clickstream* gem includes a middleware
that captures users browsing sessions for Rack applications.

## Disclaimer

This is an alpha release, it is tested with Sinatra and Rails 3 only.

## Using with Rack application

*Clickstream* can be used with any Rack application,
for example with a **Sinatra** application.
If your application includes a rackup file
or uses *Rack::Builder* to construct the application pipeline, 
simply require and use as follows:

    require 'clickstream'
    use Clickstream::Capture, {
      capture: true,
      bench: true,
      api_key: 'your-private-api-key',
      logger: 'log/clickstream.log'
    }
    run app

## Using with Rails 3

In order to use, include the following in a Rails application
**Gemfile** file:

    gem 'clickstream'

**config/application.rb** file:

    require 'clickstream'
    config.middleware.insert 0, Clickstream::Capture, {
      capture: Rails.env.production?,
      api_key: 'your-private-api-key',
      logger: 'log/clickstream.log',
      filter_uri: ['admin']
    }

Check the Rack configuration:

    rake middleware

## Options

- `api_key`: the api key for authentication (mandatory)
- `api_uri`: overwrite api uri endpoint
- `capture`: set to true to collect data, default `false`
- `bench`: set to true to benchmark middleware overhead, default `false`
- `logger`: file to write logs to, default `env['rack.errors']`
- `capture_crawlers`: set to true to capture hits from crawlers, default `false`
- `crawlers`: overwrite crawlers user agent regex
- `filter_params`: array of parameters to filter, for `Rails` default to `Rails.configuration.filter_parameters`
- `filter_uri`: array of uri for which **not** to capture data

## Author

Jerome Touffe-Blin, [@jtblin](https://twitter.com/jtlbin), [http://www.linkedin.com/in/jtblin](http://www.linkedin.com/in/jtblin)

## License

clickstream-rb is copyright 2013 Jerome Touffe-Blin and contributors. It is licensed under the BSD license. See the include LICENSE file for details.

