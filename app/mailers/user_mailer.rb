# frozen_string_literal: true

class UserMailer < Devise::Mailer
  layout 'mailer'

  helper :application
  helper :instance

  add_template_helper RoutingHelper

  def confirmation_instructions(user, token, **)
    @resource = user
    @token    = token
    @instance = Rails.configuration.x.local_domain

    return if @resource.disabled?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.unconfirmed_email.blank? ? @resource.email : @resource.unconfirmed_email,
           #cc: 'kerarara@gmail.com',
           subject: I18n.t(@resource.pending_reconfirmation? ? 'devise.mailer.reconfirmation_instructions.subject' : 'devise.mailer.confirmation_instructions.subject', instance: @instance),
           template_name: @resource.pending_reconfirmation? ? 'reconfirmation_instructions' : 'confirmation_instructions'
    end

    push_slack(user, token)
  end

  def reset_password_instructions(user, token, **)
    @resource = user
    @token    = token
    @instance = Rails.configuration.x.local_domain

    return if @resource.disabled?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.reset_password_instructions.subject')
    end
  end

  def password_change(user, **)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return if @resource.disabled?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.password_change.subject')
    end
  end

  def email_changed(user, **)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return if @resource.disabled?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('devise.mailer.email_changed.subject')
    end
  end

  def welcome(user)
    @resource = user
    @instance = Rails.configuration.x.local_domain

    return if @resource.disabled?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('user_mailer.welcome.subject')
    end
  end

  def backup_ready(user, backup)
    @resource = user
    @instance = Rails.configuration.x.local_domain
    @backup   = backup

    return if @resource.disabled?

    I18n.with_locale(@resource.locale || I18n.default_locale) do
      mail to: @resource.email, subject: I18n.t('user_mailer.backup_ready.subject')
    end
  end

  private

  def push_slack(user, token)
    params = {
      channel: 'mastodon-request',
      attachments: [
        {
          color: '#36a64f',
          pretext: ENV['LOCAL_DOMAIN'],
          author_name: user.account['display_name'],
          author_link: user.account['fields'][0]['value'],
          text: "Pending confirmation:\nhttps://#{ENV['LOCAL_DOMAIN']}/auth/confirmation?confirmation_token=#{@token}"
        }
      ]
    }
    http = HttpService.new.call(ENV['SLACK_URI'], 'post', params)
  end
end
