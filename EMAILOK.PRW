#INCLUDE "Ap5Mail.ch" 


/*{Protheus.doc} 
Fun��o com o objetivo de enviar email, validando a priore o destinat�rio.
Caso o email seja inv�lido, ser� enviado uma notifuca��o ao atendimento para entrar em contato com o cliente para atualiza��o.
Parametros Necess�rios:
cServer: Servidor smtp:587
cAccount: Conta remetente
cPassword: senha
cTo: Destinat�rio
cCC: Com C�pia para...
cSubject: Assunto do e-mail
cConteudo: corpo do e-mail
/*/


User Function EMAILOK(cServer, cAccount, cPassword, cTo, cCC, cSubject, cConteudo,cCC2,lCliente,lConfirmaEnvio)
 
Local lSmtpAuth := GetMv("MV_RELAUTH",,.F.)
Local cFrom     := cAccount
Local lOk       := .T.
Local lAutOk    := .F.                                          
Local cBody     := cConteudo  
local cMsg      :=""



If lConfirmaEnvio
	if ValidEmail(cTo, lCliente)
	
		cMsg:= "Email enviado ao Cliente com sucesso!!!"
		
		if lCliente == .F.
			cMsg:= "Email interno Enviado."
		endif
		
	else
		//Se o e-mail n�o for v�lido, ser� enviado uma msgm ao atendimento para solicitar corre��o ao cliente.
		
		alert("Ops!   Email do Cliente Inv�lido: "+ cTo + chr(10) + chr(10) +"Obs.: Um email ser� enviado ao atendimento Solicitando a corre��o ao cadastro do cliente!")
		cConteudo:= "<H2>E-MAIL INVALIDO: "+ cTo +"</H2>" + cConteudo
		
		
		if cFilAnt==''
			cTo:= ""
		elseif cFIlAnt==''
			cTo:=""
		endif
		cCC2 := ""
		cSubject:="EMAIL DO CLIENTE INVALIDO"
		
		
		cMsg:= "Corre��o solicitada ao Atendimento/administrativo. - "+cTo
	
	end if
EndIf

cCC+= ", "
cCC+= cCC2

		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk   
		 	      
			If !lAutOk 
			If ( lSmtpAuth )
			lAutOk := MailAuth(cAccount,cPassword)
			Else
			lAutOk := .T.
			EndIf 
			EndIf       
			     	
			cBody := cConteudo
		
		
		   	If lOk .and. lAutOk 
				 Send Mail From cFrom To cTo CC cCC Subject cSubject Body cBody Result lOk
			
				If lConfirmaEnvio = .T.
					If lOk
						MsgInfo(cMsg)
					Else
						GET MAIL ERROR cErro
						MsgStop("N�o foi poss�vel enviar o Email. Contate setor de T.I." +Chr(13)+Chr(10)+ cErro,"AVISO")
						Return .f.
					EndIf
				EndIf	   
		 	Else
				GET MAIL ERROR cErro
				MsgStop("Erro na conex�o com o SMTP Server. Contate setor de T.I." +Chr(13)+Chr(10)+ cErro,"AVISO")
				Return .f.
			EndIf 
				
				DISCONNECT SMTP SERVER

Return .T.

//Fun��o para v�lidar se o e-mail � v�lido

STATIC FUNCTION ValidEmail(cEmail, lCliente)

lRet := .T.

if !"@" $ cEmail	
	lRet := .F.
endif

if !"." $ cEmail	
	lRet := .F.
endif

If lCliente = .T.
	if "CITOPH" $ cEmail .OR. "citoph" $ cEmail 	
		lRet := .F.
		
	Endif
EndIf

if "/" $ cEmail	
	lRet := .F.
endif

if "*" $ cEmail	
	lRet := .F.
endif

RETURN lRet





