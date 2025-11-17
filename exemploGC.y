	
%{
  import java.io.*;
  import java.util.ArrayList;
  import java.util.Stack;
%}
 

%token ID, INT, FLOAT, BOOL, NUM, LIT, VOID, MAIN, READ, WRITE, IF, ELSE
%token WHILE,TRUE, FALSE, IF, ELSE, DO, FOR
%token BREAK, CONTINUE
%token EQ, LEQ, GEQ, NEQ 
%token AND, OR
%token PLUSPLUS, MINUSMINUS, PLUSEQUAL

%right '=' 
%right '?' ':'

%left OR
%left AND
%left  '>' '<' EQ LEQ GEQ NEQ
%left '+' '-'
%left '*' '/' '%'
%left '!' 
%nonassoc '++' '--' '+='

%type <sval> ID
%type <sval> LIT
%type <sval> NUM
%type <ival> type

%%

prog : { geraInicio(); } dList mainF { geraAreaDados(); geraAreaLiterais(); } ;

mainF : VOID MAIN '(' ')'   { System.out.println("_start:"); }
        '{' lcmd  { geraFinal(); } '}'
         ; 

dList : decl dList | ;

decl : type ID ';' {  TS_entry nodo = ts.pesquisa($2);
    	                if (nodo != null) 
                            yyerror("(sem) variavel >" + $2 + "< jah declarada");
                        else ts.insert(new TS_entry($2, $1)); }
      ;

type : INT    { $$ = INT; }
     | FLOAT  { $$ = FLOAT; }
     | BOOL   { $$ = BOOL; }
     ;

lcmd : lcmd cmd
	   |
	   ;
	   
cmd :  exp	';' {  System.out.println("\tPOPL %EDX"); }
			| '{' lcmd '}' { System.out.println("\t\t# terminou o bloco..."); }
					     
					       
      | WRITE '(' LIT ')' ';' { strTab.add($3);
                                System.out.println("\tMOVL $_str_"+strCount+"Len, %EDX"); 
				System.out.println("\tMOVL $_str_"+strCount+", %ECX"); 
                                System.out.println("\tCALL _writeLit"); 
				System.out.println("\tCALL _writeln"); 
                                strCount++;
				}
      
	  | WRITE '(' LIT 
                              { strTab.add($3);
                                System.out.println("\tMOVL $_str_"+strCount+"Len, %EDX"); 
				System.out.println("\tMOVL $_str_"+strCount+", %ECX"); 
                                System.out.println("\tCALL _writeLit"); 
				strCount++;
				}

                    ',' exp ')' ';' 
			{ 
			 System.out.println("\tPOPL %EAX"); 
			 System.out.println("\tCALL _write");	
			 System.out.println("\tCALL _writeln"); 
                        }
         
     | READ '(' ID ')' ';'								
								{
									System.out.println("\tPUSHL $_"+$3);
									System.out.println("\tCALL _read");
									System.out.println("\tPOPL %EDX");
									System.out.println("\tMOVL %EAX, (%EDX)");
									
								}
         
    | WHILE {
					pRot.push(proxRot);  
					proxRot += 2;

					pBreak.push(pRot.peek() + 1);
					pContinue.push(pRot.peek());

					System.out.printf("rot_%02d:\n",pRot.peek());
				  } 
			 '(' exp ')' {
						System.out.println("\tPOPL %EAX   # desvia se falso...");
						System.out.println("\tCMPL $0, %EAX");
						System.out.printf("\tJE rot_%02d\n", (int)pRot.peek()+1);
				} 
				cmd	{
						System.out.printf("\tJMP rot_%02d   # terminou cmd na linha de cima\n", pRot.peek());
						System.out.printf("rot_%02d:\n",(int)pRot.peek()+1);
						pRot.pop();
						pBreak.pop();
						pContinue.pop();
				}  

	| DO {
			pRot.push(proxRot);  //rotulo base
			proxRot += 2; // reserva mais 2 rotulos pro do while

			//guarda o contexto nas pilhas
			pBreak.push(pRot.peek() + 2); 
			pContinue.push(pRot.peek() + 2);


			System.out.printf("rot_%02d:\n", pRot.peek());
		}
		cmd
		WHILE '(' exp ')' ';' {
			System.out.println("\tPOPL %EAX    # desvia se falso..."); // copia o topo da pilha pro EAX
			System.out.println("\tCMPL $0, %EAX"); // verifica se é 0 (falso)
			System.out.printf("\tJNE rot_%02d\n", (int)pRot.peek()); //  se for, pula pro inicio do while
			//limpa o contexto deste 
			pRot.pop();
			pBreak.pop();
			pContinue.pop();
		}
	| FOR '('{
			pRot.push(proxRot);  
			proxRot += 4; // reserva espaco pros 4 rotulos
			//adiciona o contexto nas pilhas
			pBreak.push(pRot.peek() + 1); 
			pContinue.push(pRot.peek() + 2);
		} 
		
		FORINICIO ';' { 
			System.out.printf("rot_%02d:\n", pRot.peek()); //inicio do for pra voltar depois
		}
		
		FORCONDICAO ';' {
        	System.out.printf("\tJMP rot_%02d\n", pRot.peek()+3); //pula pro fim 
    		System.out.printf("rot_%02d:\n", pRot.peek()+2);   //marca a parte do incremento (vai precisar?)    
        }
		
		FORINCREMENTO {
			System.out.printf("\tJMP rot_%02d\n", pRot.peek()); //volta pra reavaliar a condicao   
         	System.out.printf("rot_%02d:\n", pRot.peek()+3); //marca a parte do inicio do cmd
		}
		
		')' cmd {
			System.out.printf("\tJMP rot_%02d\n", pRot.peek()+2); //depois de executar, vai pra parte do incremento
        	System.out.printf("rot_%02d:\n", pRot.peek()+1);     //marca o rotulo de saóda do for  

			//tira o contexto deste for nas pilhas
        	pRot.pop();
			pBreak.pop();
			pContinue.pop();
		}
	| BREAK ';' {
		//pula direto pro final do loop em que está
			System.out.printf("\tJMP rot_%02d\n", pBreak.peek());    
		}
	| CONTINUE ';' {
		//pula direto pro inicio do loop em que esta
			System.out.printf("\tJMP rot_%02d\n", pContinue.peek());   
		}
	| IF '(' exp {	
					pRot.push(proxRot);  proxRot += 2;
									
					System.out.println("\tPOPL %EAX");
					System.out.println("\tCMPL $0, %EAX");
					System.out.printf("\tJE rot_%02d\n", pRot.peek());
				}
		 ')' cmd 

			restoIf {
									System.out.printf("rot_%02d:\n",pRot.peek()+1);
									pRot.pop();
								}
			;

