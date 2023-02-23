#!/usr/bin/env ruby
# frozen_string_literal: true

require 'google/apis/gmail_v1'
require 'googleauth/stores/file_token_store'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

# Gmail module.
module Gmail
  # Gmail importer class.
  class Importer
    def initialize(folder, user_id, client_id_file, token_file)
      raise ArgumentError, "Folder #{folder} does not exist" unless Dir.exist?(folder)
      raise ArgumentError, "File #{client_id_file} does not exist" unless File.exist?(client_id_file)
      raise ArgumentError, "User ID #{user_id} is not a valid email address" unless user_id =~ /@/

      @folder = folder
      @user_id = user_id
      @gmail = init_gmail(client_id_file, token_file)
    end

    def list_labels
      @gmail.list_user_labels(@user_id).labels.each do |label|
        puts "#{label.id}: #{label.name}"
      end
    end

    def import!
      Dir.glob(File.join(@folder, '*.mime')).each do |file|
        import_mail(file)
      end
    end

    private

    def init_authorizer(client_id_file, token_file)
      scopes = [
        'https://www.googleapis.com/auth/gmail.labels',
        'https://www.googleapis.com/auth/gmail.insert',
        'https://www.googleapis.com/auth/gmail.modify'
      ]
      client_id = Google::Auth::ClientId.from_file(client_id_file)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: token_file)
      Google::Auth::UserAuthorizer.new(client_id, scopes, token_store)
    end

    def retrieve_authenticate_code(authorizer)
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts "Open #{url} in your browser and enter the resulting code:"
      gets
    end

    def authenticate(client_id_file, token_file)
      authorizer = init_authorizer(client_id_file, token_file)
      credentials = authorizer.get_credentials(@user_id)

      return credentials unless credentials.nil?

      code = retrieve_authenticate_code(authorizer)
      authorizer.get_and_store_credentials_from_code(
        user_id: @user_id,
        code: code,
        base_url: OOB_URI
      )
    end

    def init_gmail(client_id_file, token_file)
      gmail = Google::Apis::GmailV1::GmailService.new
      gmail.authorization = authenticate(client_id_file, token_file)
      gmail
    end

    def import_mail(file)
      mail = import(file)
      puts "#{file} successfully imported:"
      puts "  ID: #{mail.id}."
      result = label(mail)
      puts "  Labels: #{result.label_ids}."
    rescue StandardError => e
      puts "Error importing #{file}: #{e}"
    end

    def import(file)
      @gmail.import_user_message(@user_id,
                                 nil,
                                 upload_source: file,
                                 content_type: 'message/rfc822',
                                 never_mark_spam: true)
    end

    def label(mail)
      # TODO: Select labels based on user input.
      labels = %w[Label_123 Label_456]
      mmr = Google::Apis::GmailV1::ModifyMessageRequest.new(add_label_ids: labels)
      @gmail.modify_message(@user_id, mail.id, mmr)
    end
  end
end

# TODO: Select arguments based on user input.
importer = Gmail::Importer.new(
  '/folder/containing/mime/files/to/import',
  'example@gmail.com',
  '/home/example/.gcloud/client_secret_1234.apps.googleusercontent.com.json',
  '/home/example/.gcloud/tokens.yaml'
)

# importer.list_labels

importer.import!
