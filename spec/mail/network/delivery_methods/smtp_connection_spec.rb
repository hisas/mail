# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

describe "SMTP Delivery Method" do

  before(:each) do
    Mail.defaults do
      smtp = Net::SMTP.start('127.0.0.1', 25)
      delivery_method :smtp_connection, :connection => smtp
    end
  end

  after(:each) do
    Mail.delivery_method.smtp.finish
  end

  it "should send an email using open SMTP connection" do
    mail = Mail.deliver do
      from    'roger@test.lindsaar.net'
      to      'marcel@test.lindsaar.net, bob@test.lindsaar.net'
      subject 'invalid RFC2822'

      smtp_envelope_from 'smtp_from'
      smtp_envelope_to 'smtp_to'
    end

    expect(MockSMTP.deliveries[0][0]).to eq mail.encoded
    expect(MockSMTP.deliveries[0][1]).to eq 'smtp_from'
    expect(MockSMTP.deliveries[0][2]).to eq %w(smtp_to)
  end

  it "should be able to return actual SMTP protocol response" do
    Mail.defaults do
      smtp = Net::SMTP.start('127.0.0.1', 25)
      delivery_method :smtp_connection, :connection => smtp, :port => 587, :return_response => true
    end

    mail = Mail.deliver do
      from    'roger@moore.com'
      to      'marcel@amont.com'
      subject 'invalid RFC2822'
    end

    response = mail.deliver!
    expect(response).to eq 'OK'

  end


  it "should raise an error if no sender is defined" do
    Mail.defaults do
      smtp = Net::SMTP.start('127.0.0.1', 25)
      delivery_method :smtp_connection, :connection => smtp, :port => 587, :return_response => true
    end

    expect do
      Mail.deliver do
        to "to@somemail.com"
        subject "Email with no sender"
        body "body"
      end
    end.to raise_error('SMTP From address may not be blank: nil')
  end

  it "should raise an error if no recipient if defined" do
    Mail.defaults do
      smtp = Net::SMTP.start('127.0.0.1', 25)
      delivery_method :smtp_connection, :connection => smtp, :port => 587, :return_response => true
    end

    expect do
      Mail.deliver do
        from "from@somemail.com"
        subject "Email with no recipient"
        body "body"
      end
    end.to raise_error('SMTP To address may not be blank: []')
  end
end
