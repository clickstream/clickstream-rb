# columbo-rb

The *columbo* gem includes a middleware
that captures users browsing sessions for Rack applications.

Tribute to [Inspector Columbo](http://www.imdb.com/title/tt1466074/)

## Disclaimer

This is an alpha release, it is tested with Sinatra and Rails 3 only.
The UI to explore sessions is in progress (ETA: 2013'Q4) therefore
there is no point using this gem at the moment.

## Using with Rack application

*Columbo* can be used with any Rack application,
for example with a **Sinatra** application.
If your application includes a rackup file
or uses *Rack::Builder* to construct the application pipeline, 
simply require and use as follows:

    require 'columbo/capture'
    use Columbo::Capture, {
      capture: true,
      bench: false,
      apy_key: 'your-private-api-key',
      logger: 'log/columbo.log'
    }
    run app

## Using with Rails 3

In order to use, include the following in a Rails application
*Gemfile* file:

    gem 'columbo'

*config/application.rb* file:

    require 'columbo/capture'
    config.middleware.insert 0, Columbo::Capture, {
      capture: Rails.env.production?,
      bench: false,
      apy_key: 'your-private-api-key',
      logger: 'log/columbo.log'
    }

Check the Rack configuration:

    rake middleware

## Author

Jerome Touffe-Blin, [@jtblin](https://twitter.com/jtlbin), [http://www.linkedin.com/in/jtblin](http://www.linkedin.com/in/jtblin)

## License

Columbo is copyright 2013 Jerome Touffe-Blin and contributors. It is licensed under the BSD license. See the include LICENSE file for details.

