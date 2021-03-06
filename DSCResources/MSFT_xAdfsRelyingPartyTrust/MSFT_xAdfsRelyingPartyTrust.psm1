
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

    if ($null -eq $rpTrust)
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
    
    if ($null -eq $rpTrust -and $Ensure -eq 'Present')
    {
        Write-Verbose -Message $($LocalizedData.AddingRelyingPartyTrust) -f $Name
        Add-AdfsRelyingPartyTrust @PSBoundParameters

    }
    elseIf ( $null -ne $rpTrust -and $Ensure -eq 'Present')
    {
        Write-Verbose -Message $($LocalizedData.CorrectingRelyingPartyTrust) -f $Name
        $PSBoundParameters.Remove('Enabled')
        $PSBoundParameters.Add('TargetName',$Name)
        Set-AdfsRelyingPartyTrust @PSBoundParameters
    }
    elseIf ($null -ne $rpTrust -and $Ensure -eq 'Absent')
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

    if ($rpTrust -eq $null -and $Ensure -eq 'Present')
    {
        Write-Verbose -Message ($LocalizedData.RPTrustNotFound -f $Name)
        return $false
    }
    if ($rpTrust -ne $null -and $Ensure -eq 'Absent')
    {
        return $false
    }
    if ($PSBoundParameters.ContainsKey('AdditionalAuthenticationRules'))
    {
        if ($PSBoundParameters.AdditionalAuthenticationRules -ne $rpTrust.AdditionalAuthenticationRules)
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'AdditionalAuthenticationRules', `
                $AdditionalAuthenticationRules, `
                $($rpTrust.AdditionalAuthenticationRules))

            return $false
        }
    }
    if ($PSBoundParameters.ContainsKey('AdditionalWSFedEndpoint'))
    {
        if (-not(Compare-Array $AdditionalWSFedEndpoint $rpTrust.AdditionalWSFedEndpoint))
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'AdditionalWSFedEndpoint', `
                $(ConvertTo-String $AdditionalWSFedEndpoint), `
                $(ConvertTo-String $rpTrust.AdditionalWSFedEndpoint))

            return $false
        }

    }
    if ($PSBoundParameters.ContainsKey('AutoUpdateEnabled'))
    {
        if ($PSBoundParameters.AutoUpdateEnabled -ne $rpTrust.AutoUpdateEnabled)
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'AutoUpdateEnabled', `
                $AutoUpdateEnabled, `
                $($rpTrust.AutoUpdateEnabled))

        return $false
        }
    }
    if ($PSBoundParameters.ContainsKey('ClaimAccepted'))
    {
        if (-not(Compare-Array $ClaimAccepted $rpTrust.ClaimsAccepted))
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'ClaimAccepted', `
                $(ConvertTo-String $ClaimAccepted), `
                $(ConvertTo-String $rpTrust.ClaimAccepted))

            return $false
        }
    }
    if ($PSBoundParameters.ContainsKey('ClaimsProviderName'))
    {
        if (-not(Compare-Array $ClaimsProviderName $rpTrust.ClaimsProviderName))
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'ClaimsProviderName', `
                $(ConvertTo-String $ClaimsProviderName), `
                $(ConvertTo-String $rpTrust.ClaimsProviderName))

            return $false
        }
    }
    if ($PSBoundParameters.ContainsKey('DelegationAuthorizationRules'))
    {
        
        if ($PSBoundParameters.DelegationAuthorizationRules -ne $rpTrust.DelegationAuthorizationRules)
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'DelegationAuthorizationRules', `
                $DelegationAuthorizationRules, `
                $($rpTrust.DelegationAuthorizationRules))
            
            return $false
        }
    }
    if ($PSBoundParameters.ContainsKey('Enabled') -and $PSBoundParameters.Enabled -ne $rpTrust.Enabled)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'Enabled', `
            $Enabled, `
            $($rpTrust.Enabled))

        return $false
    }
    if ($PSBoundParameters.ContainsKey('EnableJWT') -and $PSBoundParameters.EnableJWT -ne $rpTrust.EnableJWT)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'EnableJWT', `
            $EnableJWT, `
            $($rpTrust.EnableJWT))

        return $false
    }
    if ($PSBoundParameters.ContainsKey('EncryptClaims') -and $PSBoundParameters.EncryptClaims -ne $rpTrust.EncryptClaims)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'EncryptClaims', `
            $EncryptClaims, `
            $($rpTrust.EncryptClaims))
            
        return $false
    }
    if ($PSBoundParameters.ContainsKey('EncryptedNameIdRequired'))
    {
        if ($PSBoundParameters.EncryptedNameIdRequired -ne $rpTrust.EncryptedNameIdRequired)
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'EncryptedNameIdRequired', `
                $EncryptedNameIdRequired, `
                $($rpTrust.EncryptedNameIdRequired))

            return $false
        }
    }
    if ($PSBoundParameters.ContainsKey('EncryptionCertificate') -and $PSBoundParameters.EncryptionCertificate -ne $rpTrust.EncryptionCertificate)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'EncryptionCertificate', `
            $EncryptionCertificate, `
            $($rpTrust.EncryptionCertificate))

        return $false
    }
    if ($PSBoundParameters.ContainsKey('EncryptionCertificateRevocationCheck'))
    {
        if ($PSBoundParameters.EncryptionCertificateRevocationCheck -ne $rpTrust.EncryptionCertificateRevocationCheck)
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'EncryptionCertificateRevocationCheck', `
                $EncryptionCertificateRevocationCheck, `
                $($rpTrust.EncryptionCertificateRevocationCheck))

            return $false
        }
    }
    if ($PSBoundParameters.ContainsKey('Identifier'))
    {
        if (-not(Compare-Array $PSBoundParameters.Identifier $rpTrust.Identifier))
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'Identifier', `
                $(ConvertTo-String $Identifier), `
                $(ConvertTo-String $rpTrust.Identifier))

            return $false
        }
    }
    if ($PSBoundParameters.ContainsKey('ImpersonationAuthorizationRules')) 
    {
        $CompareResultsImpersonationAuthorizationRules = Compare-AdfsRules $ImpersonationAuthorizationRules $rpTrust.ImpersonationAuthorizationRules

        if ($CompareResultsImpersonationAuthorizationRules -eq $false)
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'ImpersonationAuthorizationRules', `
                $ImpersonationAuthorizationRules, `
                $($rpTrust.ImpersonationAuthorizationRules))

                return $false
        }
    }
    if ($PSBoundParameters.ContainsKey('IssuanceAuthorizationRules')) 
    {
        $CompareResultsIssuanceAuthorizationRules = Compare-AdfsRules $IssuanceAuthorizationRules $rpTrust.IssuanceAuthorizationRules

        if ($CompareResultsIssuanceAuthorizationRules -eq $false)
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'IssuanceAuthorizationRules', `
                $IssuanceAuthorizationRules, `
                $($rpTrust.IssuanceAuthorizationRules))

            return $false
        }
    }
    if ($PSBoundParameters.ContainsKey('IssuanceTransformRules'))
    {
        $CompareResultsTransformRules = Compare-AdfsRules $IssuanceTransformRules $rpTrust.IssuanceTransformRules

        if ($CompareResultsTransformRules -eq $false)
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'IssuanceTransformRules', `
                $IssuanceTransformRules, `
                $($rpTrust.IssuanceTransformRules))

            return $false
        }
    }
    if ($PSBoundParameters.ContainsKey('MetadataUrl') -and $PSBoundParameters.MetadataUrl -ne $rpTrust.MetadataUrl)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'MetadataUrl', `
            $MetadataUrl, `
            $($rpTrust.MetadataUrl))

        return $false
    }
    if ($PSBoundParameters.ContainsKey('MonitoringEnabled') -and $PSBoundParameters.MonitoringEnabled -ne $rpTrust.MonitoringEnabled)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'MonitoringEnabled', `
            $MonitoringEnabled, `
            $($rpTrust.MonitoringEnabled))

        return $false
    }
    if ($PSBoundParameters.ContainsKey('NotBeforeSkew') -and $PSBoundParameters.NotBeforeSkew -ne $rpTrust.NotBeforeSkew)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'NotBeforeSkew', `
            $NotBeforeSkew, `
            $($rpTrust.NotBeforeSkew))

        return $false
    }
    if ($PSBoundParameters.ContainsKey('Notes') -and $PSBoundParameters.Notes -ne $rpTrust.Notes)
    {
        Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'Notes', `
            $Notes, `
            $($rpTrust.Notes))

        return $false
    }
    if ($PSBoundParameters.ContainsKey('ProtocolProfile') -and $PSBoundParameters.ProtocolProfile -ne $rpTrust.ProtocolProfile)
    {
         Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'ProtocolProfile', `
            $ProtocolProfile, `
            $($rpTrust.ProtocolProfile))

        return $false
    }
    if ($PSBoundParameters.ContainsKey('RequestSigningCertificate'))
    {
        if (-not(Compare-Array $RequestSigningCertificate $rpTrust.RequestSigningCertificate))
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'RequestSigningCertificate', `
                $(ConvertTo-String $RequestSigningCertificate), `
                $(ConvertTo-String $rpTrust.RequestSigningCertificate))
                
            return $false
        }
    }
    if ($PSBoundParameters.ContainsKey('SamlEndpoint'))
    {
        if (-not(Compare-Array $SamlEndpoint $rpTrust.SamlEndpoint))
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'SamlEndpoint', `
                $(ConvertTo-String $SamlEndpoint), `
                $(ConvertTo-String $rpTrust.SamlEndpoint))

            return $false
        }
    }
    if ($PSBoundParameters.ContainsKey('SamlResponseSignature') -and $SamlResponseSignature -ne $rpTrust.SamlResponseSignature)
    {
         Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'SamlResponseSignature', `
            $SamlResponseSignature, `
            $($rpTrust.SamlResponseSignature))

        return $false
    }
    if ($PSBoundParameters.ContainsKey('SignatureAlgorithm') -and $SignatureAlgorithm -ne $rpTrust.SignatureAlgorithm)
    {
         Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'SignatureAlgorithm', `
            $SignatureAlgorithm, `
            $($rpTrust.SignatureAlgorithm))

        return $false
    }
    if ($PSBoundParameters.ContainsKey('SignedSamlRequestsRequired') -and $SignedSamlRequestsRequired -ne $rpTrust.SignedSamlRequestsRequired)
    {
         Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'SignedSamlRequestsRequired', `
            $SignedSamlRequestsRequired, `
            $($rpTrust.SignedSamlRequestsRequired))

        return $false
    }
    if ($PSBoundParameters.ContainsKey('SigningCertificateRevocationCheck'))
    {
        if ($SigningCertificateRevocationCheck -ne $rpTrust.SigningCertificateRevocationCheck)
        {
            Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
                'SigningCertificateRevocationCheck', `
                $SigningCertificateRevocationCheck, `
                $($rpTrust.SigningCertificateRevocationCheck))

            return $false
        }
    }
    if ($PSBoundParameters.ContainsKey('TokenLifetime') -and $TokenLifetime -ne $rpTrust.TokenLifetime)
    {
         Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'TokenLifetime', `
            $TokenLifetime, `
            $($rpTrust.TokenLifetime))

        return $false
    }
    if ($PSBoundParameters.ContainsKey('WSFedEndpoint') -and $WSFedEndpoint -ne $rpTrust.WSFedEndpoint)
    {
         Write-Verbose -Message ($LocalizedData.PropertyNotInDesiredState -f `
            'WSFedEndpoint', `
            $WSFedEndpoint, `
            $($rpTrust.WSFedEndpoint))

        return $false
    }
    #if the code made it this far all settings must be in a desired state
    return $true
}


Export-ModuleMember -Function *-TargetResource