restoIf : ELSE  {
						System.out.printf("\tJMP rot_%02d\n", pRot.peek()+1);
						System.out.printf("rot_%02d:\n",pRot.peek());
			
					} 							
		cmd  				
			| {
				System.out.printf("\tJMP rot_%02d\n", pRot.peek()+1);
					System.out.printf("rot_%02d:\n",pRot.peek());
					} 
			;	

FORINICIO : exp {
			System.out.println("\tPOPL %EDX"); // copia a exp pro registrador
			}	
		  | 
		  ;

FORCONDICAO : exp {
				System.out.println("\tPOPL %EAX");
				System.out.println("\tCMPL $0, %EAX");
				System.out.printf("\tJE rot_%02d\n", pRot.peek()+1); 
				}
			|
			;

FORINCREMENTO : exp { //acabou que era igual ao inicio kkkk
					System.out.println("\tPOPL %EDX");
					}	
		      | 
		      ;
				
												


exp :  NUM  { System.out.println("\tPUSHL $"+$1); } 
    |  TRUE  { System.out.println("\tPUSHL $1"); } 
    |  FALSE  { System.out.println("\tPUSHL $0"); }      
    | ID   { System.out.println("\tPUSHL _"+$1); }
    | '(' exp	')' 
    | '!' exp       { gcExpNot(); }
     
		| exp '+' exp		{ gcExpArit('+'); }
		| exp '-' exp		{ gcExpArit('-'); }
		| exp '*' exp		{ gcExpArit('*'); }
		| exp '/' exp		{ gcExpArit('/'); }
		| exp '%' exp		{ gcExpArit('%'); }
																			
		| exp '>' exp		{ gcExpRel('>'); }
		| exp '<' exp		{ gcExpRel('<'); }											
		| exp EQ exp		{ gcExpRel(EQ); }											
		| exp LEQ exp		{ gcExpRel(LEQ); }											
		| exp GEQ exp		{ gcExpRel(GEQ); }											
		| exp NEQ exp		{ gcExpRel(NEQ); }											
												
		| exp OR exp		{ gcExpLog(OR); }											
		| exp AND exp		{ gcExpLog(AND); }		
											
	    | PLUSPLUS ID { //deixa na pilha o valor novo
					System.out.println("\tPUSHL _" + $2); // empilha o id 
 					System.out.println("\tPUSHL $1");  // empilha 1
					gcExpArit('+'); // soma os 2
					System.out.println("\tPOPL %EDX"); // pega o valor da pilha e guarda em EDX
					System.out.println("\tMOVL %EDX, _" + $2); //atribui isso no ID
					System.out.println("\tPUSHL %EDX"); //empilha o valor dnv pra deixar um valor
				}
		| ID PLUSPLUS { //ao contrario do anterior, ele deixa na pilha o valor antigo
					System.out.println("\tPUSHL _" + $1);   //empilha o id 2 vezes. aqui o antigo valor
					System.out.println("\tPUSHL _" + $1);   //aqui o vai ser o novo
					System.out.println("\tPUSHL $1"); // empilha 1 pra somar
					gcExpArit('+');                         //faz a soma
					System.out.println("\tPOPL %EDX");		// retira o valor novo e guarda no reg EDX
					System.out.println("\tMOVL %EDX, _" + $1); // Atualiza o ID com o novo valor
		}


		| MINUSMINUS ID { //deixa na pilha o novo resultado
					System.out.println("\tPUSHL _" + $2); //coloca o valor de ID na pilha
					System.out.println("\tPUSHL $1"); //coloca 1 na pilhja
					gcExpArit('-');             // faz a subtracao (aqui a ordem importa)
					System.out.println("\tPOPL %EDX"); //tira o resultado da pilha pro edx
					System.out.println("\tMOVL %EDX, _" + $2); //atualiza o ID com o novo valor
					System.out.println("\tPUSHL %EDX"); //devolve o resultado para continuar na pilha
				}
		| ID MINUSMINUS { //deixa na pilha o valor antigo
					System.out.println("\tPUSHL _" + $1); //empilha o antigo e o que ira ser o novo valor
					System.out.println("\tPUSHL _" + $1); 
					System.out.println("\tPUSHL $1"); // eppilha 1
					gcExpArit('-');  //subtrai
					System.out.println("\tPOPL %EDX"); //busca o resultado e armazena em edx
					System.out.println("\tMOVL %EDX, _" + $1); // atribui o valor de edx pro ID
				}

		| ID '=' exp	{  
					System.out.println("\tPOPL %EDX");
					System.out.println("\tPUSHL %EDX");
  					System.out.println("\tMOVL %EDX, _"+$1);
				}

		// a += b; -> a = a + b;
		| ID PLUSEQUAL exp	{  // a exp é pra ter deixado um valor na pilha, logo
					System.out.println("\tPUSHL _" + $1); // adiciona ID na pilha
					gcExpArit('+'); //soma as duas
					System.out.println("\tPOPL %EDX"); // tira o resultado da pilha pro reg
					System.out.println("\tMOVL %EDX, _" + $1); // atribui o novo resultado no ID
					System.out.println("\tPUSHL %EDX");  //deixa dnv o resultado no topo da pilha
				}

		// a = b > c ? b : c - > if (b>c) {a = b} else {a = c}
		| exp '?' {
					// gera dois rótulos novos
					int rFalso = proxRot++; //é como se fosse o do else
					int rFim   = proxRot++; // e aqui é pro final kkkk
					
					//adiciona nas pilhas
					pCondFalso.push(rFalso);
					pCondFim.push(rFim);

					// testa o valor da condição (que está no topo da pilha)
					System.out.println("\tPOPL %EAX"); // pega o valor e coloca em EAX
					System.out.println("\tCMPL $0, %EAX"); // verifica se é 0 (falso)
					System.out.printf("\tJE rot_%02d\n", rFalso); // se for falso vai para ramo falso
				}
			exp	{
					// aqui é o camninho verdadeiro
					//da uma olhadinha no topo das pilhas os valores deste contexto
					int rFalso = pCondFalso.peek();
					int rFim   = pCondFim.peek();

					// pula o ramo falso
					System.out.printf("\tJMP rot_%02d\n", rFim);
					// marca início do ramo falso
					System.out.printf("rot_%02d:\n", rFalso);
				}
			':' exp
				{
					// tira os rotulos deste contexto da pilha
					int rFim = pCondFim.pop();
					pCondFalso.pop();
					// marca o final do operador condicional
					System.out.printf("rot_%02d:\n", rFim);
				}
					


