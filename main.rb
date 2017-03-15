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
      verify_json(json)
    end

    handle_debug 'attempting login U: ' + username + ' p: ' + password

    Gmail.connect!(username,password) do |gmail|
        if gmail.logged_in?
          handle_debug 'Logged in successfully!'
        else
          handle_debug 'Log in failed!'
        end

      gmail.inbox.emails(:unread, :format => 'minimal').each do |email|
        handle_email(email,debug)
      end
    end
  end

  # Validation of the JSON that we use for settings
  # json: JSON containing the settings.json file contents.
  # debug: Debug flag that will use 'puts' to spit out info
  def self.verify_json(json)
      handle_debug 'calling verify'

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
    delegate_email(email.subject,body_lines)
    if debug
      # do nothing
    else
      email.read!
    end

  end

  # Finding the matching string that is in the beginning of the body of the email message
  # body_array: Array which contains line-by-line the email body
  # first_line: The first line of the body that we trim before passing array. This returns the
  # first instance of it since I didn't want to take the time to determine how many we have.
  def self.get_body_end_index(body_array, first_line)
    index_array = body_array.map.with_index {|a, i| a == first_line ? i : nil}.compact
    if index_array.length == 0
      raise 'Second line of email end not found'
    end
    return index_array[0]-1
  end

  # This is where we delegate out what to do with the email.
  # subject: A string containing the subject
  # body: Array of strings that contain the body line by line.
  def self.delegate_email(subject,body)
      if subject.downcase.include?('todo')
        add_todo(subject,body)
        found = 'To Do'
      elsif subject.to_s.downcase.include?('journal')
        add_journal(subject,body)
        found = 'Journal'
      elsif subject.downcase.include?('goal')
        add_goal(subject,body)
        found = 'Goal'
      elsif subject.downcase.include?('event')
        add_event(subject,body)
        found = 'Event'
      elsif subject.downcase.include?('idea')
        add_idea(subject,body)
        found = 'Idea'
      else
        add_edge_case(subject,body)
        found = 'Edge Case'
      end

      handle_debug(found + ' FOUND: ' + "\n" + subject + "\n" + body.join("\n"))

  end

  # I need to do something, let's do something with it
  # subject: A string containing the subject
  # body: Array of strings that contain the body line by line.
  def self.add_todo(subject, body)

  end

  # Dear Diary... adding it
  # subject: A string containing the subject
  # body: Array of strings that contain the body line by line.
  def self.add_journal(subject, body)

  end

  # Personal goal, don't know about this one, but let's think about it
  # subject: A string containing the subject
  # body: Array of strings that contain the body line by line.
  def self.add_goal(subject, body)

  end

  # This will schedule a task for my main account, this one might be pretty difficult...
  # subject: A string containing the subject
  # body: Array of strings that contain the body line by line.
  def self.add_event(subject,body)

  end

  # Got your next program idea? Thought of the next sliced bread? Add it here.
  # subject: A string containing the subject
  # body: Array of strings that contain the body line by line.
  def self.add_idea(subject,body)

  end

  # Something funky came in and I need to debug this if we're allowing logging, pretty much.
  # subject: A string containing the subject
  # body: Array of strings that contain the body line by line.
  def self.add_edge_case(subject,body)

  end


  # Right now, we're just using puts to handle a debug with str being the debug statement
  # Making it so that if we want to change that, it will be ezpz
  def self.handle_debug(str, logging_on=true)
    if logging_on
      puts str
    end
  end
end

Main.main(false)