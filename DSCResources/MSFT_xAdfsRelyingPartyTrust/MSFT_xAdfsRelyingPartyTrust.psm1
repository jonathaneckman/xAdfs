
data LocalizedData
{
    ConvertFrom-StringData @'
        PropertyNotInDesiredState = {0} not in desired state. Expected: {1} Actual: {2}
        RPTrustNotFound = Adfs RelyingParty Trust with name {0} was not found
        AddingRelyingPartyTrust =  Adfs Relying Party Trust with name {0} was not found. Ensure equals Present. Adding new Relying Party Trust.
        CorrectingRelyingPartyTrust = Adfs Relying Party Trust with name {0} found. Ensure equals Present. Correcting configuration.
        RemovingRelyingPartyTrust = Adfs Relying Party Trust with name {0} was found. Ensure equals Absent. Removing Relying Party Trust    
'@

}


function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    $rpTrust = Get-AdfsRelyingPartyTrust -Name $Name

    if($rpTrust -eq $null)
    {
        Write-Warning -Message $($LocalizedData.RPTrustNotFound) -f $Name
        $EnsureResult = "Absent"
    }
    else
    {
        $EnsureResult = "Present"
    }

    
    $returnValue = @{
        AdditionalAuthenticationRules = $rpTrust.AdditionalAuthenticationRules
        AdditionalWSFedEndpoint = $rpTrust.AdditionalWSFedEndpoint
        AutoUpdateEnabled = $rpTrust.AutoUpdateEnabled
        ClaimAccepted = $rpTrust.ClaimsAccepted
        ClaimsProviderName = $rpTrust.ClaimsProviderName
        DelegationAuthorizationRules = $rpTrust.DelegationAuthorizationRules
        Enabled = $rpTrust.Enabled
        EnableJWT = $rpTrust.EnableJWT
        EncryptClaims = $rpTrust.EncryptClaims
        EncryptedNameIdRequired = $rpTrust.EncryptedNameIdRequired
        EncryptionCertificate = $rpTrust.EncryptionCertificate
        EncryptionCertificateRevocationCheck = $rpTrust.EncryptionCertificateRevocationCheck
        Identifier = $rpTrust.Identifier
        ImpersonationAuthorizationRules = $rpTrust.ImpersonationAuthorizationRules
        IssuanceAuthorizationRules = $rpTrust.IssuanceAuthorizationRules
        IssuanceTransformRules = $rpTrust.IssuanceTransformRules
        MetadataUrl = $rpTrust.MetadataUrl
        MonitoringEnabled = $rpTrust.MonitoringEnabled
        Name = $rpTrust.Name
        NotBeforeSkew = $rpTrust.NotBeforeSkew
        Notes = $rpTrust.Notes
        ProtocolProfile = $rpTrust.ProtocolProfile
        RequestSigningCertificate = $rpTrust.RequestSigningCertificate
        SamlEndpoint = $rpTrust.SamlEndpoints
        SamlResponseSignature = $rpTrust.SamlResponseSignature
        SignatureAlgorithm = $rpTrust.SignatureAlgorithm
        SignedSamlRequestsRequired = $rpTrust.SignedSamlRequestsRequired
        SigningCertificateRevocationCheck = $rpTrust.SigningCertificateRevocationCheck
        TokenLifetime = $rpTrust.TokenLifetime
        WSFedEndpoint = $rpTrust.WSFedEndpoint
        Ensure = $EnsureResult
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [System.String]
        $AdditionalAuthenticationRules,

        [System.String[]]
        $AdditionalWSFedEndpoint,

        [System.Boolean]
        $AutoUpdateEnabled,

        [System.String[]]
        $ClaimAccepted,

        [System.String[]]
        $ClaimsProviderName,

        [System.String]
        $DelegationAuthorizationRules,

        [System.Boolean]
        $Enabled,

        [System.Boolean]
        $EnableJWT,

        [System.Boolean]
        $EncryptClaims,

        [System.Boolean]
        $EncryptedNameIdRequired,

        [System.String]
        $EncryptionCertificate,

        [ValidateSet("None","CheckEndCert","CheckEndCertCacheOnly","CheckChain","CheckChainCacheOnly","CheckChainExcludingRoot","CheckChainExcludingRootCacheOnly")]
        [System.String]
        $EncryptionCertificateRevocationCheck,

        [System.String[]]
        $Identifier,

        [System.String]
        $ImpersonationAuthorizationRules,

        [System.String]
        $IssuanceAuthorizationRules,

        [System.String]
        $IssuanceTransformRules,

        [System.String]
        $MetadataUrl,

        [System.Boolean]
        $MonitoringEnabled,

        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.Int32]
        $NotBeforeSkew,

        [System.String]
        $Notes,

        [ValidateSet("SAML","WsFederation","WsFed-SAML")]
        [System.String]
        $ProtocolProfile,

        [System.String[]]
        $RequestSigningCertificate,

        [System.String[]]
        $SamlEndpoint,

        [ValidateSet("AssertionOnly","MessageAndAssertion","MessageOnly")]
        [System.String]
        $SamlResponseSignature,

        [ValidateSet("http://www.w3.org/2000/09/xmldsig#rsa-sha1","http://www.w3.org/2001/04/xmldsig-more#rsa-sha256")]
        [System.String]
        $SignatureAlgorithm,

        [System.Boolean]
        $SignedSamlRequestsRequired,

        [ValidateSet("None","CheckEndCert","CheckEndCertCacheOnly","CheckChain","CheckChainCacheOnly","CheckChainExcludingRoot","CheckChainExcludingRootCacheOnly")]
        [System.String]
        $SigningCertificateRevocationCheck,

        [System.Int32]
        $TokenLifetime,

        [System.String]
        $WSFedEndpoint,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )

    #Remove Ensure from PSBoundParameter because it is not a parameter on the *AdfsRelyingPartyTrust cmdlets
    $PSBoundParameters.Remove('Ensure')
    $rpTrust = Get-AdfsRelyingPartyTrust -Name $Name
    
    if($null -eq $rpTrust -and $Ensure -eq 'Present')
    {
        Write-Verbose -Message $($LocalizedData.AddingRelyingPartyTrust) -f $Name
        Add-AdfsRelyingPartyTrust @PSBoundParameters

    }
    elseIf($null -ne $rpTrust -and $Ensure -eq 'Present')
    {
        Write-Verbose -Message $($LocalizedData.CorrectingRelyingPartyTrust) -f $Name
        $PSBoundParameters.Remove('Enabled')
        $PSBoundParameters.Add('TargetName',$Name)
        Set-AdfsRelyingPartyTrust @PSBoundParameters
    }
    elseIf($null -ne $rpTrust -and $Ensure -eq 'Absent')
    {
        Write-Verbose -Message $($LocalizedData.RemovingRelyingPartyTrust) -f $Name

        Remove-AdfsRelyingPartyTrust -TargetIdentifier $Name        
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [System.String]
        $AdditionalAuthenticationRules,

        [System.String[]]
        $AdditionalWSFedEndpoint,

        [System.Boolean]
        $AutoUpdateEnabled,

        [System.String[]]
        $ClaimAccepted,

        [System.String[]]
        $ClaimsProviderName,

        [System.String]
        $DelegationAuthorizationRules,

        [System.Boolean]
        $Enabled,

        [System.Boolean]
        $EnableJWT,

        [System.Boolean]
        $EncryptClaims,

        [System.Boolean]
        $EncryptedNameIdRequired,

        [System.String]
        $EncryptionCertificate,

        [ValidateSet("None","CheckEndCert","CheckEndCertCacheOnly","CheckChain","CheckChainCacheOnly","CheckChainExcludingRoot","CheckChainExcludingRootCacheOnly")]
        [System.String]
        $EncryptionCertificateRevocationCheck,

        [System.String[]]
        $Identifier,

        [System.String]
        $ImpersonationAuthorizationRules,

        [System.String]
        $IssuanceAuthorizationRules,

        [System.String]
        $IssuanceTransformRules,

        [System.String]
        $MetadataUrl,

        [System.Boolean]
        $MonitoringEnabled,

        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.Int32]
        $NotBeforeSkew,

        [System.String]
        $Notes,

        [ValidateSet("SAML","WsFederation","WsFed-SAML")]
        [System.String]
        $ProtocolProfile,

        [System.String[]]
        $RequestSigningCertificate,

        [System.String[]]
        $SamlEndpoint,

        [ValidateSet("AssertionOnly","MessageAndAssertion","MessageOnly")]
        [System.String]
        $SamlResponseSignature,

        [ValidateSet("http://www.w3.org/2000/09/xmldsig#rsa-sha1","http://www.w3.org/2001/04/xmldsig-more#rsa-sha256")]
        [System.String]
        $SignatureAlgorithm,

        [System.Boolean]
        $SignedSamlRequestsRequired,

        [ValidateSet("None","CheckEndCert","CheckEndCertCacheOnly","CheckChain","CheckChainCacheOnly","CheckChainExcludingRoot","CheckChainExcludingRootCacheOnly")]
        [System.String]
        $SigningCertificateRevocationCheck,

        [System.Int32]
        $TokenLifetime,

        [System.String]
        $WSFedEndpoint,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure
    )    

    $rpTrust = Get-AdfsRelyingPartyTrust -Name $Name

    if($rpTrust -eq $null -and $Ensure -eq 'Present')
    {
        Write-Verbose -Message ($LocalizedData.RPTrustNotFound -f $Name)
        return $false
    }
    if($rpTrust -ne $null -and $Ensure -eq 'Absent')
    {
        return $false
    }
    if($PSBoundParameters.ContainsKey('AdditionalAuthenticationRules') -and $PSBoundParameters.AdditionalAuthenticationRules -ne $rpTrust.AdditionalAuthenticationRules)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'AdditionalAuthenticationRules', `
            $($PSBoundParameters.AdditionalAuthenticationRules), `
            $($rpTrust.AdditionalAuthenticationRules))

        return $false
    }
    if($PSBoundParameters.ContainsKey('AdditionalWSFedEndpoint'))
    {
        if(-not(Compare-Array $PSBoundParameters.AdditionalWSFedEndpoint $rpTrust.AdditionalWSFedEndpoint))
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'AdditionalWSFedEndpoint', `
                $(ConvertTo-String $PSBoundParameters.AdditionalWSFedEndpoint), `
                $(ConvertTo-String $rpTrust.AdditionalWSFedEndpoint))

            return $false
        }

    }
    if($PSBoundParameters.ContainsKey('AutoUpdateEnabled') -and $PSBoundParameters.AutoUpdateEnabled -ne $rpTrust.AutoUpdateEnabled)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'AutoUpdateEnabled', `
            $($PSBoundParameters.AutoUpdateEnabled), `
            $($rpTrust.AutoUpdateEnabled))

        return $false
    }
    if($PSBoundParameters.ContainsKey('ClaimAccepted'))
    {
        if(-not(Compare-Array $PSBoundParameters.ClaimAccepted $rpTrust.ClaimsAccepted))
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'ClaimAccepted', `
                $(ConvertTo-String $PSBoundParameters.ClaimAccepted), `
                $(ConvertTo-String $rpTrust.ClaimAccepted))

            return $false
        }
    }
    if($PSBoundParameters.ContainsKey('ClaimsProviderName'))
    {
        if(-not(Compare-Array $PSBoundParameters.ClaimsProviderName $rpTrust.ClaimsProviderName))
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'ClaimsProviderName', `
                $(ConvertTo-String $PSBoundParameters.ClaimsProviderName), `
                $(ConvertTo-String $rpTrust.ClaimsProviderName))

            return $false
        }
    }
    if($PSBoundParameters.ContainsKey('DelegationAuthorizationRules') -and $PSBoundParameters.DelegationAuthorizationRules -ne $rpTrust.DelegationAuthorizationRules)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'DelegationAuthorizationRules', `
            $($PSBoundParameters.DelegationAuthorizationRules), `
            $($rpTrust.DelegationAuthorizationRules))
            
        return $false
    }
    if($PSBoundParameters.ContainsKey('Enabled') -and $PSBoundParameters.Enabled -ne $rpTrust.Enabled)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'Enabled', `
            $($PSBoundParameters.Enabled), `
            $($rpTrust.Enabled))

        return $false
    }
    if($PSBoundParameters.ContainsKey('EnableJWT') -and $PSBoundParameters.EnableJWT -ne $rpTrust.EnableJWT)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'EnableJWT', `
            $($PSBoundParameters.EnableJWT), `
            $($rpTrust.EnableJWT))

        return $false
    }
    if($PSBoundParameters.ContainsKey('EncryptClaims') -and $PSBoundParameters.EncryptClaims -ne $rpTrust.EncryptClaims)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'EncryptClaims', `
            $($PSBoundParameters.EncryptClaims), `
            $($rpTrust.EncryptClaims))
            
        return $false
    }
    if($PSBoundParameters.ContainsKey('EncryptedNameIdRequired') -and $PSBoundParameters.EncryptedNameIdRequired -ne $rpTrust.EncryptedNameIdRequired)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'EncryptedNameIdRequired', `
            $($PSBoundParameters.EncryptedNameIdRequired), `
            $($rpTrust.EncryptedNameIdRequired))

        return $false
    }
    if($PSBoundParameters.ContainsKey('EncryptionCertificate') -and $PSBoundParameters.EncryptionCertificate -ne $rpTrust.EncryptionCertificate)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'EncryptionCertificate', `
            $($PSBoundParameters.EncryptionCertificate), `
            $($rpTrust.EncryptionCertificate))

        return $false
    }
    if($PSBoundParameters.ContainsKey('EncryptionCertificateRevocationCheck') -and $PSBoundParameters.EncryptionCertificateRevocationCheck -ne $rpTrust.EncryptionCertificateRevocationCheck)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'EncryptionCertificateRevocationCheck', `
            $($PSBoundParameters.EncryptionCertificateRevocationCheck), `
            $($rpTrust.EncryptionCertificateRevocationCheck))

        return $false
    }
    if($PSBoundParameters.ContainsKey('Identifier'))
    {
        if(-not(Compare-Array $PSBoundParameters.Identifier $rpTrust.Identifier))
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'Identifier', `
                $(ConvertTo-String $PSBoundParameters.Identifier), `
                $(ConvertTo-String $rpTrust.Identifier))

            return $false
        }
    }
    if($PSBoundParameters.ContainsKey('ImpersonationAuthorizationRules')) 
    {
        $CompareResultsImpersonationAuthorizationRules = Compare-AdfsRules $PSBoundParameters.ImpersonationAuthorizationRules $rpTrust.ImpersonationAuthorizationRules

        if($CompareResultsImpersonationAuthorizationRules -eq $false)
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'ImpersonationAuthorizationRules', `
                $($PSBoundParameters.ImpersonationAuthorizationRules), `
                $($rpTrust.ImpersonationAuthorizationRules))

                return $false
        }
    }
    if($PSBoundParameters.ContainsKey('IssuanceAuthorizationRules')) 
    {
        $CompareResultsIssuanceAuthorizationRules = Compare-AdfsRules $PSBoundParameters.ImpersonationAuthorizationRules $rpTrust.ImpersonationAuthorizationRules

        if($CompareResultsIssuanceAuthorizationRules -eq $false)
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'IssuanceAuthorizationRules', `
                $($PSBoundParameters.IssuanceAuthorizationRules), `
                $($rpTrust.IssuanceAuthorizationRules))

            return $false
        }
    }
    if($PSBoundParameters.ContainsKey('IssuanceTransformRules'))
    {
        $CompareResultsTransformRules = Compare-AdfsRules $PSBoundParameters.IssuanceTransformRules $rpTrust.IssuanceTransformRules

        if($CompareResultsTransformRules -eq $false)
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'IssuanceTransformRules', `
                $($PSBoundParameters.IssuanceTransformRules), `
                $($rpTrust.IssuanceTransformRules))

            return $false
        }
    }
    if($PSBoundParameters.ContainsKey('MetadataUrl') -and $PSBoundParameters.MetadataUrl -ne $rpTrust.MetadataUrl)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'MetadataUrl', `
            $($PSBoundParameters.MetadataUrl), `
            $($rpTrust.MetadataUrl))

        return $false
    }
    if($PSBoundParameters.ContainsKey('MonitoringEnabled') -and $PSBoundParameters.MonitoringEnabled -ne $rpTrust.MonitoringEnabled)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'MonitoringEnabled', `
            $($PSBoundParameters.MonitoringEnabled), `
            $($rpTrust.MonitoringEnabled))

        return $false
    }
    if($PSBoundParameters.ContainsKey('NotBeforeSkew') -and $PSBoundParameters.NotBeforeSkew -ne $rpTrust.NotBeforeSkew)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'NotBeforeSkew', `
            $($PSBoundParameters.NotBeforeSkew), `
            $($rpTrust.NotBeforeSkew))

        return $false
    }
    if($PSBoundParameters.ContainsKey('Notes') -and $PSBoundParameters.Notes -ne $rpTrust.Notes)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'Notes', `
            $($PSBoundParameters.Notes), `
            $($rpTrust.Notes))

        return $false
    }
    if($PSBoundParameters.ContainsKey('ProtocolProfile') -and $PSBoundParameters.ProtocolProfile -ne $rpTrust.ProtocolProfile)
    {
         Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'ProtocolProfile', `
            $($PSBoundParameters.ProtocolProfile), `
            $($rpTrust.ProtocolProfile))

        return $false
    }
    if($PSBoundParameters.ContainsKey('RequestSigningCertificate'))
    {
        if(-not(Compare-Array $PSBoundParameters.RequestSigningCertificate $rpTrust.RequestSigningCertificate))
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'RequestSigningCertificate', `
                $(ConvertTo-String $PSBoundParameters.RequestSigningCertificate), `
                $(ConvertTo-String $rpTrust.RequestSigningCertificate))
                
            return $false
        }
    }
    if($PSBoundParameters.ContainsKey('SamlEndpoint'))
    {
        if(-not(Compare-Array $PSBoundParameters.SamlEndpoint $rpTrust.SamlEndpoint))
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'SamlEndpoint', `
                $(ConvertTo-String $PSBoundParameters.SamlEndpoint), `
                $(ConvertTo-String $rpTrust.SamlEndpoint))

            return $false
        }
    }
    if($PSBoundParameters.ContainsKey('SamlResponseSignature') -and $PSBoundParameters.SamlResponseSignature -ne $rpTrust.SamlResponseSignature)
    {
         Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'SamlResponseSignature', `
            $($PSBoundParameters.SamlResponseSignature), `
            $($rpTrust.SamlResponseSignature))

        return $false
    }
    if($PSBoundParameters.ContainsKey('SignatureAlgorithm') -and $PSBoundParameters.SignatureAlgorithm -ne $rpTrust.SignatureAlgorithm)
    {
         Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'SignatureAlgorithm', `
            $($PSBoundParameters.SignatureAlgorithm), `
            $($rpTrust.SignatureAlgorithm))

        return $false
    }
    if($PSBoundParameters.ContainsKey('SignedSamlRequestsRequired') -and $PSBoundParameters.SignedSamlRequestsRequired -ne $rpTrust.SignedSamlRequestsRequired)
    {
         Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'SignedSamlRequestsRequired', `
            $($PSBoundParameters.SignedSamlRequestsRequired), `
            $($rpTrust.SignedSamlRequestsRequired))

        return $false
    }
    if($PSBoundParameters.ContainsKey('SigningCertificateRevocationCheck') -and $PSBoundParameters.SigningCertificateRevocationCheck -ne $rpTrust.SigningCertificateRevocationCheck)
    {
         Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'SigningCertificateRevocationCheck', `
            $($PSBoundParameters.SigningCertificateRevocationCheck), `
            $($rpTrust.SigningCertificateRevocationCheck))

        return $false
    }
    if($PSBoundParameters.ContainsKey('TokenLifetime') -and $PSBoundParameters.TokenLifetime -ne $rpTrust.TokenLifetime)
    {
         Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'TokenLifetime', `
            $($PSBoundParameters.TokenLifetime), `
            $($rpTrust.TokenLifetime))

        return $false
    }
    if($PSBoundParameters.ContainsKey('WSFedEndpoint') -and $PSBoundParameters.WSFedEndpoint -ne $rpTrust.WSFedEndpoint)
    {
         Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'WSFedEndpoint', `
            $($PSBoundParameters.WSFedEndpoint), `
            $($rpTrust.WSFedEndpoint))

        return $false
    }
    #if the code made it this far all settings must be in a desired state
    return $true
}


Export-ModuleMember -Function *-TargetResource
