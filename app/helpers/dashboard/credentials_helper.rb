module Dashboard::CredentialsHelper


  def parsed_blob(blob)
    blob.is_a?(String) ? JSON.parse(blob) : blob
  end

  
end
