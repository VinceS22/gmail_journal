class Main
  require 'rubygems'
  require 'json'
  require 'gmail'
  require 'highline'

  # Entry point for the app
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

      gmail.inbox.emails(:unread, :format => 'minimal').each do |email|
        handle_email(email,debug)
      end
    end
  end

  # Validation of the JSON that we use for settings
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

  # So the actual message in the body of the email seems to be wrapped around a string that begins with --
  # and ends with the same string. They're on their own line so I'm going to separate it that way.
  def self.handle_email(email,debug)
    body_lines =  email.body.to_s.split("\n")
    first_line = body_lines[0]
    body_lines.slice!(0,2)
    body_end_index = get_body_end_index(body_lines, first_line)
    body_lines.slice!(body_end_index,body_lines.length.to_i)
    if debug
      puts email.subject
      puts body_lines
    else
      email.read!
    end

  end

  # Finding the matching string that is in the beginning of the body of the email message
  def self.get_body_end_index(body_array, first_line)
    index_array = body_array.map.with_index {|a, i| a == first_line ? i : nil}.compact
    if index_array.length == 0
      raise 'Second line of email end not found'
    end
    return index_array[0]-1
  end
end

Main.main(false)