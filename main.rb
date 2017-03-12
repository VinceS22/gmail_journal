class Main
  require 'rubygems'
  require 'json'
  require 'gmail'
  require 'highline'

  def self.main(debug=false)
    file_name = debug ? 'developmentSettings.json' : 'settings.json'

    file = File.open(file_name, 'r')
    data = file.read
    file.close

    json = JSON.parse(data)


    username = json['gmail_account_info']['username']
    password = json['gmail_account_info']['password']


    if json['query_account_info']
      cli = HighLine.new

      puts 'You chose to not store account info, please enter your user account info'
      puts 'Username: '
      username = gets.chomp

      password = cli.ask('Password: ') do |q|
        q.echo = false
      end
    else
      verify_json(json, debug)
    end

    if debug
      puts 'attempting login U: ' + username + ' p: ' + password
    end

    Gmail.connect!(username,password) do |gmail|
      if debug
        if gmail.logged_in?
          puts 'Logged in successfully!'
        else
          puts 'Log in failed!'
        end
      end

      gmail.inbox.find(:unread).each do |email|
        puts email.subject

        puts email.message
      end
    end
  end

  def self.verify_json(json, debug)
    if debug
      puts 'calling verify'
    end

      if json['gmail_account_info']['username'].to_s.empty?
        raise 'query_account_info  is true but gmail_account_info username is empty'
      end
      if json['gmail_account_info']['password'].to_s.empty?
        raise 'query_account_info  is true but gmail_account_info password is empty'
      end
  end
end

Main.main(true)