@{
    ModuleVersion     = '1.0.0'
    GUID              = 'a3f2d1c0-4e5b-4f6a-8d7c-9e0f1a2b3c4d'
    Author            = 'Ruthie-FRC'
    CompanyName       = 'Ruthie-FRC'
    Copyright         = '(c) 2025 Ruthie-FRC. MIT License.'
    Description       = 'FRC (FIRST Robotics Competition) PowerShell helpers: robot connectivity, SCP/SSH, Gradle build wrappers, and log collection.'
    PowerShellVersion = '7.0'
    RootModule        = 'FrcTools.psm1'
    FunctionsToExport = @(
        'Test-FrcRobotConnection'
        'Connect-RoboRioSsh'
        'Copy-ToRoboRio'
        'Copy-FromRoboRio'
        'Install-RoboRioJreIpk'
        'Get-RoboRioLogs'
        'Invoke-WpilibGradle'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags        = @('FRC', 'roboRIO', 'WPILib', 'GradleRIO', 'Robotics', 'FIRST')
            ProjectUri  = 'https://github.com/Ruthie-FRC/Powershell-Commands'
            ReleaseNotes = 'Initial release — FRC helper functions for robot development and competition-day automation.'
        }
    }
}
