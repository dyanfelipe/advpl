#INCLUDE "rwmake.ch"
User Function RDREG004()
//Declaracao de Variaveis
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "RELATORIO DE TAREFA A SER REALIZADA"
Local cPict          := ""
Local titulo       := "AGENDAMENTO DE TAREFA"
Local nLin         := 132
Local cQuery		:= ""
Local cQuery1 := ""
Local cAnvisa		:=""
STATIC cVend		:=""
Local Cabec1       := "C�digo   Titulo da Tarefa                Informa��o                                         Respons�vel                            Data Inicial    Data Final"
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}

Private oExcel := FWMSEXCEL():New()
Private cAba1:= "Vendas"
Private cAba2:= "Devolucoes"
Private cAba3 := "Resumo"
Private cTitulo:= "Tarefas"
Private cGet4 := "C:\smartclient\Relat�rio.XLS"

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "RDREG002 " + RetCodUsr()
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "RDREG002"
Private cPerg      :="RALTARMENU"
Private cString := "SZI"

dbSelectArea("SZI")
dbSetOrder(1)



Pergunte(cPerg,.T.)//Chama a pergunta

nTipo := If(aReturn[4]==1,15,18)
cGet4 := alltrim(MV_PAR05) + ".xls" //Campo do exel Caminho onde o arquivo vai ser salvo.
cQuery+=" SELECT DISTINCT SZI010.ZI_COD, SZI010.ZI_ZUSUARI, SZI010.ZI_ZTITULO ,SZI010.ZI_ZINFORM,SZI010.ZI_ZALETU, SZI010.ZI_ZDATAIN, SZI010.ZI_ZDATAFI, SZI010.ZI_ZDPARTM,SZI010.ZI_CODUSER, SZI010.ZI_NOMEUSR"
cQuery+=" FROM SZI010"
cQuery+=" WHERE SZI010.D_E_L_E_T_ <> '*'"
cQuery+=" AND SZI010.ZI_FILIAL = '"+xFilial("SZI")+"'"
cQuery+=" AND SZI010.ZI_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
cQuery+=" AND SZI010.ZI_ZDATAIN BETWEEN " + dtos(MV_PAR03) + " AND " + dtos(MV_PAR04) 
cQuery+=" AND SZI010.ZI_ZDATAFI BETWEEN " + dtos(MV_PAR03) + " AND " + dtos(MV_PAR04) 
cQuery+=" AND SZI010.ZI_ZDATAIN <= GETDATE() + SZI010.ZI_ZALETU"
cQuery+=" AND SZI010.ZI_ZSTATUS <> '2'"
cQuery+=" ORDER BY ZI_COD "
dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery),"TBLT", .F.,.T.)

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)// Monta a interface padrao com o usuario...

If nLastKey == 27
	Return
Endif                           		

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)//RPTSTATUS monta janela com a regua de processamento.
Return

/*
Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS
monta a janela com a regua de processamento.
*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem

dbSelectArea(cString)
dbSetOrder(1)
dbSelectArea("TBLT")

SetRegua(RecCount())//SETREGUA -> Indica quantos registros serao processados para a regua


/*
Posicionamento do primeiro registro e loop principal. Pode-se criar �
a logica da seguinte maneira: Posiciona-se na filial corrente e pro �
cessa enquanto a filial do registro for a filial corrente. Por exem �
plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    �
�
dbSeek(xFilial())                                                   �
While !EOF() .And. xFilial() == A1_FILIAL                           �
*/
dbGoTop()
//Titulo da Tarefa que vais ser salvo no exel.
oExcel:AddworkSheet(cAba1)
oExcel:AddTable (cAba1, cTitulo)
oExcel:AddColumn(cAba1, cTitulo,"Cod Tarefa",1,1)
oExcel:AddColumn(cAba1, cTitulo,"Titulo",1,1)
oExcel:AddColumn(cAba1, cTitulo,"Informa��o da Tarefa",1,1)
oExcel:AddColumn(cAba1, cTitulo,"Respons�vel",1,1)
oExcel:AddColumn(cAba1, cTitulo,"Data De Inicio",1,1)
oExcel:AddColumn(cAba1, cTitulo,"Data Final",1,1)
oExcel:AddColumn(cAba1, cTitulo,"Aviso Antecipado",1,1)

