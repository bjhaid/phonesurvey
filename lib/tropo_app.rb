require "tropo-webapi-ruby"

class TropoApp < Sinatra::Base

  before do
    @v = Tropo::Generator.parse request.env["rack.input"].read
    @t = Tropo::Generator.new do
      on :event => 'error', :next => '/tropo/error.json'
      on :event => 'hangup', :next => '/tropo/hangup.json'
    end

  end

  helpers do

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

    ##
    # This will detect if the next action will be outbound
    #
    if @v[:session][:parameters]
      product = Product.find(@v[:session][:parameters][:product_id])
      @t.call :to => @v[:session][:parameters][:number_to_dial], :from => @v[:session][:parameters][:caller_id]
      @t.on :event => 'continue', :next => "/tropo/survey.json&product_id=#{product.id}"
      @t.ask construct_welcome_message(product.name, product.description)
    else
      trunk_line = @v[:session][:to][:id]
      product = Product.find_by_tropo_number("+1#{trunk_line}")
      @t.on :event => 'continue', :next => "/tropo/survey.json&product_id=#{product.id}"
      @t.ask construct_welcome_message(product.name, product.description)
    end

    @t.response
  end

  post '/survey.json' do
    product = Product.find(params[:product_id])
    take_survey = @v[:result][:actions][:take_survey][:value]

    question_counter = 1

    case take_survey
    when 'yes'
      @t.on :event => 'continue', :next => "/tropo/results.json?product_id=#{product.id}"
      products.surveys.each do |survey|
        @t.ask construct_survey("question_#{survey.id}", question_counter, survey.question, survey.yes_no)
        question_counter += 1
      end
    when 'no'
      @t.say :value => "Goodbye."
    end

    @t.response
  end

  post '/results.json' do
    product = Product.find(params[:product_id])

    products.surveys.each do |survey|
      survey_answer = @v[:result][:actions]["question_#{survey.id}".to_sym][:value]
      Feedback.create(:survey_id => survey.id, :answer => survey_answer, :callerid => @v[:session][:from][:id])
    end

    @t.say :value => "Thank you for you time. Goodbye."

    @t.response
  end

end
