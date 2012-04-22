require "tropo-webapi-ruby"

class TropoApp < Sinatra::Base

  enable :sessions

  helpers do

    def tropo_object
      t = Tropo::Generator.new do
        on :event => 'error', :next => '/tropo/error.json'
        on :event => 'hangup', :next => '/tropo/hangup.json'
      end
    end

    def construct_welcome_message(product_name, msg)
      options = {
        :name => 'take_survey',
        :timeout => 60,
        :say => { :value => "Welcome to #{product_name} survey. #{product_name} is #{msg}. Do you want to take a quick survey? Yes or no." },
        :attempts => 3,
        :choices => { :value => "yes,no" }
      }
    end

    def construct_survey(name, question_number, msg, yes_no=true)
      question_options =  "yes,no"
      question_appender = "Say yes or no."

      unless yes_no
        question_options =  "[5 DIGITS]"
        question_appender = "Using the keypad press 1 to 5. 5 being the heighest and 1 being the lowest."
      end

      options = {
        :name => name,
        :timeout => 30,
        :say => { :value => "Question number #{question_number}. #{msg}. #{question_appender}" },
        :attempts => 3,
        :choices => { :value => question_options }
      }
    end

  end

  get '/index.json' do
    "Welcome to PhoneSurvey"
  end

  post '/index.json' do
    v = Tropo::Generator.parse request.env["rack.input"].read
    pp v

    trunk_line = v[:session][:to][:id]
    caller_id = v[:session][:from][:id]

    product = Product.find_by_tropo_number("+1#{trunk_line}")

    t = tropo_object

    t.on :event => 'continue', :next => "/tropo/survey.json&product_id=#{product.id}"
    t.ask construct_welcome_message(product.name, product.description)

    pp t.response
    t.response
  end

  post '/survey.json' do
    v = Tropo::Generator.parse request.env["rack.input"].read
    pp v

    product = Product.find(params[:product_id])
    take_survey = v[:result][:actions][:take_survey][:value]

    t = tropo_object
    question_counter = 1

    case take_survey
    when 'yes'
      t.on :event => 'continue', :next => "/tropo/results.json?product_id=#{product.id}"
      products.surveys.each do |survey|
        t.ask construct_survey("question_#{survey.id}", question_counter, survey.question, survey.yes_no)
        question_counter += 1
      end
    when 'no'
      t.say :value => "Goodbye."
    end

    pp t.response
    t.response
  end

  post '/results.json' do
    v = Tropo::Generator.parse request.env["rack.input"].read
    pp v

    product = Product.find(params[:product_id])

    products.surveys.each do |survey|
      survey_answer = v[:result][:actions]["question_#{survey.id}".to_sym][:value]
      Feedback.create(:survey_id => survey.id, :answer => survey_answer, :callerid => v[:session][:from][:id])
    end

    t = tropo_object
    t.say :value => "Thank you for you time. Goodbye."

    pp t.response
    t.response
  end

end