While !EOF()
	
	//Verifica o cancelamento pelo usuario.
	If lAbortPrint
		Pergunte(cPerg,.F.)
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	//Impressao do cabecalho do relatorio.
	If nLin > 65 // Salto de Pagina. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
	
	// Coloque aqui a logica da impressao do seu programa...
	// Utilize PSAY para saida na impressora. Por exemplo:
	// @nLin,00 PSAY SA1->A1_COD
	
	TabelaSZJ()
	dbSelectArea("TSZJ")
	dbGoTop()
	
	IF(TBLT->ZI_CODUSER == RetCodUsr() .OR. TSZJ->ZJ_ZCODUSU == RetCodUsr())
		
		oExcel:AddRow(cAba1,cTitulo,{"Projeto: " + TBLT->ZI_COD ,TBLT->ZI_ZTITULO, TBLT->ZI_ZINFORM, TBLT->ZI_ZUSUARI, DtoC(StoD(TBLT->ZI_ZDATAIN)), DtoC(StoD(TBLT->ZI_ZDATAFI)), TBLT->ZI_ZALETU})
		
		@nLin,0 PSAY "________________________________________________________________________________________________________________________________________________________________"
		@nLin,00 PSAY cValToChar(TBLT->ZI_COD)
		@nLin,9 PSAY Substr(TBLT->ZI_ZTITULO,1,30)
		@nLin,41 PSAY TBLT->ZI_ZINFORM
		@nLin,91 PSAY TBLT->ZI_NOMEUSR
		@nLin,132 PSAY DtoC(StoD(TBLT->ZI_ZDATAIN))
		@nLin,148 PSAY DtoC(StoD(TBLT->ZI_ZDATAFI))
		nLin++
		
		While !EOF()
			
			oExcel:AddRow(cAba1,cTitulo,{"Item: " + TSZJ->ZJ_ITEM ,TSZJ->ZJ_DESC, TSZJ->ZJ_DESC,1,30, TSZJ->ZJ_ZNOMEUS,1,10, TSZJ->ZJ_ZINFORM,1,20, DtoC(StoD(TSZJ->ZJ_ZDATA)),IIF(TSZJ->ZJ_ZSTATUS == "1","Aberto","Fechado")})
			
			@nLin,12 PSAY "Tarefa: "  + TSZJ->ZJ_ITEM
			@nLin,31 PSAY Substr(TSZJ->ZJ_DESC,1,30)
			@nLin,67 PSAY Substr(TSZJ->ZJ_ZNOMEUS,1,10)
			if (TSZJ->ZJ_ZSTATUS=="1")
				@nLin,79 PSAY "Aberto"
			elseif(TSZJ->ZJ_ZSTATUS=="2")
				@nLin,79 PSAY "Fechado"
			else
				@nLin,79 PSAY "Campo em branco"
			endif
			@nLin,88 PSAY Substr(TSZJ->ZJ_ZINFORM,1,20)
			@nLin,109 PSAY DtoC(StoD(TSZJ->ZJ_ZDATA))
			nLin++
			DBSKIP()
		enddo
		nLin++
		@nLin,0 PSAY "________________________________________________________________________________________________________________________________________________________________"
	ENDIF
	
	
	dbSelectArea("TSZJ")
	dbCloseArea()
	
	dbselectArea("TBLT")
	dbSkip()
enddo
//Exel: Caminho a ser salvo.  
oExcel:Activate()
oExcel:GetXMLFile(cGet4)

MSGINFO('Arquivo salvo no seguinte diretorio: ' + chr(10) + cGet4)
AbrirArquivo(cGet4)
//Finaliza a execucao do relatorio...

SET DEVICE TO SCREEN

//Se impressao em disco, chama o gerenciador de impressao...

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

Static Function AbrirArquivo(cGet4)

oExcelApp := MsExcel():New()
//alguns caso descomentar o codigo abaixo.
//oExcelApp:WorkBooks:Open()

IF MSGYESNO(cGet4 + chr(10)+ chr(10) + "Deseja Abrir a Planilha Agora? ")
	oExcelApp:WorkBooks:Open(cGet4) //Abre uma planilha
	oExcelApp:WorkBooks:Open(cGet4) //Abre uma planilha
	oExcelApp:SetVisible(.T.)
else
	return
endif

Return

Static Function TabelaSZJ()
Local cQuery1 := ""


cQuery1 += " SELECT SZJ010.ZJ_ZNUM,SZJ010.ZJ_ITEM,SZJ010.ZJ_DESC,SZJ010.ZJ_ZSTATUS,SZJ010.ZJ_ZNOMEUS, SZJ010.ZJ_ZINFORM, SZJ010.ZJ_ZDATA,SZJ010.ZJ_ZCODUSU"
cQuery1 += " FROM SZJ010"
cQuery1 += " WHERE SZJ010.D_E_L_E_T_ <> '*'"
cQuery1 += " AND SZJ010.ZJ_ZDATA <= GETDATE() + SZJ010.ZJ_ZALERTA"
cQuery1 += " AND SZJ010.ZJ_ZNUM = "+TBLT->ZI_COD
IF(TBLT->ZI_CODUSER <> RetCodUsr())
	cQuery1 += " AND SZJ010.ZJ_ZCODUSU =" + RetCodUsr()
ENDIF
dbUseArea(.t., "TOPCONN", tcgenqry(,,cQuery1),"TSZJ", .F.,.T.)

return