%%

  private Yylex lexer;

  private TabSimb ts = new TabSimb();

  private int strCount = 0;
  private ArrayList<String> strTab = new ArrayList<String>();

 //pilha original
  private Stack<Integer> pRot = new Stack<Integer>();
  
  // pilhas pro :?
  private Stack<Integer> pCondFalso = new Stack<Integer>();
  private Stack<Integer> pCondFim   = new Stack<Integer>();

  
  //pilhas pro brack e continue
  private Stack<Integer> pBreak = new Stack<Integer>();
  private Stack<Integer> pContinue = new Stack<Integer>();


  private int proxRot = 1;


  public static int ARRAY = 100;


  private int yylex () {
    int yyl_return = -1;
    try {
      yylval = new ParserVal(0);
      yyl_return = lexer.yylex();
    }
    catch (IOException e) {
      System.err.println("IO error :"+e);
    }
    return yyl_return;
  }


  public void yyerror (String error) {
    System.err.println ("Error: " + error + "  linha: " + lexer.getLine());
  }


  public Parser(Reader r) {
    lexer = new Yylex(r, this);
  }  

  public void setDebug(boolean debug) {
    yydebug = debug;
  }

  public void listarTS() { ts.listar();}

  public static void main(String args[]) throws IOException {

    Parser yyparser;
    if ( args.length > 0 ) {
      // parse a file
      yyparser = new Parser(new FileReader(args[0]));
      yyparser.yyparse();
      // yyparser.listarTS();

    }
    else {
      // interactive mode
      System.out.println("\n\tFormato: java Parser entrada.cmm >entrada.s\n");
    }

  }

							
		void gcExpArit(int oparit) {
 				System.out.println("\tPOPL %EBX");
   			System.out.println("\tPOPL %EAX");

   		switch (oparit) {
     		case '+' : System.out.println("\tADDL %EBX, %EAX" ); break;
     		case '-' : System.out.println("\tSUBL %EBX, %EAX" ); break;
     		case '*' : System.out.println("\tIMULL %EBX, %EAX" ); break;

    		case '/': 
           		     System.out.println("\tMOVL $0, %EDX");
           		     System.out.println("\tIDIVL %EBX");
           		     break;
     		case '%': 
           		     System.out.println("\tMOVL $0, %EDX");
           		     System.out.println("\tIDIVL %EBX");
           		     System.out.println("\tMOVL %EDX, %EAX");
           		     break;
    		}
   		System.out.println("\tPUSHL %EAX");
		}

	public void gcExpRel(int oprel) {

    System.out.println("\tPOPL %EAX");
    System.out.println("\tPOPL %EDX");
    System.out.println("\tCMPL %EAX, %EDX");
    System.out.println("\tMOVL $0, %EAX");
    
    switch (oprel) {
       case '<':  			System.out.println("\tSETL  %AL"); break;
       case '>':  			System.out.println("\tSETG  %AL"); break;
       case Parser.EQ:  System.out.println("\tSETE  %AL"); break;
       case Parser.GEQ: System.out.println("\tSETGE %AL"); break;
       case Parser.LEQ: System.out.println("\tSETLE %AL"); break;
       case Parser.NEQ: System.out.println("\tSETNE %AL"); break;
       }
    
    System.out.println("\tPUSHL %EAX");

	}


	public void gcExpLog(int oplog) {

	   	System.out.println("\tPOPL %EDX");
 		 	System.out.println("\tPOPL %EAX");

  	 	System.out.println("\tCMPL $0, %EAX");
 		  System.out.println("\tMOVL $0, %EAX");
   		System.out.println("\tSETNE %AL");
   		System.out.println("\tCMPL $0, %EDX");
   		System.out.println("\tMOVL $0, %EDX");
   		System.out.println("\tSETNE %DL");

   		switch (oplog) {
    			case Parser.OR:  System.out.println("\tORL  %EDX, %EAX");  break;
    			case Parser.AND: System.out.println("\tANDL  %EDX, %EAX"); break;
       }

    	System.out.println("\tPUSHL %EAX");
	}

	public void gcExpNot(){

  	 System.out.println("\tPOPL %EAX" );
 	   System.out.println("	\tNEGL %EAX" );
  	 System.out.println("	\tPUSHL %EAX");
	}

   private void geraInicio() {
			System.out.println(".text\n\n#\t nome COMPLETO e matricula dos componentes do grupo...\n#\n"); 
			System.out.println(".GLOBL _start\n\n");  
   }

   private void geraFinal(){
	
			System.out.println("\n\n");
			System.out.println("#");
			System.out.println("# devolve o controle para o SO (final da main)");
			System.out.println("#");
			System.out.println("\tmov $0, %ebx");
			System.out.println("\tmov $1, %eax");
			System.out.println("\tint $0x80");
	
			System.out.println("\n");
			System.out.println("#");
			System.out.println("# Funcoes da biblioteca (IO)");
			System.out.println("#");
			System.out.println("\n");
			System.out.println("_writeln:");
			System.out.println("\tMOVL $__fim_msg, %ECX");
			System.out.println("\tDECL %ECX");
			System.out.println("\tMOVB $10, (%ECX)");
			System.out.println("\tMOVL $1, %EDX");
			System.out.println("\tJMP _writeLit");
			System.out.println("_write:");
			System.out.println("\tMOVL $__fim_msg, %ECX");
			System.out.println("\tMOVL $0, %EBX");
			System.out.println("\tCMPL $0, %EAX");
			System.out.println("\tJGE _write3");
			System.out.println("\tNEGL %EAX");
			System.out.println("\tMOVL $1, %EBX");
			System.out.println("_write3:");
			System.out.println("\tPUSHL %EBX");
			System.out.println("\tMOVL $10, %EBX");
			System.out.println("_divide:");
			System.out.println("\tMOVL $0, %EDX");
			System.out.println("\tIDIVL %EBX");
			System.out.println("\tDECL %ECX");
			System.out.println("\tADD $48, %DL");
			System.out.println("\tMOVB %DL, (%ECX)");
			System.out.println("\tCMPL $0, %EAX");
			System.out.println("\tJNE _divide");
			System.out.println("\tPOPL %EBX");
			System.out.println("\tCMPL $0, %EBX");
			System.out.println("\tJE _print");
			System.out.println("\tDECL %ECX");
			System.out.println("\tMOVB $'-', (%ECX)");
			System.out.println("_print:");
			System.out.println("\tMOVL $__fim_msg, %EDX");
			System.out.println("\tSUBL %ECX, %EDX");
			System.out.println("_writeLit:");
			System.out.println("\tMOVL $1, %EBX");
			System.out.println("\tMOVL $4, %EAX");
			System.out.println("\tint $0x80");
			System.out.println("\tRET");
			System.out.println("_read:");
			System.out.println("\tMOVL $15, %EDX");
			System.out.println("\tMOVL $__msg, %ECX");
			System.out.println("\tMOVL $0, %EBX");
			System.out.println("\tMOVL $3, %EAX");
			System.out.println("\tint $0x80");
			System.out.println("\tMOVL $0, %EAX");
			System.out.println("\tMOVL $0, %EBX");
			System.out.println("\tMOVL $0, %EDX");
			System.out.println("\tMOVL $__msg, %ECX");
			System.out.println("\tCMPB $'-', (%ECX)");
			System.out.println("\tJNE _reading");
			System.out.println("\tINCL %ECX");
			System.out.println("\tINC %BL");
			System.out.println("_reading:");
			System.out.println("\tMOVB (%ECX), %DL");
			System.out.println("\tCMP $10, %DL");
			System.out.println("\tJE _fimread");
			System.out.println("\tSUB $48, %DL");
			System.out.println("\tIMULL $10, %EAX");
			System.out.println("\tADDL %EDX, %EAX");
			System.out.println("\tINCL %ECX");
			System.out.println("\tJMP _reading");
			System.out.println("_fimread:");
			System.out.println("\tCMPB $1, %BL");
			System.out.println("\tJNE _fimread2");
			System.out.println("\tNEGL %EAX");
			System.out.println("_fimread2:");
			System.out.println("\tRET");
			System.out.println("\n");
     }

     private void geraAreaDados(){
			System.out.println("");		
			System.out.println("#");
			System.out.println("# area de dados");
			System.out.println("#");
			System.out.println(".data");
			System.out.println("#");
			System.out.println("# variaveis globais");
			System.out.println("#");
			ts.geraGlobais();	
			System.out.println("");
	
    }

     private void geraAreaLiterais() { 

         System.out.println("#\n# area de literais\n#");
         System.out.println("__msg:");
	       System.out.println("\t.zero 30");
	       System.out.println("__fim_msg:");
	       System.out.println("\t.byte 0");
	       System.out.println("\n");

         for (int i = 0; i<strTab.size(); i++ ) {
             System.out.println("_str_"+i+":");
             System.out.println("\t .ascii \""+strTab.get(i)+"\""); 
	           System.out.println("_str_"+i+"Len = . - _str_"+i);  
	      }		
   }
   
