/*
+-----------+------------+----------------+-------------------+-------+---------------+
| Programa  | FA040INC   | Desenvolvedor  |    FELIPE JUNIO   | Data  |  18/01/2019   |
+-----------+------------+----------------+-------------------+-------+---------------+
| Descricao | Ponto de entrada usado para validar a inclus�o de titulos no contas     |
|           | a receber.									      					  |
|           |                    						     						  |
+-----------+-------------------------------------------------------------------------+
| Modulos   | SIGAFAT                                                                 |
+-----------+-------------------------------------------------------------------------+
| Processos |                                                                         |
+-----------+-------------------------------------------------------------------------+
|                  Modificacoes desde a construcao inicial                            |
+----------+-------------+------------------------------------------------------------+
| DATA     | PROGRAMADOR | MOTIVO                                                     |
+----------+-------------+------------------------------------------------------------+
|		   |			 |											  				  |
+----------+-------------+------------------------------------------------------------+
*/
#INCLUDE 'Protheus.ch'
#INCLUDE 'Parmtype.ch'

USER FUNCTION FA040INC()
	
	LOCAL lOk := .T.

	IF ( !ValTitNcc() .AND. GetMv("MV_F040PED",.F.,.F.) ) //--> Valida se o campo do or�amento est� vazio quando titulo � do tipo NCC (Felipe Junio)
		MsgAlert('O campo "Vendas" da primeira pasta n�o foi prenchido, por favor verificar.',"TOTVS||") ; lOk := .F.
	ENDIF

	IF(cFilAnt=='0201')
		lOk:= ValidBAT()
	ENDIF

RETURN lOk

STATIC FUNCTION ValTitNcc()

	LOCAL lOk := .T.

	IF ( Empty(M->E1_ZVENDA) .AND. ALLTRIM(M->E1_TIPO) == "NCC" )
		lOk := .F.
	ENDIF
RETURN lOk

/*/{Protheus.doc} Static Function ValidaBAT
	@type  Valida.
	@author Dyan
	@since 15/08/2019
	@0.01
	@Modulo: SIGAFIN
	@Valida se os campos NUM, CLIENTE, NOTA s�o validos
	@ No caso da nota ela n�o pode est� faturada 
	/*/
Static Function ValidBAT()

LOCAL lRet := .T.

dbSelectArea("SC5")
dbSetorder(1)
dbSeek(xFilial ("SC5")+M->E1_NUM)

	if (M->E1_PREFIXO = "BAT" .AND. SC5->C5_CONDPAG = "BAT")

		if (M->E1_NUM != SC5->C5_NUM .OR. M->E1_CLIENTE != SC5->C5_CLIENTE .OR. M->E1_LOJA != SC5->C5_LOJACLI)
			MsgAlert ("As informa��es (No. Titulo, Cliente, loja, Prefixo) tem que ser o mesmo do Pedido.")
			Return lRet := .F.
		elseif (Alltrim(SC5->C5_NOTA) != '')
			MsgAlert ("Digite um pedido que ainda n�o foi faturado.")
			RETURN lRet := .F.
		ENDIF
	else
		Msginfo("S� pode ser adicionado pedido do tipo BAT")
		Return .F.
	ENDIF

Return lRet