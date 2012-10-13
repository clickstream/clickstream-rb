# Colombo

The *colombo* gem includes a simple sinatra web server and a middleware that captures users browsing sessions
for Rack applications.

## Disclaimer

This is an early release that has not been tested in production. **Use at your own risk**


## Using with Rack application

*Colombo* can be used with any Rack application,
for example with a **Sinatra** application.
If your application includes a rackup file
or uses *Rack::Builder* to construct the application pipeline, 
simply require and use as follows:

    require 'rack/capture'
    use Rack::Capture
    run app

## Using with Rails 3

In order to use, include the following in a Rails application
*Gemfile* file:

    gem 'colombo'

*config/application.rb* file:

    require 'rack/capture'
    config.middleware.insert_before Rack::ETag, Rack::Capture

Check the Rack configuration:

    rake middleware

## Author

Jerome Touffe-Blin, [@jtblin](https://twitter.com/jtlbin), [http://www.linkedin.com/in/jtblin](http://www.linkedin.com/in/jtblin)

## License

Colombo is copyright 2012 Jerome Touffe-Blin and contributors. It is licensed under the BSD license. See the include LICENSE file for details.

