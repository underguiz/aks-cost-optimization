Param
(
  [Parameter (Mandatory= $true)]
  [String] $ClusterName,
  
  [Parameter (Mandatory= $true)]
  [String] $ResourceGroup,

  [Parameter (Mandatory= $true)]
  [String] $Action

)

Connect-AzAccount -Identity

switch ( $Action )
{
    start { $Return = Start-AzAksCluster -Name $ClusterName -ResourceGroupName $ResourceGroup }
    stop  { $Return = Stop-AzAksCluster -Name $ClusterName -ResourceGroupName $ResourceGroup  }
}

Write-Output ($Return)