$token = [Environment]::GetEnvironmentVariable("SPTRANS_TOKEN", "User")
 
 $codigoLinha = "%CodigoLinhaAtual%"
 $codigoParada = "%CodigoParadaAtual%"
 
 $baseUrl = "https://api.olhovivo.sptrans.com.br/v2.1"
 $sessao = New-Object Microsoft.PowerShell.Commands.WebRequestSession
 
 try {
 
     # Verificar token
     if ([string]::IsNullOrWhiteSpace($token)) {
         throw "Token SPTRANS_TOKEN não encontrado."
     }
 
     # Autenticação
     $urlLogin = "$baseUrl/Login/Autenticar?token=$([uri]::EscapeDataString($token))"
 
     $login = Invoke-RestMethod `
         -Uri $urlLogin `
         -Method Post `
         -WebSession $sessao
 
     if ($login -ne $true) {
         throw "Falha na autenticação da SPTrans."
     }
 
     # Consultar previsão no ponto
     $urlPrevisao = "$baseUrl/Previsao?codigoParada=$codigoParada&codigoLinha=$codigoLinha"
 
     $resposta = Invoke-RestMethod `
         -Uri $urlPrevisao `
         -Method Get `
         -WebSession $sessao
 
     # Inicializar variáveis
     $veiculos = @()
     $linhaEncontrada = ""
     $statusConsulta = "SEM_PREVISAO_NO_PONTO"
     $quantidadeVeiculosLinha = 0
     $erroPosicao = ""
 
     # Processar veículos previstos
     if ($null -ne $resposta.p -and $null -ne $resposta.p.l) {
 
         foreach ($linhaApi in $resposta.p.l) {
 
             if ([string]$linhaApi.cl -eq [string]$codigoLinha) {
 
                 $linhaEncontrada = $linhaApi.c
 
                 foreach ($veiculo in $linhaApi.vs) {
 
                     $horaConsulta = [datetime]::ParseExact(
                         $resposta.hr,
                         "HH:mm",
                         [Globalization.CultureInfo]::InvariantCulture
                     )
 
                     $horaChegada = [datetime]::ParseExact(
                         $veiculo.t,
                         "HH:mm",
                         [Globalization.CultureInfo]::InvariantCulture
                     )
 
                     $espera = ($horaChegada - $horaConsulta).TotalMinutes
 
                     # Tratar virada do dia
                     if ($espera -lt 0) {
                         $espera += 1440
                     }
 
                     $veiculos += @{
                         prefixo = $veiculo.p
                         horarioPrevisto = $veiculo.t
                         esperaMinutos = [int][math]::Round($espera)
                     }
                 }
             }
         }
     }
 
     # Classificar resultado da previsão
     if (@($veiculos).Count -gt 0) {
 
         $statusConsulta = "PREVISOES_ENCONTRADAS"
 
     }
     else {
 
         # Consultar posição de todos os veículos da linha
         try {
 
             $urlPosicao = "$baseUrl/Posicao/Linha?codigoLinha=$codigoLinha"
 
             $respostaPosicao = Invoke-RestMethod `
                 -Uri $urlPosicao `
                 -Method Get `
                 -WebSession $sessao
 
             $veiculosNaLinha = @()
 
             if ($null -ne $respostaPosicao.vs) {
                 $veiculosNaLinha = @($respostaPosicao.vs)
             }
 
             $quantidadeVeiculosLinha = $veiculosNaLinha.Count
 
             if ($quantidadeVeiculosLinha -gt 0) {
 
                 $statusConsulta = "SEM_PREVISAO_NO_PONTO"
 
             }
             else {
 
                 $statusConsulta = "SEM_VEICULOS_LOCALIZADOS"
 
             }
         }
         catch {
 
             $statusConsulta = "ERRO_API_POSICAO"
             $erroPosicao = $_.Exception.Message
 
         }
     }
 
 	$nomeParada = ""

	if ($null -ne $resposta.p) {
	    $nomeParada = $resposta.p.np
	}
 
     # Organizar resultado final
     $saida = @{
         horaConsulta = $resposta.hr
         codigoLinha = $codigoLinha
         linha = $linhaEncontrada
         codigoParada = $codigoParada
         nomeParada = $nomeParada
         veiculos = @($veiculos)
         statusConsulta = $statusConsulta
         quantidadeVeiculosLinha = $quantidadeVeiculosLinha
         erroPosicao = $erroPosicao
         respostaOriginal = $resposta
     }
 
     # Devolver somente um JSON
     Write-Output (ConvertTo-Json -InputObject $saida -Depth 30 -Compress)
 
 }
 catch {
 
     # Tratar falha de autenticação ou consulta principal
     $saida = @{
         erro = $_.Exception.Message
         statusConsulta = "ERRO_API_PREVISAO"
         quantidadeVeiculosLinha = 0
         erroPosicao = ""
         codigoLinha = $codigoLinha
         codigoParada = $codigoParada
         veiculos = @()
     }
 
     Write-Output (ConvertTo-Json -InputObject $saida -Depth 30 -Compress)
 
 }   