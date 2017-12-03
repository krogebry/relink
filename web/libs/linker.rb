class UnableToFindKMSKeyException < Exception
end

class LDAPConnectionFailedException < Exception
end

class LDAPBindException < Exception
end

class LDAPAuthenticationFailure < Exception
end

module Linker
  REALM = 'CYBRAICS.COM'
  PEA_USER_BASE = 'OU=acmeui,DC=cybraics,DC=com'
  S3_BUCKET_NAME = 'cybraics-linker-2'
  ENABLED_PASSWD_NOT_EXPIRE = '66048'

  GROUP_ROLE_DN = 'CN=acmeusers,OU=Groups,DC=cybraics,DC=com'

  def self.make_password
    SecureRandom.base64(15)
  end

  def self.get_s3_client
    if ENV.key? 'USE_AWS_CREDS'
      creds = Aws::SharedCredentials.new
      Aws::S3::Client.new(credentials: creds, signature_version: 'v4')
    else
      Aws::S3::Client.new(signature_version: 'v4')
    end
  end

  def self.s_ldap_object(obj)
    c = {}
    obj.each do |k, v|
      next if k == :objectguid || k == :objectsid
      c[k.to_s] = v
    end
    c
  end

  def self.get_kms_client
    Aws::KMS::Client.new
  end

  def self.get_alias_key_id(kms_client, kms_key_alias)
    aliases = kms_client.list_aliases.aliases
    key = aliases.find { |alias_struct| alias_struct.alias_name == kms_key_alias }
    raise UnableToFindKMSKeyException if key.nil?
    key.target_key_id
  end

  def self.get_s3_enc_client(s3_client, kms_client, kms_key_alias)
    key_id = get_alias_key_id(kms_client, kms_key_alias)
    LOG.debug(format('KeyId: %s', key_id))
    Aws::S3::Encryption::Client.new(
      client: s3_client,
      kms_key_id: key_id,
      kms_client: kms_client
    )
  end

  def self.ldap_login(username, password)
    LOG.debug(format('Connecting to ldap on %s:%s', ENV['LDAP_HOST'], ENV['LDAP_PORT']))

    begin
      ldap = Net::LDAP.new(
        host: ENV['LDAP_HOST'],
        port: ENV['LDAP_PORT'],
        encryption: {
          method: :simple_tls,
          tls_options: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
        }
      )
    rescue Net::LDAP::ConnectionError, Net::LDAP::ConnectionRefusedError => e
      LOG.fatal(format('Failed to conncet to LDAP host %s: %s', ENV['LDAP_HOST'], e))
      return nil
    end

    begin
      LOG.debug(format('Authenticating: %s', username))
      ldap.auth username, password

      if ldap.bind
        msg = ldap.get_operation_result.message
        code = ldap.get_operation_result.code
        LOG.debug(format('Authenticated: %s - %s - %s', username, msg, code))
      else
        msg = ldap.get_operation_result.message
        code = ldap.get_operation_result.code
        LOG.fatal(format('Bind failed %s - %s', msg, code).red)
        raise LDAPBindException, 'Failed to bind to LDAP host'
      end
    rescue LDAPBindException => e
      LOG.fatal(format('Failed to authenticate to the LDAP server: %s', e))
      return nil
    end

    ldap
  end
end

# require format('%s/linker/customer.rb', LIB_DIR)
