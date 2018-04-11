$(document).on 'modal:contentUpdated', (e) ->
  $form = $('form[data-rule-types]')
  predefinedTypes = $form.data("rule-types") # read types from data attribute
  
  $form.find('.form-group.security_group_rule_type select').change () ->
    selectedType = predefinedTypes[$(this).find(":selected").val()] # find the settings for the new selection
    
    # for each key, value in selected type do
    for key,value of selectedType
      # skip if key is label
      if key!='label' && value
        # set predefined value unless it is true
        # find field group
        $fieldGroup = $form.find(".form-group.security_group_rule_#{key}")
        $inputField = $fieldGroup.find('input')
        $inputField = $fieldGroup.find('select') if $inputField.length==0
        $inputField.val(value)

    # show/hide port range or icmp type/code fields        
    if selectedType['protocol']=='icmp'
      $form.find('.form-group.security_group_rule_port_range').addClass('hidden')
      $form.find('.form-group.security_group_rule_icmp_type').removeClass('hidden')
      $form.find('.form-group.security_group_rule_icmp_code').removeClass('hidden')
      if selectedType['port_range']
        try
          range = selectedType['port_range'].split('-')
          if range.length>1
            $form.find('.form-group.security_group_rule_icmp_type input').val(range[0])
            $form.find('.form-group.security_group_rule_icmp_code input').val(range[1])
        catch e
          
    else
      $form.find('.form-group.security_group_rule_port_range').removeClass('hidden')
      $form.find('.form-group.security_group_rule_icmp_type').addClass('hidden')
      $form.find('.form-group.security_group_rule_icmp_code').addClass('hidden')
      
  
  $form.find('.form-group.security_group_rule_remote_source select').change () ->    
    value = $(this).find(":selected").val()
    if value=='remote_ip_prefix'
      $form.find(".form-group.security_group_rule_remote_ip_prefix").removeClass('hidden')
      $form.find(".form-group.security_group_rule_remote_group_id").addClass('hidden')
      $form.find(".form-group.security_group_rule_ethertype").addClass('hidden')
      $form.find("#wrapper_has_read_documentation").addClass('hidden')
    else
      $form.find(".form-group.security_group_rule_remote_ip_prefix").addClass('hidden')
      $form.find(".form-group.security_group_rule_remote_group_id").removeClass('hidden')
      $form.find(".form-group.security_group_rule_ethertype").removeClass('hidden')
      $form.find("#wrapper_has_read_documentation").removeClass('hidden')
